cmake_minimum_required(VERSION 3.0)
project(mnn-llm)

option(BUILD_FOR_ANDROID "Build for android whith mini memory mode." OFF)
option(WITH_CUDA "Enable CUDA support" OFF)

# include dir
include_directories(${CMAKE_CURRENT_LIST_DIR}/include/)

# libs dir
link_directories(${CMAKE_CURRENT_LIST_DIR}/libs)

# source files
FILE(GLOB SRCS ${CMAKE_CURRENT_LIST_DIR}/src/*.cpp)

if (MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17")
    # compile static lib, surrpot Winwows
    add_library(llm STATIC ${SRCS})
    target_link_libraries(llm MNN.lib)
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
    # compile dynamic so, support Linux/Mac
    add_library(llm SHARED ${SRCS})
    set_target_properties(llm PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS TRUE)

    target_link_libraries(llm MNN MNN_Express)
endif()
# target_link_libraries(llm MNN MNN_Express MNN_CL) # if using OPENCL

if (BUILD_FOR_ANDROID)
    add_library(MNN SHARED IMPORTED)
    add_library(MNN_Express SHARED IMPORTED)
    set_target_properties(
        MNN
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_CURRENT_LIST_DIR}/libs/libMNN.so
        )
    set_target_properties(
        MNN_Express
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_CURRENT_LIST_DIR}/libs/libMNN_Express.so
        )
    # just cli demo
    add_executable(cli_demo ${CMAKE_CURRENT_LIST_DIR}/demo/cli_demo.cpp)
    target_link_libraries(cli_demo llm log)
else()
    # cli demo
    if(WITH_CUDA)
        message("CUDA support enabled for cli demo")
        find_package(CUDA REQUIRED)
        include_directories(${CUDA_INCLUDE_DIRS})
        add_definitions(-DWITH_CUDA)
        add_executable(cli_demo ${CMAKE_CURRENT_LIST_DIR}/demo/cli_demo.cpp)
        target_link_libraries(cli_demo llm ${CUDA_LIBRARIES})
    else()
        message("CUDA support disabled for cli demo")
        add_executable(cli_demo ${CMAKE_CURRENT_LIST_DIR}/demo/cli_demo.cpp)
        if (MSVC)
            target_link_libraries(cli_demo llm)
            # copy all lib to target dir
            file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/libs/ DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/Debug/)
        else()
            target_link_libraries(cli_demo llm)
        endif()
    endif()
    # web demo
    if (WITH_CUDA)
        message("CUDA support enabled for web demo")
        find_package(CUDA REQUIRED)
        include_directories(${CUDA_INCLUDE_DIRS})
        add_definitions(-DWITH_CUDA)
        add_executable(web_demo ${CMAKE_CURRENT_LIST_DIR}/demo/web_demo.cpp)
        target_link_libraries(web_demo llm ${CUDA_LIBRARIES})
    else()
        message("CUDA support disabled for web demo")
        add_executable(web_demo ${CMAKE_CURRENT_LIST_DIR}/demo/web_demo.cpp)
        if (MSVC)
            target_link_libraries(web_demo llm pthreadVC2)
            # copy all lib to target dir
            file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/libs/ DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/Debug/)
        else()
            target_link_libraries(web_demo llm pthread)
        endif()
    endif()
endif()
