#include <Python.h>
#include <torch/extension.h>
#include <torch/library.h>

#include "muladd.h"

extern "C" {
  /* Creates a dummy empty _C module that can be imported from Python.
     The import from Python will load the .so consisting of this file
     in this extension, so that the TORCH_LIBRARY static initializers
     below are run. */
  PyObject* PyInit__C(void)
  {
      static struct PyModuleDef module_def = {
          PyModuleDef_HEAD_INIT,
          "_C",   /* name of module */
          NULL,   /* module documentation, may be NULL */
          -1,     /* size of per-interpreter state of the module,
                     or -1 if the module keeps state in global variables. */
          NULL,   /* methods */
      };
      return PyModule_Create(&module_def);
  }
}

namespace extension_cpp {
// Registers _C as a Python extension module.
// PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {}

// Defines the operators
TORCH_LIBRARY(extension_cpp, m) {
  m.def("mymuladd(Tensor a, Tensor b, float c) -> Tensor");
  m.def("mymul(Tensor a, Tensor b) -> Tensor");
  m.def("myadd_out(Tensor a, Tensor b, Tensor(a!) out) -> ()");
}

// Registers CUDA implementations for mymuladd, mymul, myadd_out
TORCH_LIBRARY_IMPL(extension_cpp, CPU, m) {
  m.impl("mymuladd", &mymuladd_cpu);
  m.impl("mymul", &mymul_cpu);
  m.impl("myadd_out", &myadd_out_cpu);
}
}