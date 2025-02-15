#include <vector>
#include <torch/torch.h>

namespace extension_cpp {
  torch::Tensor mymuladd_cuda(const torch::Tensor &a, const torch::Tensor &b, double c);
  torch::Tensor mymul_cuda(const torch::Tensor &a, const torch::Tensor &b);
  void myadd_out_cuda(const torch::Tensor &a, const torch::Tensor &b, torch::Tensor &out);
}
