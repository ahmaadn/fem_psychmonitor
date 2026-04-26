cmake_minimum_required(VERSION 3.22.1)
project(mfcc_extractor VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ── Release optimizations ─────────────────────────────────────────────────────
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    add_compile_options(-O3 -ffast-math -fno-math-errno)
endif()

add_library(
    mfcc_extractor
    SHARED
    mfcc_extractor.cpp
)

target_include_directories(mfcc_extractor PRIVATE .)

# Link math library (required on Android)
find_library(log-lib log)
target_link_libraries(mfcc_extractor ${log-lib} m)
