# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required (VERSION 3.16)

  set(CMAKE_CXX_STANDARD 23)

project ("2015")
project ("2023")
# Include sub-projects.
#add_subdirectory ("2015")
add_subdirectory("2023")
