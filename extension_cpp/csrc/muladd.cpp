#include <vector>
#include <torch/torch.h>

#include "muladd.h"

namespace extension_cpp {

torch::Tensor mymuladd_cpu(const torch::Tensor& a, const torch::Tensor& b, double c) {
  TORCH_CHECK(a.sizes() == b.sizes());
  TORCH_CHECK(a.dtype() == torch::kFloat);
  TORCH_CHECK(b.dtype() == torch::kFloat);
  TORCH_INTERNAL_ASSERT(a.device().type() == torch::DeviceType::CPU);
  TORCH_INTERNAL_ASSERT(b.device().type() == torch::DeviceType::CPU);
  torch::Tensor a_contig = a.contiguous();
  torch::Tensor b_contig = b.contiguous();
  torch::Tensor result = torch::empty(a_contig.sizes(), a_contig.options());
  const float* a_ptr = a_contig.data_ptr<float>();
  const float* b_ptr = b_contig.data_ptr<float>();
  float* result_ptr = result.data_ptr<float>();
  for (int64_t i = 0; i < result.numel(); i++) {
    result_ptr[i] = a_ptr[i] * b_ptr[i] + c;
  }
  return result;
}

torch::Tensor mymul_cpu(const torch::Tensor& a, const torch::Tensor& b) {
  TORCH_CHECK(a.sizes() == b.sizes());
  TORCH_CHECK(a.dtype() == torch::kFloat);
  TORCH_CHECK(b.dtype() == torch::kFloat);
  TORCH_INTERNAL_ASSERT(a.device().type() == torch::DeviceType::CPU);
  TORCH_INTERNAL_ASSERT(b.device().type() == torch::DeviceType::CPU);
  torch::Tensor a_contig = a.contiguous();
  torch::Tensor b_contig = b.contiguous();
  torch::Tensor result = torch::empty(a_contig.sizes(), a_contig.options());
  const float* a_ptr = a_contig.data_ptr<float>();
  const float* b_ptr = b_contig.data_ptr<float>();
  float* result_ptr = result.data_ptr<float>();
  for (int64_t i = 0; i < result.numel(); i++) {
    result_ptr[i] = a_ptr[i] * b_ptr[i];
  }
  return result;
}

// An example of an operator that mutates one of its inputs.
void myadd_out_cpu(const torch::Tensor& a, const torch::Tensor& b, torch::Tensor& out) {
  TORCH_CHECK(a.sizes() == b.sizes());
  TORCH_CHECK(b.sizes() == out.sizes());
  TORCH_CHECK(a.dtype() == torch::kFloat);
  TORCH_CHECK(b.dtype() == torch::kFloat);
  TORCH_CHECK(out.dtype() == torch::kFloat);
  TORCH_CHECK(out.is_contiguous());
  TORCH_INTERNAL_ASSERT(a.device().type() == torch::DeviceType::CPU);
  TORCH_INTERNAL_ASSERT(b.device().type() == torch::DeviceType::CPU);
  TORCH_INTERNAL_ASSERT(out.device().type() == torch::DeviceType::CPU);
  torch::Tensor a_contig = a.contiguous();
  torch::Tensor b_contig = b.contiguous();
  const float* a_ptr = a_contig.data_ptr<float>();
  const float* b_ptr = b_contig.data_ptr<float>();
  float* result_ptr = out.data_ptr<float>();
  for (int64_t i = 0; i < out.numel(); i++) {
    result_ptr[i] = a_ptr[i] + b_ptr[i];
  }
}

}