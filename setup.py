#!/usr/bin/env python3

import io
import os
import re
import shutil
import subprocess
import sys
import sysconfig
from shutil import which
from pathlib import Path
from typing import List

from setuptools import Extension, setup
from setuptools.command.build_ext import build_ext


def is_ninja_available() -> bool:
    return which("ninja") is not None


def get_torch_root():
    try:
        import torch

        return str(Path(torch.__file__).parent)
    except ImportError:
        return None


def get_base_dir():
    return os.path.abspath(os.path.dirname(__file__))


def join_path(*paths):
    return os.path.join(get_base_dir(), *paths)


def read_requirements() -> List[str]:
    file = join_path("requirements.txt")
    with open(file) as f:
        return f.read().splitlines()


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


def get_cmake_dir():
    plat_name = sysconfig.get_platform()
    python_version = sysconfig.get_python_version().replace(".", "")
    dir_name = f"cmake.{plat_name}-{sys.implementation.name}-{python_version}"
    cmake_dir = Path(get_base_dir()) / "build" / dir_name
    cmake_dir.mkdir(parents=True, exist_ok=True)
    return cmake_dir


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
        ninja_dir = shutil.which("ninja")
        # the output dir for the extension
        # extdir = os.path.abspath(os.path.dirname(self.get_ext_fullpath(ext.path)))

        # create build directory
        os.makedirs(self.build_temp, exist_ok=True)

        # Using this requires trailing slash for auto-detection & inclusion of
        # auxiliary "native" libs

        debug = int(os.environ.get("DEBUG", 0)) if self.debug is None else self.debug
        build_type = "Debug" if debug else "Release"

        LIBTORCH_ROOT = get_torch_root()
        if LIBTORCH_ROOT is None:
            raise RuntimeError(
                "Please install requirements first, pip install -r requirements.txt"
            )

        # python directories
        cmake_args = [
            f"-DCMAKE_BUILD_TYPE:STRING={build_type}",  # not used on MSVC, but no harm
            "-DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE",
            f"-DCMAKE_C_COMPILER:FILEPATH=/usr/bin/clang",
            f"-DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/clang++",
            f"-DPython_EXECUTABLE:FILEPATH={sys.executable}",
        ]

        build_args = ["--config", build_type]
        max_jobs = os.getenv("MAX_JOBS", str(os.cpu_count()))
        build_args += ["-j" + max_jobs]

        env = os.environ.copy()
        env["LIBTORCH_ROOT"] = LIBTORCH_ROOT

        # print cmake args
        print("CMake Args: ", cmake_args)
        print("Env: ", env)

        # cmake_dir = get_cmake_dir()
        cmake_dir = self.build_temp
        # cmake_dir = "/Users/cat/Desktop/Workspace/ML/extension-cpp/build"
        subprocess.check_call(
            ["cmake", self.base_dir] + cmake_args, cwd=cmake_dir, env=env
        )

        # add build target to speed up the build process
        build_args += ["--target", ext.name]
        subprocess.check_call(["cmake", "--build", "."] + build_args, cwd=cmake_dir)


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
