#!/usr/bin/env python3

import logging
import os
import re
import shutil
import subprocess
import sys

from pathlib import Path
from typing import List

from setuptools import Extension, setup
from setuptools.command.build_ext import build_ext


logger = logging.getLogger(__name__)


def get_base_dir():
    return os.path.abspath(os.path.dirname(__file__))


def join_path(*paths):
    return os.path.join(get_base_dir(), *paths)


def read_requirements() -> List[str]:
    file = join_path("requirements.txt")
    with open(file) as f:
        return f.read().splitlines()


def get_ninja_dir():
    ninja_dir = shutil.which("ninja")
    return ninja_dir


# ---- cmake extension ----
def check_cmake():
    # check cmake is installed
    try:
        out = subprocess.check_output(["cmake", "--version"])
    except OSError:
        raise RuntimeError("CMake must be installed.")

    match = re.search(
        r"version\s*(?P<major>\d+)\.(?P<minor>\d+)([\d.]+)?", out.decode()
    )
    cmake_major, cmake_minor = int(match.group("major")), int(match.group("minor"))
    if (cmake_major, cmake_minor) < (3, 18):
        raise RuntimeError("CMake >= 3.18.0 is required")


def get_cmake_out_dir():
    cmake_out_dir = Path(get_base_dir()) / "build"
    cmake_out_dir.mkdir(parents=True, exist_ok=True)
    return cmake_out_dir


# A CMakeExtension needs a sourcedir instead of a file list.
# The name must be the _single_ output extension from the CMake build.
# If you need multiple extensions, see scikit-build.
class CMakeExtension(Extension):
    def __init__(self, name: str, path: str, sourcedir: str = "") -> None:
        super().__init__(name, sources=[])
        self.sourcedir = os.fspath(Path(sourcedir).resolve())
        self.path = path


class CMakeBuild(build_ext):
    user_options = build_ext.user_options + [
        ("base-dir=", None, "base directory of ScaleLLM project"),
    ]

    def initialize_options(self):
        build_ext.initialize_options(self)
        self.base_dir = get_base_dir()

    def finalize_options(self):
        build_ext.finalize_options(self)

    def run(self):
        # check cmake is installed
        check_cmake()

        # build extensions
        for ext in self.extensions:
            self.build_extension(ext)

    def build_extension(self, ext: CMakeExtension):
        # the output dir for the extension
        # extdir = os.path.abspath(os.path.dirname(self.get_ext_fullpath(ext.path)))

        debug = int(os.environ.get("DEBUG", 0)) if self.debug is None else self.debug
        build_type = "Debug" if debug else "Release"

        cmake_cfg_args = []
        # Setup the build tool.
        ninja_dir = get_ninja_dir()
        if ninja_dir is not None:
            cmake_cfg_args += [
                "-G", "Ninja",
                f"-DCMAKE_MAKE_PROGRAM={ninja_dir}",  # pass in the ninja build path
            ]

        # Adding compiler arguments
        cmake_cfg_args += [
            f"-DCMAKE_BUILD_TYPE:STRING={build_type}",
            "-DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE",
            "-DCMAKE_C_COMPILER:FILEPATH=/usr/bin/gcc",
            "-DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++",
        ]

        # Pass the python executable to cmake so it can find an exact
        # match.
        cmake_cfg_args += [f"-DPython_EXECUTABLE:FILEPATH={sys.executable}"]

        # Adding CMake arguments set as environment variable
        # (needed e.g. to build for ARM OSx on conda-forge)
        if "CMAKE_ARGS" in os.environ:
            cmake_cfg_args += [item for item in os.environ["CMAKE_ARGS"].split(" ") if item]

        env = os.environ.copy()

        # print cmake args
        print("CMake Configuge Args: ", cmake_cfg_args)
        print("Env: ", env)
        
        cmake_out_dir = get_cmake_out_dir()
        # run cmake config process
        subprocess.check_call(
            ["cmake", self.base_dir] + cmake_cfg_args, cwd=cmake_out_dir, env=env
        )

        # adding number of jobs to build
        build_args = ["--config", build_type]
        max_jobs = os.getenv("MAX_JOBS", str(os.cpu_count()))
        build_args += ["-j" + max_jobs]
        # add build target to speed up the cmake build process
        build_args += ["--target", ext.name]
        # run cmake build process
        subprocess.check_call(["cmake", "--build", "."] + build_args, cwd=cmake_out_dir)


if __name__ == "__main__":
    setup(
        name="custom_ops",
        version="0.0.1",
        description="Custom ops.",
        packages=[],
        ext_modules=[CMakeExtension("custom_ops", "extension_cpp/")],
        cmdclass={"build_ext": CMakeBuild},
        zip_safe=False,
        python_requires=">=3.8",
        install_requires=read_requirements(),
    )
