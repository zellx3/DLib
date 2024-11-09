include(CMakeFindDependencyMacro)

find_package(OpenCV REQUIRED)
find_package(Boost REQUIRED)  # For dynamic_bitset

include("${CMAKE_CURRENT_LIST_DIR}/DLibTargets.cmake")