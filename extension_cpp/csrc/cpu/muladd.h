#include <vector>
#include <torch/torch.h>
// #include <torch/extension.h>

namespace extension_cpp {
  torch::Tensor mymuladd_cpu(const torch::Tensor &a, const torch::Tensor &b, double c);
  torch::Tensor mymul_cpu(const torch::Tensor &a, const torch::Tensor &b);
  void myadd_out_cpu(const torch::Tensor &a, const torch::Tensor &b, torch::Tensor &out);
}
