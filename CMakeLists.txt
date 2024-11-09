cmake_minimum_required(VERSION 3.20)
project(DLib VERSION 1.0)

option(BUILD_DUtils   "Build DUtils (basic c++ functions)." ON)
option(BUILD_DUtilsCV "Build DUtilsCV (OpenCV functions, requires DUtils)." ON)
option(BUILD_DVision  "Build DVision (computer vision functions, requires DUtilsCV)." ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
    "MinSizeRel" "RelWithDebInfo")
endif()

if(MSVC)
  add_compile_options(/W4)
else()
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

if(BUILD_DUtils)
  set(HDRS include/DUtils/
    include/DUtils/BinaryFile.h      include/DUtils/DUtils.h          include/DUtils/FileModes.h       include/DUtils/Math.hpp          
    include/DUtils/STL.h             include/DUtils/Timestamp.h
    include/DUtils/ConfigFile.h      include/DUtils/DebugFunctions.h  include/DUtils/LUT.h             include/DUtils/Profiler.h        
    include/DUtils/StringFunctions.h include/DUtils/dirent_win.h
    include/DUtils/DException.h      include/DUtils/FileFunctions.h   include/DUtils/LineFile.h        include/DUtils/Random.h          
    include/DUtils/TimeManager.h)
  set(SRCS 
    src/DUtils/BinaryFile.cpp      src/DUtils/DebugFunctions.cpp  src/DUtils/LUT.cpp             src/DUtils/Profiler.cpp        
    src/DUtils/StringFunctions.cpp src/DUtils/Timestamp.cpp
    src/DUtils/ConfigFile.cpp      src/DUtils/FileFunctions.cpp   src/DUtils/LineFile.cpp        src/DUtils/Random.cpp          
    src/DUtils/TimeManager.cpp)
endif(BUILD_DUtils)

if(BUILD_DUtilsCV)  
  set(HDRS 
    include/DUtilsCV/CvVersion.h       include/DUtilsCV/Drawing.h         include/DUtilsCV/Geometry.h        include/DUtilsCV/Mat.h             
    include/DUtilsCV/Types.h
    include/DUtilsCV/DUtilsCV.h        include/DUtilsCV/GUI.h             include/DUtilsCV/IO.h              include/DUtilsCV/Transformations.h
    ${HRDS})
  set(SRCS 
    src/DUtilsCV/Drawing.cpp         src/DUtilsCV/Geometry.cpp        src/DUtilsCV/Mat.cpp             src/DUtilsCV/Types.cpp
    src/DUtilsCV/GUI.cpp             src/DUtilsCV/IO.cpp              src/DUtilsCV/Transformations.cpp
    ${SRCS})
endif(BUILD_DUtilsCV)

if(BUILD_DVision)
  set(HDRS
    include/DVision/DVision.h        include/DVision/HSolver.h        include/DVision/Matches.h
    include/DVision/PMVSCamera.h     include/DVision/PixelPointFile.h
    include/DVision/BundleCamera.h   include/DVision/FSolver.h        include/DVision/ImageFunctions.h include/DVision/PLYFile.h        
    include/DVision/PatchFile.h      include/DVision/BRIEF256.h
    ${HDRS})
  set(SRCS
    src/DVision/FSolver.cpp        src/DVision/ImageFunctions.cpp src/DVision/PLYFile.cpp
    src/DVision/PatchFile.cpp
    src/DVision/BundleCamera.cpp   src/DVision/HSolver.cpp        src/DVision/Matches.cpp        src/DVision/PMVSCamera.cpp     
    src/DVision/PixelPointFile.cpp
    ${SRCS})

  find_package(Boost QUIET)  # For dynamic_bitset
  if (Boost_FOUND)
    set(HDRS include/DVision/BRIEF.h ${HDRS})
    set(SRCS src/DVision/BRIEF.cpp ${SRCS})
  else()
    message(WARNING "Boost not found. BRIEF class wit dynamic bitset length will not be built. You can use BRIEF256 class with fixed bitset length.")
  endif(Boost_FOUND)
endif(BUILD_DVision)

if(BUILD_DUtilsCV OR BUILD_DVision)
  find_package(OpenCV REQUIRED)
endif(BUILD_DUtilsCV OR BUILD_DVision)

set(LIB_SHARED "SHARED")
if(WIN32)
  set(LIB_SHARED "STATIC")
endif(WIN32)

add_library(${PROJECT_NAME}
    ${LIB_SHARED}
    ${SRCS})

target_link_libraries(${PROJECT_NAME}
    PUBLIC
      ${OpenCV_LIBS})

target_include_directories(${PROJECT_NAME}
    PUBLIC
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Additional individual includes
target_include_directories(${PROJECT_NAME}
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/DUtils>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/DUtilsCV>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/DVision>
)

set_target_properties(${PROJECT_NAME}
    PROPERTIES
      CXX_STANDARD 11)

if (Boost_FOUND)
  target_link_libraries(${PROJECT_NAME}
      PUBLIC
      ${Boost_LIBRARIES})

  target_include_directories(${PROJECT_NAME}
      PUBLIC
      ${Boost_INCLUDE_DIRS})
endif()

include(GNUInstallDirs)

export(TARGETS ${PROJECT_NAME} FILE "${PROJECT_NAME}Targets.cmake")

install(TARGETS ${PROJECT_NAME}
    EXPORT "${PROJECT_NAME}Targets"
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY "include/" DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(EXPORT "${PROJECT_NAME}Targets"
    FILE "${PROJECT_NAME}Targets.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

install(FILES "cmake/${PROJECT_NAME}Config.cmake" "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)
