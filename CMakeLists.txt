#
# MIT License
#
#Copyright (c) 2026 BartekDeveloper<github.com/BartekDeveloper>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

cmake_minimum_required(VERSION 3.25)

set(DISABLE_RECOMMENDED_COMPILER OFF CACHE BOOL "Disable automatic selection of the recommended compiler when available")

if(NOT DISABLE_RECOMMENDED_COMPILER)
    set(FOUND_user_selected_compiler OFF)

    if(DEFINED CMAKE_CXX_COMPILER OR DEFINED CMAKE_C_COMPILER)
        set(FOUND_user_selected_compiler ON)
    elseif(DEFINED ENV{CXX} OR DEFINED ENV{CC})
        set(FOUND_user_selected_compiler ON)
    endif()

    if(NOT FOUND_user_selected_compiler)
        find_program(FOUND_CLANGXX_PROGRAM NAMES clang++)
        find_program(FOUND_CLANG_PROGRAM NAMES clang)

        if(FOUND_CLANGXX_PROGRAM AND FOUND_CLANG_PROGRAM)
            set(CMAKE_CXX_COMPILER "${FOUND_CLANGXX_PROGRAM}" CACHE FILEPATH "Recommended C++ compiler" FORCE)
            set(CMAKE_C_COMPILER "${FOUND_CLANG_PROGRAM}" CACHE FILEPATH "Recommended C compiler" FORCE)
            message(STATUS "Using recommended compiler toolchain: Clang (${FOUND_CLANG_PROGRAM}, ${FOUND_CLANGXX_PROGRAM})")
        endif()
    endif()
endif()

# --------------------
#  1. Common Settings
# --------------------
project(MyLib
    VERSION 1.0.0 
    LANGUAGES CXX C
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${OUTPUTCONFIG} CONFIG)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG} ${CMAKE_BINARY_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CONFIG} ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CONFIG} ${CMAKE_BINARY_DIR}/lib)
endforeach()

set(FETCHCONTENT_BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vendor" CACHE PATH "Directory for FetchContent dependencies")
set(FOUND_cmake_package_dir "${CMAKE_INSTALL_LIBDIR}/cmake/MyLib")

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(ENABLE_CLANG_TIDY "Run clang-tidy during builds when available" OFF)
option(ENABLE_FETCHCONTENT_FALLBACK "Allow FetchContent fallback when packaged dependencies are unavailable" ON)

if(DISABLE_RECOMMENDED_COMPILER)
    message(STATUS "Recommended compiler auto-selection is disabled")
elseif(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message(STATUS "Note: Build is using ${CMAKE_CXX_COMPILER_ID}; pass -DDISABLE_RECOMMENDED_COMPILER=ON to silence Clang preference")
endif()

find_program(CLANG_FORMAT_PROGRAM NAMES clang-format)
find_program(CLANG_TIDY_PROGRAM NAMES clang-tidy)

set(PROJECT_FORMAT_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/interface.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/lib.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/testapp/testapp.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/tests.cpp
)

set(PROJECT_PUBLIC_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/interface.hpp
)

file(GLOB_RECURSE PROJECT_INTERFACE_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/interfaces/*.h
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/interfaces/*.hh
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/interfaces/*.hpp
)

list(APPEND PROJECT_PUBLIC_HEADERS ${PROJECT_INTERFACE_HEADERS})

if(CLANG_FORMAT_PROGRAM)
    add_custom_target(format
        COMMAND ${CLANG_FORMAT_PROGRAM} -i ${PROJECT_FORMAT_SOURCES}
        COMMENT "Formatting project sources with clang-format"
        VERBATIM
    )

    add_custom_target(format-check
        COMMAND ${CLANG_FORMAT_PROGRAM} --dry-run --Werror ${PROJECT_FORMAT_SOURCES}
        COMMENT "Checking project formatting with clang-format"
        VERBATIM
    )
else()
    message(STATUS "clang-format not found; 'format' and 'format-check' targets disabled")
endif()

find_package(Doxygen QUIET)

if(ENABLE_CLANG_TIDY)
    if(CLANG_TIDY_PROGRAM)
        set(CMAKE_CXX_CLANG_TIDY
            ${CLANG_TIDY_PROGRAM};--config-file=${CMAKE_CURRENT_SOURCE_DIR}/.clang-tidy
        )
    else()
        message(FATAL_ERROR "ENABLE_CLANG_TIDY is ON, but clang-tidy was not found")
    endif()
elseif(NOT CLANG_TIDY_PROGRAM)
    message(STATUS "clang-tidy not found; 'tidy' target disabled")
endif()

# ------------------------
#  2. Build Optimizations
# ------------------------
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_C_COMPILER_LAUNCHER   "${CCACHE_PROGRAM}")
    message(STATUS "ccache enabled: ${CCACHE_PROGRAM}")
endif()

find_program(MOLD_PROGRAM mold)
find_program(GOLD_PROGRAM gold)
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    if(MOLD_PROGRAM)
        if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.29")
            set(CMAKE_LINKER_TYPE MOLD)
        else()
            add_link_options("-fuse-ld=mold")
        endif()
        message(STATUS "mold linker enabled: ${MOLD_PROGRAM}")
    elseif(GOLD_PROGRAM)
        add_link_options("-fuse-ld=gold")
        message(STATUS "gold linker enabled: ${GOLD_PROGRAM}")
    else()
        message(STATUS "No optional linker found; using default linker")
    endif()
endif()

option(ENABLE_CUSTOM_ALLOCATOR "Enable better memory allocator (jemalloc; mimalloc)" ON)

set(ALLOCATOR_LIBRARIES "")
set(ALLOCATOR_COMPILE_DEFINITIONS "")

if(ENABLE_CUSTOM_ALLOCATOR)
    find_package(PkgConfig QUIET)
    
    if(PkgConfig_FOUND)
        pkg_check_modules(JEMALLOC QUIET jemalloc)
    endif()

    if(JEMALLOC_FOUND)
        set(ALLOCATOR_LIBRARIES ${JEMALLOC_LIBRARIES})
        list(APPEND ALLOCATOR_COMPILE_DEFINITIONS "USE_JEMALLOC_OVERRIDE")
        message(STATUS "Memory Allocator: jemalloc (pkg-config)")
    else()
        
        find_library(JEMALLOC_LIBRARY NAMES jemalloc)
        if(JEMALLOC_LIBRARY)
            set(ALLOCATOR_LIBRARIES ${JEMALLOC_LIBRARY})
            list(APPEND ALLOCATOR_COMPILE_DEFINITIONS "USE_JEMALLOC_OVERRIDE")
            message(STATUS "Memory Allocator: jemalloc (${JEMALLOC_LIBRARY})")
        else()
            set(MI_OVERRIDE ON CACHE BOOL "Override standard malloc with mimalloc" FORCE)
            
            find_package(mimalloc QUIET)
            if(mimalloc_FOUND)
                if(TARGET mimalloc)
                    set(ALLOCATOR_LIBRARIES mimalloc)
                elseif(TARGET mimalloc-static)
                    set(ALLOCATOR_LIBRARIES mimalloc-static)
                else()
                    set(ALLOCATOR_LIBRARIES ${mimalloc_LIBRARIES})
                endif()
                
                list(APPEND ALLOCATOR_COMPILE_DEFINITIONS "MI_OVERRIDE=1" "USE_MIMALLOC_OVERRIDE")
                message(STATUS "Memory Allocator: mimalloc (via CMake package, MI_OVERRIDE=ON)")
            else()

                find_library(MIMALLOC_LIBRARY NAMES mimalloc mimalloc-static)
                if(MIMALLOC_LIBRARY)
                    set(ALLOCATOR_LIBRARIES ${MIMALLOC_LIBRARY})
                    list(APPEND ALLOCATOR_COMPILE_DEFINITIONS "MI_OVERRIDE=1" "USE_MIMALLOC_OVERRIDE")
                    message(STATUS "Memory Allocator: mimalloc (${MIMALLOC_LIBRARY}, MI_OVERRIDE=ON)")
                else()
                    message(STATUS "Memory Allocator: None found. Falling back to system default allocator.")

                endif()
            endif()
        endif()
    endif()
endif()

# -------------------
#  3. Build Settings
# -------------------
function(apply_FOUND_warnings target_name)
    target_compile_options(${target_name} PRIVATE
        $<$<CXX_COMPILER_ID:Clang,GNU>:-Wall -Wextra -Wpedantic -Wconversion>
        $<$<CXX_COMPILER_ID:MSVC>:/W4 /permissive- /EHsc>
    )
endfunction()

file(GLOB_RECURSE LIB_SOURCES lib/*.cpp)

add_library(MyLib STATIC ${LIB_SOURCES})
add_library(MyLib::MyLib ALIAS MyLib)

target_sources(MyLib PUBLIC
    FILE_SET HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/lib
    FILES ${PROJECT_PUBLIC_HEADERS}
)

target_include_directories(MyLib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/lib>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if(ALLOCATOR_LIBRARIES)
    target_link_libraries(MyLib PRIVATE ${ALLOCATOR_LIBRARIES})
    target_compile_definitions(MyLib PRIVATE ${ALLOCATOR_COMPILE_DEFINITIONS})
endif()

apply_FOUND_warnings(MyLib)
set_target_properties(MyLib PROPERTIES
    EXPORT_NAME MyLib
    OUTPUT_NAME MyLib
)

install(TARGETS MyLib EXPORT MyLibTargets
    FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.md
    ${CMAKE_CURRENT_SOURCE_DIR}/README.md
    DESTINATION ${CMAKE_INSTALL_DATADIR}/MyLib
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/MyLibConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    INSTALL_DESTINATION ${FOUND_cmake_package_dir}
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(EXPORT MyLibTargets
    FILE MyLibTargets.cmake
    NAMESPACE MyLib::
    DESTINATION ${FOUND_cmake_package_dir}
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake
    DESTINATION ${FOUND_cmake_package_dir}
)

# ----------------------
#  4. Executables
# ----------------------
add_executable(TestApp_MyLib 
    testapp/testapp.cpp
)

target_link_libraries(TestApp_MyLib PRIVATE MyLib)
apply_FOUND_warnings(TestApp_MyLib)

if(ALLOCATOR_LIBRARIES)
    target_link_libraries(TestApp_MyLib PRIVATE ${ALLOCATOR_LIBRARIES})
    target_compile_definitions(TestApp_MyLib PRIVATE ${ALLOCATOR_COMPILE_DEFINITIONS})
endif()

set_target_properties(TestApp_MyLib PROPERTIES OUTPUT_NAME "MyLib TestApp")

# ----------------------
#  5. Testing Framework
# ----------------------
option(BUILD_TESTING "Build the unit tests" ON)

if(BUILD_TESTING)
    enable_testing()

    find_package(GTest CONFIG QUIET)

    if(NOT GTest_FOUND AND ENABLE_FETCHCONTENT_FALLBACK)
        include(FetchContent)

        FetchContent_Declare(
            googletest
            GIT_REPOSITORY https://github.com/google/googletest.git
            GIT_TAG 58d77fa8070e8cec2dc1ed015d66b454c8d78850
        )
        set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
        FetchContent_MakeAvailable(googletest)
    elseif(NOT GTest_FOUND)
        message(FATAL_ERROR "GTest was not found. Enable vcpkg or turn on ENABLE_FETCHCONTENT_FALLBACK.")
    endif()

    add_executable(MyLib_tests 
        tests/tests.cpp
    )

    target_link_libraries(MyLib_tests PRIVATE 
        MyLib
        GTest::gtest_main
    )
    apply_FOUND_warnings(MyLib_tests)

    include(GoogleTest)
    gtest_discover_tests(MyLib_tests)
endif()

if(Doxygen_FOUND)
    set(DOXYGEN_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/docs)
    file(MAKE_DIRECTORY ${DOXYGEN_OUTPUT_DIRECTORY})
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)

    add_custom_target(docs
        COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Generating API documentation with Doxygen"
        VERBATIM
    )
else()
    message(STATUS "Doxygen not found; 'docs' target disabled")
endif()

if(CLANG_TIDY_PROGRAM)
    add_custom_target(tidy
        COMMAND ${CLANG_TIDY_PROGRAM}
                -p ${CMAKE_BINARY_DIR}
                --config-file=${CMAKE_CURRENT_SOURCE_DIR}/.clang-tidy
                ${PROJECT_FORMAT_SOURCES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running clang-tidy on project sources"
        VERBATIM
    )
endif()

set(CPACK_PACKAGE_NAME "MyLib")
set(CPACK_PACKAGE_VENDOR "BartekDeveloper")
set(CPACK_PACKAGE_CONTACT "BartekDeveloper")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "MyLib C++ project template with CMake, tests, docs, and CI")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_INSTALL_DIRECTORY "MyLib")
set(CPACK_PACKAGE_FILE_NAME "MyLib-${PROJECT_VERSION}-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
set(CPACK_PACKAGE_CHECKSUM SHA256)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.md")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_NUGET_PACKAGE_NAME "MyLib")
set(CPACK_NUGET_PACKAGE_AUTHORS "BartekDeveloper")
set(CPACK_NUGET_PACKAGE_DESCRIPTION "MyLib C++ project template with CMake, tests, docs, and CI")
set(CPACK_NUGET_PACKAGE_LICENSE_EXPRESSION "MIT")
set(CPACK_NUGET_PACKAGE_TITLE "MyLib")
set(CPACK_NUGET_PACKAGE_TAGS "native cplusplus cmake MyLib")
set(CPACK_NUGET_PACKAGE_REPOSITORY_TYPE "git")
set(CPACK_NUGET_PACKAGE_TFMS "native")

include(CPack)
