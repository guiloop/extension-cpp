#
# Run `EXPR` in python.  The standard output of python is stored in `OUT` and
# has trailing whitespace stripped.  If an error is encountered when running
# python, a fatal message `ERR_MSG` is issued.
#
# Example:
# run_python(TORCH_PREFIX_PATH
#     "import torch; print(torch.utils.cmake_prefix_path)"
#     ERR_MSG "Not found torch"
#     ERR_STS FALTAL_ERROR
# )
function (run_python OUT EXPR)
  cmake_parse_arguments(
      PARSE_ARGV 1 PYTHON "" "ERR_MSG;ERR_STS" "")
  execute_process(
    COMMAND
    "${Python_EXECUTABLE}" "-c" "${EXPR}"
    OUTPUT_VARIABLE PYTHON_OUT
    RESULT_VARIABLE PYTHON_ERROR_CODE
    ERROR_VARIABLE PYTHON_STDERR
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  if (DEFINED PYTHON_ERR_MSG)
    if(NOT PYTHON_ERROR_CODE EQUAL 0)
      if (NOT DEFINED PYTHON_ERR_STS)
        set(${PYTHON_ERR_STS} FATAL_ERROR)
      endif()
      message(${PYTHON_ERR_STS} "${PYTHON_ERR_MSG}: ${PYTHON_STDERR}")
    endif()
  endif()
  set(${OUT} ${PYTHON_OUT} PARENT_SCOPE)
endfunction()
