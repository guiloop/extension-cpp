
# # enable FetchContent
# include(FetchContent)

# # declare where to find the dependency
# FetchContent_Declare(GoogleTest
#   GIT_REPOSITORY https://github.com/google/googletest.git
#   GIT_TAG        release-1.11.0
#   )

# # bring the dependency into scope
# FetchContent_MakeAvailable(GoogleTest)

# build and link the unit_tests executable
add_executable(unit_tests)
target_sources(
  unit_tests
  PRIVATE
    calculator.cpp
    driver.cpp
  )
target_link_libraries(
  unit_tests
  PRIVATE
    calculator
    gtest_main  # this target is not here, we fetch it from the web (above)
  )

# define tests
add_test(
  NAME adding
  COMMAND $<TARGET_FILE:unit_tests> --gtest_filter=cal.add_
  )
add_test(
  NAME subtracting
  COMMAND $<TARGET_FILE:unit_tests> --gtest_filter=calculator.subtract
  )
