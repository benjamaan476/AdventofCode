# CMakeList.txt : CMake project for Chess, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.16)

#find_package(glm CONFIG REQUIRED)
#find_package(glfw3 CONFIG REQUIRED)
#find_package(spdlog REQUIRED)

#include_directories(${GLM_INCLUDE_DIRS})
#include_directories(${GLFW_INCLUDE_DIRS})

add_compile_definitions(_PROJECT_DIR_="${CMAKE_CURRENT_SOURCE_DIR}")

# Add source to this project's executable.
add_executable (3 "main.cpp")

add_custom_command(
    TARGET 3 POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${PROJECT_SOURCE_DIR}/3/in.txt" "${CMAKE_BINARY_DIR}/2015/3/in.txt"
    COMMAND_EXPAND_LISTS
  )

if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET 3 PROPERTY CXX_STANDARD 20)
endif()

target_compile_options(3 PRIVATE
  $<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>
  $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wall -Wextra -Wpedantic -Werror>
)