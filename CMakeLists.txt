################################################################################
# Project:  Expat
# Purpose:  CMake build scripts
################################################################################
# Copyright (C) 2018-2021, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)

if(POLICY CMP0077)
    cmake_policy(SET CMP0077 NEW)
endif()

project(expat)

if(NOT DEFINED PACKAGE_VENDOR)
    set(PACKAGE_VENDOR NextGIS)
endif()

if(NOT DEFINED PACKAGE_BUGREPORT)
    set(PACKAGE_BUGREPORT info@nextgis.com)
endif()

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
    set(INSTALL_BIN_DIR "bin" CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR "Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_CMAKECONF_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Resources/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
    set(SKIP_INSTALL_HEADERS ON)
    set(SKIP_INSTALL_FILES ON)
    set(SKIP_INSTALL_EXPORT ON)
    set(SKIP_INSTALL_DOCS ON)
    set(CMAKE_MACOSX_RPATH ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_MAN_DIR ${CMAKE_INSTALL_MANDIR} CACHE INTERNAL "Installation directory for manual pages" FORCE)
    set(INSTALL_PKGCONFIG_DIR "${INSTALL_LIB_DIR}/pkgconfig" CACHE INTERNAL "Installation directory for pkgconfig (.pc) files" FORCE)
    set(INSTALL_CMAKECONF_DIR ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
endif()

if(CMAKE_GENERATOR_TOOLSET MATCHES "v([0-9]+)_xp")
    add_definitions(-D_WIN32_WINNT=0x0501)
endif()

include(util)

check_version(EXPAT_MAJOR_VERSION EXPAT_MINOR_VERSION EXPAT_REV_VERSION)
set(VERSION ${EXPAT_MAJOR_VERSION}.${EXPAT_MINOR_VERSION}.${EXPAT_REV_VERSION})

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${EXPAT_MAJOR_VERSION}")
endif()
report_version(${PROJECT_NAME} ${VERSION})

set(PACKAGE_VERSION ${VERSION})
set(PACKAGE_STRING "${PACKAGE_NAME} ${PACKAGE_VERSION}")
set(PACKAGE_TARNAME "${PACKAGE_NAME}")
set(PACKAGE_NAME ${PROJECT_NAME})

#
# Configuration defaults
#
if(WINCE)
    set(_EXPAT_BUILD_TOOLS_DEFAULT OFF)
else()
    set(_EXPAT_BUILD_TOOLS_DEFAULT ON)
endif()
if(MSVC)
    set(_EXPAT_BUILD_PKGCONFIG_DEFAULT OFF)
else()
    set(_EXPAT_BUILD_PKGCONFIG_DEFAULT ON)
endif()
#
# Configuration
#
option(EXPAT_BUILD_TOOLS "build the xmlwf tool for expat library" ${_EXPAT_BUILD_TOOLS_DEFAULT})
option(EXPAT_BUILD_TESTS "build the tests for expat library" ON)
option(EXPAT_BUILD_PKGCONFIG "build pkg-config file" ${_EXPAT_BUILD_PKGCONFIG_DEFAULT})
if(UNIX OR _EXPAT_HELP)
    option(EXPAT_WITH_LIBBSD "utilize libbsd (for arc4random_buf)" OFF)
endif()
option(EXPAT_ENABLE_INSTALL "install expat files in cmake install target" ON)
set(EXPAT_CONTEXT_BYTES 1024 CACHE STRING "Define to specify how much context to retain around the current parse point")
mark_as_advanced(EXPAT_CONTEXT_BYTES)
option(EXPAT_DTD "Define to make parameter entity parsing functionality available" ON)
mark_as_advanced(EXPAT_DTD)
option(EXPAT_NS "Define to make XML Namespaces functionality available" ON)
mark_as_advanced(EXPAT_NS)
option(EXPAT_WARNINGS_AS_ERRORS "Treat all compiler warnings as errors" OFF)
if(UNIX OR _EXPAT_HELP)
    option(EXPAT_DEV_URANDOM "Define to include code reading entropy from `/dev/urandom'." ON)
    set(EXPAT_WITH_GETRANDOM "AUTO" CACHE STRING
            "Make use of getrandom function (ON|OFF|AUTO) [default=AUTO]")
    set(EXPAT_WITH_SYS_GETRANDOM "AUTO" CACHE STRING
            "Make use of syscall SYS_getrandom (ON|OFF|AUTO) [default=AUTO]")
    mark_as_advanced(EXPAT_DEV_URANDOM)
endif()
set(EXPAT_CHAR_TYPE "char" CACHE STRING "Character type to use (char|ushort|wchar_t) [default=char]")
option(EXPAT_ATTR_INFO "Define to allow retrieving the byte offsets for attribute names and values" OFF)
mark_as_advanced(EXPAT_ATTR_INFO)
option(EXPAT_LARGE_SIZE "Make XML_GetCurrent* functions return <(unsigned) long long> rather than <(unsigned) long>" OFF)
mark_as_advanced(EXPAT_LARGE_SIZE)
option(EXPAT_MIN_SIZE "Get a smaller (but slower) parser (in particular avoid multiple copies of the tokenizer)" OFF)
mark_as_advanced(EXPAT_MIN_SIZE)
if(MSVC OR _EXPAT_HELP)
    set(EXPAT_MSVC_STATIC_CRT OFF CACHE BOOL "Use /MT flag (static CRT) when compiling in MSVC")
endif()

if(EXPAT_BUILD_TESTS)
    # We have to call enable_language() before modifying any CMAKE_CXX_* variables
    enable_language(CXX)
endif()

#
# Environment checks
#
if(EXPAT_WITH_LIBBSD)
    find_library(LIB_BSD NAMES bsd)
    if(NOT LIB_BSD)
        message(SEND_ERROR "EXPAT_WITH_LIBBSD option is enabled, but libbsd was not found")
    else()
        set(HAVE_LIBBSD TRUE)
    endif()
endif()

if(MSVC)
    # For the three types of MSVC version values, please see:
    # - https://cmake.org/cmake/help/latest/variable/MSVC_VERSION.html
    # - https://sourceforge.net/p/predef/wiki/Compilers/
    # - https://en.wikipedia.org/wiki/Microsoft_Visual_Studio#History
    set(_EXPAT_MSVC_REQUIRED_INT 1800)  # i.e. 12.0/2013/1800; see PR #426
    set(_EXPAT_MSVC_SUPPORTED_INT 1910)
    set(_EXPAT_MSVC_SUPPORTED_DISPLAY "Visual Studio 15.0/2017/${_EXPAT_MSVC_SUPPORTED_INT}")

    if(MSVC_VERSION VERSION_LESS ${_EXPAT_MSVC_SUPPORTED_INT})
        if(MSVC_VERSION VERSION_LESS ${_EXPAT_MSVC_REQUIRED_INT})
            message(SEND_ERROR "MSVC_VERSION ${MSVC_VERSION} is TOO OLD to compile Expat without errors.")
            message(SEND_ERROR "Please use officially supported ${_EXPAT_MSVC_SUPPORTED_DISPLAY} or later.  Thank you!")
        else()
            message(WARNING "MSVC_VERSION ${MSVC_VERSION} is NOT OFFICIALLY SUPPORTED by Expat.")
            message(WARNING "Please use ${_EXPAT_MSVC_SUPPORTED_DISPLAY} or later.  Thank you!")
        endif()
    endif()
endif()

macro(_expat_copy_bool_int source_ref dest_ref)
    if(${source_ref})
        set(${dest_ref} 1)
    else()
        set(${dest_ref} 0)
    endif()
endmacro()

if(EXPAT_LARGE_SIZE)
    add_definitions(-DXML_LARGE_SIZE)
endif()

if(EXPAT_MIN_SIZE)
    add_definitions(-DXML_MIN_SIZE)
endif()

if(EXPAT_CHAR_TYPE STREQUAL "char")
    set(_EXPAT_UNICODE OFF)
    set(_EXPAT_UNICODE_WCHAR_T OFF)
elseif(EXPAT_CHAR_TYPE STREQUAL "ushort")
    set(_EXPAT_UNICODE ON)
    set(_EXPAT_UNICODE_WCHAR_T OFF)
    if(EXPAT_BUILD_TESTS)
        message(SEND_ERROR "The testsuite can not be built with option -DEXPAT_CHAR_TYPE=ushort. Please pass -DEXPAT_CHAR_TYPE=(char|wchar_t) or -DEXPAT_BUILD_TESTS=OFF.")
    endif()
    if(EXPAT_BUILD_TOOLS)
        message(SEND_ERROR "The xmlwf tool can not be built with option -DEXPAT_CHAR_TYPE=ushort. Please pass -DEXPAT_CHAR_TYPE=(char|wchar_t) or -DEXPAT_BUILD_TOOLS=OFF.")
    endif()
elseif(EXPAT_CHAR_TYPE STREQUAL "wchar_t")
    set(_EXPAT_UNICODE ON)
    set(_EXPAT_UNICODE_WCHAR_T ON)
    if(NOT WIN32)
        string(FIND "${CMAKE_C_FLAGS}" "-fshort-wchar" _expat_short_wchar_found)
        if(${_expat_short_wchar_found} EQUAL "-1")
            message(SEND_ERROR "Configuration -DEXPAT_CHAR_TYPE=wchar_t requires -DCMAKE_{C,CXX}_FLAGS=-fshort-wchar (which was not found) and libc compiled with -fshort-wchar, too.")
        endif()
        if (EXPAT_BUILD_TOOLS)
            message(SEND_ERROR "The xmlwf tool can not be built with option -DEXPAT_CHAR_TYPE=wchar_t outside of Windows. Please pass -DEXPAT_CHAR_TYPE=char or -DEXPAT_BUILD_TOOLS=OFF.")
        endif()
    endif()
else()
    message(SEND_ERROR "Option -DEXPAT_CHAR_TYPE=(char|ushort|wchar_t) cannot be \"${EXPAT_CHAR_TYPE}\".")
endif()

if(_EXPAT_UNICODE)
    add_definitions(-DXML_UNICODE)              # for unsigned short
    if(_EXPAT_UNICODE_WCHAR_T)
        add_definitions(-DXML_UNICODE_WCHAR_T)  # for wchar_t
    endif()
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/ConfigureChecks.cmake)

macro(evaluate_detection_results use_ref have_ref thing_lower thing_title)
    if(${use_ref} AND NOT (${use_ref} STREQUAL "AUTO") AND NOT ${have_ref})
        message(SEND_ERROR
                "Use of ${thing_lower} was enforced by ${use_ref}=ON but it could not be found.")
    elseif(NOT ${use_ref} AND ${have_ref})
        message("${thing_title} was found but it will not be used due to ${use_ref}=OFF.")
        set(${have_ref} 0)
    endif()
endmacro()

if(NOT WIN32)
    evaluate_detection_results(EXPAT_WITH_GETRANDOM HAVE_GETRANDOM "function getrandom" "Function getrandom")
    evaluate_detection_results(EXPAT_WITH_SYS_GETRANDOM HAVE_SYSCALL_GETRANDOM "syscall SYS_getrandom" "Syscall SYS_getrandom")
endif()

_expat_copy_bool_int(EXPAT_ATTR_INFO        XML_ATTR_INFO)
_expat_copy_bool_int(EXPAT_DTD              XML_DTD)
_expat_copy_bool_int(EXPAT_LARGE_SIZE       XML_LARGE_SIZE)
_expat_copy_bool_int(EXPAT_MIN_SIZE         XML_MIN_SIZE)
_expat_copy_bool_int(EXPAT_NS               XML_NS)
if(NOT WIN32)
    _expat_copy_bool_int(EXPAT_DEV_URANDOM  XML_DEV_URANDOM)
endif()
set(XML_CONTEXT_BYTES ${EXPAT_CONTEXT_BYTES})

configure_file(expat_config.h.cmake "${CMAKE_CURRENT_BINARY_DIR}/expat_config.h")
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL)
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/expat_config.h" DESTINATION ${INSTALL_INC_DIR})
endif()


set(EXTRA_COMPILE_FLAGS)
if(FLAG_NO_STRICT_ALIASING)
    set(EXTRA_COMPILE_FLAGS "${EXTRA_COMPILE_FLAGS} -fno-strict-aliasing")
endif()
if(FLAG_VISIBILITY)
  add_definitions(-DXML_ENABLE_VISIBILITY=1)
  set(EXTRA_COMPILE_FLAGS "${EXTRA_COMPILE_FLAGS} -fvisibility=hidden")
endif()
if(MINGW)
    # Without __USE_MINGW_ANSI_STDIO the compiler produces a false positive
    set(EXTRA_COMPILE_FLAGS "${EXTRA_COMPILE_FLAGS} -Wno-pedantic-ms-format")
endif()
if (EXPAT_WARNINGS_AS_ERRORS)
    if(MSVC)
        add_definitions(/WX)
    else()
        set(EXTRA_COMPILE_FLAGS "${EXTRA_COMPILE_FLAGS} -Werror")
    endif()
endif()
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${EXTRA_COMPILE_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${EXTRA_COMPILE_FLAGS}")

if (MSVC)
    if (EXPAT_MSVC_STATIC_CRT)
        message("-- Using static CRT ${EXPAT_MSVC_STATIC_CRT}")
        foreach(flag_var
                CMAKE_CXX_FLAGS_DEBUG
                CMAKE_CXX_FLAGS_RELEASE
                CMAKE_CXX_FLAGS_MINSIZEREL
                CMAKE_CXX_FLAGS_RELWITHDEBINFO
                CMAKE_C_FLAGS_DEBUG
                CMAKE_C_FLAGS_RELEASE
                CMAKE_C_FLAGS_MINSIZEREL
                CMAKE_C_FLAGS_RELWITHDEBINFO
                )
            string(REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
        endforeach()
    endif()
endif()

include_directories(${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/lib)
if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS -wd4996)
endif()

#
# C library
#
set(expat_SRCS
    lib/xmlparse.c
    lib/xmlrole.c
    lib/xmltok.c
# NOTE: ISO C forbids an empty translation unit
#   lib/xmltok_impl.c
#   lib/xmltok_ns.c
)

set(expat_HEADERS
    lib/expat.h
    lib/expat_external.h
)

if(WIN32 AND BUILD_SHARED_LIBS)
    set(expat_SRCS ${expat_SRCS} lib/libexpat.def)
endif()

set(LIBCURRENT 9)   # sync
set(LIBREVISION 1)  # with
set(LIBAGE 8)       # configure.ac!
math(EXPR LIBCURRENT_MINUS_AGE "${LIBCURRENT} - ${LIBAGE}")

set(LIB_NAME ${PROJECT_NAME})
string(TOUPPER ${PACKAGE_NAME} PACKAGE_UPPER_NAME)

if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${expat_SRCS} ${expat_HEADERS})
    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${LIBCURRENT_MINUS_AGE}.${LIBAGE}.${LIBREVISION}
        SOVERSION ${LIBCURRENT_MINUS_AGE}
    )
    if(MSVC)
        set_target_properties(${LIB_NAME} PROPERTIES IMPORT_SUFFIX "_i.lib")
    endif()
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${expat_SRCS} ${expat_HEADERS})
    set_target_properties(${LIB_NAME} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
      MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
      MACOSX_FRAMEWORK_IDENTIFIER org.expat.libexpat
      XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
      PUBLIC_HEADER "${expat_HEADERS}"
      VERSION ${LIBCURRENT_MINUS_AGE}.${LIBAGE}.${LIBREVISION}
      SOVERSION ${LIBCURRENT_MINUS_AGE}
      )
else()
    add_definitions(-DXML_STATIC)
    add_library(${LIB_NAME} STATIC ${expat_SRCS} ${expat_HEADERS})
endif()

if(EXPAT_WITH_LIBBSD)
    target_link_libraries(${LIB_NAME} ${LIB_BSD})
endif()

target_include_directories(${LIB_NAME}
    INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/lib>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    install(TARGETS ${LIB_NAME}
        EXPORT ${PACKAGE_UPPER_NAME}Targets
        RUNTIME DESTINATION ${INSTALL_BIN_DIR}
        LIBRARY DESTINATION ${INSTALL_LIB_DIR}
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
        INCLUDES DESTINATION ${INSTALL_INC_DIR}
        FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
    )
endif()

if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL)
    install(FILES ${expat_HEADERS} DESTINATION ${INSTALL_INC_DIR})
endif()

#
# pkg-config file
#
if(EXPAT_BUILD_PKGCONFIG)
    configure_file(expat.pc.in ${CMAKE_CURRENT_BINARY_DIR}/expat.pc @ONLY)

    if(NOT SKIP_INSTALL_FILES AND NOT SKIP_INSTALL_ALL)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/expat.pc DESTINATION ${INSTALL_PKGCONFIG_DIR})
    endif()
endif()

#
# C command line tool xmlwf
#
if(EXPAT_BUILD_TOOLS)
    set(xmlwf_SRCS
        xmlwf/xmlwf.c
        xmlwf/xmlfile.c
        xmlwf/codepage.c
        xmlwf/readfilemap.c
    )

    add_executable(xmlwf ${xmlwf_SRCS})
    set_property(TARGET xmlwf PROPERTY RUNTIME_OUTPUT_DIRECTORY xmlwf)
    target_link_libraries(xmlwf expat)

    if(OSX_FRAMEWORK)
        set_target_properties(xmlwf PROPERTIES INSTALL_RPATH "@executable_path/../../Library/Frameworks")
    endif()

    if(NOT SKIP_INSTALL_EXECUTABLES AND NOT SKIP_INSTALL_ALL)
        install(TARGETS xmlwf DESTINATION ${INSTALL_BIN_DIR} COMPONENT applications)
    endif()
endif()

#
# C/C++ test runners
#
if(EXPAT_BUILD_TESTS)
    ## these are unittests that can be run on any platform
    enable_testing()

    set(test_SRCS
        tests/chardata.c
        tests/memcheck.c
        tests/minicheck.c
        tests/structdata.c
        ${expat_SRCS}
    )

    if(NOT MSVC)
        if(MINGW)
            set(host whatever-mingw32)  # for nothing but run.sh
        endif()
        configure_file(${CMAKE_CURRENT_SOURCE_DIR}/run.sh.in run.sh @ONLY)
    endif()

    add_executable(runtests tests/runtests.c ${test_SRCS})
    set_property(TARGET runtests PROPERTY RUNTIME_OUTPUT_DIRECTORY tests)
    add_test(runtests $<TARGET_FILE:runtests>)

    add_executable(runtestspp tests/runtestspp.cpp ${test_SRCS})
    set_property(TARGET runtestspp PROPERTY RUNTIME_OUTPUT_DIRECTORY tests)
    add_test(runtestspp $<TARGET_FILE:runtestspp>)

    if(EXPAT_WITH_LIBBSD)
        target_link_libraries(runtests ${LIB_BSD})
        target_link_libraries(runtestspp ${LIB_BSD})
    endif()
endif()

# uninstall
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

# Export package ===============================================================

# Add path to includes to build-tree export
target_include_directories(${LIB_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/lib>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)

# Add all targets to the build-tree export set
export(TARGETS ${LIB_NAME}
    FILE ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Targets.cmake)

if(REGISTER_PACKAGE)
    # Export the package for use from the build-tree
    # (this registers the build-tree with a global CMake-registry)
    export(PACKAGE ${PACKAGE_UPPER_NAME})
endif()

# Create the <Package>Config.cmake file
configure_file(cmake/PackageConfig.cmake.in
    ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake @ONLY)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    # Install the <Package>Config.cmake
    install(FILES
      ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake
      DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)

    # Install the export set for use with the install-tree
    install(EXPORT ${PACKAGE_UPPER_NAME}Targets DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)
endif()

# Archiving ====================================================================

set(CPACK_PACKAGE_NAME "${PACKAGE_NAME}")
set(CPACK_PACKAGE_VENDOR "${PACKAGE_VENDOR}")
set(CPACK_PACKAGE_VERSION "${VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PACKAGE_NAME} Installation")
set(CPACK_PACKAGE_RELOCATABLE TRUE)
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_GENERATOR "ZIP")
set(CPACK_MONOLITHIC_INSTALL ON)
set(CPACK_STRIP_FILES TRUE)

# Get cpack zip archive name
get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_CPACK_FILENAME})

include(CPack)