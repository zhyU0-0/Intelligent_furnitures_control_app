# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(MYcpp)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(OPENCV_LIB_PATH ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH})
link_directories(${OPENCV_LIB_PATH})
#add_subdirectory(aki)

set(CMAKE_BUILD_WITH_INSTALL_RPATH On)

# opencv test, perf_test, examples, docs不需要编译,开启opencl并行运行
set(BUILD_TESTS OFF)
set(BUILD_PERF_TESTS OFF)
set(BUILD_EXAMPLES OFF)
set(BUILD_DOCS OFF)
set(WITH_OPENCL ON)

# 设置编译类型为Release
set(CMAKE_BUILD_TYPE RELEASE)
set(CMAKE_CXX_FLAGS_RELEASE -g0)

# 按需选择要编译的opencv module, 与target_link_libraries中的一致
set(BUILD_LIST core imgproc imgcodecs objdetect)

#add_subdirectory(opencv)

add_library(entry SHARED napi_init.cpp)

#debug日志编译宏
#add_definitions(-DOHOS_OPENCV_SAMPLE_DEBUG)

target_include_directories(entry PUBLIC
    #[[include
    opencv/include
    opencv/includecv4
    opencv/modules/core/include
    opencv/modules/calib3d/include
    opencv/modules/features2d/include
    opencv/modules/dnn/include
    opencv/modules/flann/include
    opencv/modules/highgui/include
    opencv/modules/imgcodecs/include
    opencv/modules/imgproc/include
    opencv/modules/ml/include
    opencv/modules/objdetect/include
    opencv/modules/photo/include
    opencv/modules/stitching/include
    opencv/modules/video/include
    opencv/modules/videoio/include
    opencv/build]])
target_link_libraries(entry PUBLIC
    #[[libace_napi.z.so
    librawfile.z.so
    libhilog_ndk.z.so
    opencv_core
    opencv_imgcodecs
    opencv_imgproc
    opencv_objdetect]])