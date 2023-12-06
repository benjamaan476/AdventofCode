# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required (VERSION 3.16)

project ("1")
project ("2")
project ("3")
project ("4")
project ("5")
# Include sub-projects.
add_subdirectory ("1")
add_subdirectory ("2")
add_subdirectory ("3")
add_subdirectory ("4")
add_subdirectory ("5")
