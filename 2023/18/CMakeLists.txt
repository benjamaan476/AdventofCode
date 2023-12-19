# CMakeList.txt : CMake project for Chess, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.16)

set(PROJECT_NAME 18)

#find_package(glm CONFIG REQUIRED)
#find_package(glfw3 CONFIG REQUIRED)
#find_package(spdlog REQUIRED)

#include_directories(${GLM_INCLUDE_DIRS})
#include_directories(${GLFW_INCLUDE_DIRS})

add_compile_definitions(_PROJECT_DIR_="${CMAKE_CURRENT_SOURCE_DIR}")

# Add source to this project's executable.
add_executable (${PROJECT_NAME} "main.cpp")

configure_file("in.txt.in" "${CMAKE_BINARY_DIR}/2023/${PROJECT_NAME}/in.txt" ESCAPE_QUOTES)

if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 20)
endif()

target_compile_options(${PROJECT_NAME} PRIVATE
  $<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>
  $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wall -Wextra -Wpedantic -Werror>
)
