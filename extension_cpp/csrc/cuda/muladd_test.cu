#include <iostream>
#include <gtest/gtest.h>

#include <torch/torch.h>
#include <torch/types.h>

#include "muladd.cuh"

namespace extension_cpp {

TEST(MulAddTest, mymuladd_cuda) {
    const auto dtype = torch::kFloat;
    const auto device = torch::kCUDA;
    const auto options = torch::dtype(dtype).device(device);
    const torch::Tensor& a = torch::ones({2, 3}, options);
    const torch::Tensor& b = torch::ones({2, 3}, options);
    const double c = 1.0;
    torch::Tensor output = extension_cpp::mymuladd_cuda(a, b, c);
    
    const torch::Tensor& desired_output = torch::full({2, 3}, 2, options);
    
    EXPECT_TRUE(torch::allclose(output, desired_output));

    std::cout << "a: " << a << std::endl;
    std::cout << "b: " << b << std::endl;
    std::cout << "c: " << c << std::endl;
    std::cout << "output: " << output << std::endl;
    std::cout << "desired_output: " << desired_output << std::endl;
}

} // namespace extension_cpp