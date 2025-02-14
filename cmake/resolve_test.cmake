# Resolve test
macro (resolve_test)
    include(FetchContent)
    # declare where to find the GTest dependency
    FetchContent_Declare(GoogleTest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG        v1.15.2
    )
    # bring the GoogleTest dependency into scope
    FetchContent_MakeAvailable(GoogleTest)
    include(GoogleTest)

    include(CTest)
    enable_testing()
endmacro()
