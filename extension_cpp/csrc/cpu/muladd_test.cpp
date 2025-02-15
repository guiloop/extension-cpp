#include <iostream>
#include <gtest/gtest.h>
#include <torch/torch.h>
#include <torch/types.h>

#include "muladd.h"

namespace extension_cpp {

  TEST(MulAddTest, mymuladd_cpu) {
    const auto dtype = torch::kFloat;
    const auto device = torch::kCPU;
    const auto options = torch::dtype(dtype).device(device);
    float data_a[] = {1, 2, 3,
                      4, 5, 6};
    float data_b[] = {1, 2, 3,
                      4, 5, 6};
    const torch::Tensor &a = torch::from_blob(data_a, {2, 3}, options);
    const torch::Tensor &b = torch::from_blob(data_b, {2, 3}, options);
    const double c = 1.0;
    torch::Tensor output = extension_cpp::mymuladd_cpu(a, b, c);

    float data_desired[] = {2, 5, 10,
                            17, 26, 37};
    const torch::Tensor &desired_output = torch::from_blob(data_desired, {2, 3}, options);
    EXPECT_TRUE(torch::allclose(output, desired_output));
  }

} // namespace extension_cpp