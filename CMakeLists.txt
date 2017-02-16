# This file is copyrighted under the BSD-license for buildsystem files of KDE
# copyright 2010, Patrick Spendrin <ps_ml@gmx.de>

cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)

project(expat)

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
  set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE INTERNAL "Installation directory for executables" FORCE)
  set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
  set(INSTALL_INC_DIR "${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers" CACHE INTERNAL "Installation directory for headers" FORCE)
  set(SKIP_INSTALL_HEADERS ON)
  set(SKIP_INSTALL_FILES ON)
  set(SKIP_INSTALL_EXPORT ON)
  set(SKIP_INSTALL_DOCS ON)
  set(CMAKE_MACOSX_RPATH ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_FULL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_FULL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_FULL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_MAN_DIR ${CMAKE_INSTALL_FULL_MANDIR} CACHE INTERNAL "Installation directory for manual pages" FORCE)
    set(INSTALL_PKGCONFIG_DIR "${INSTALL_LIB_DIR}/pkgconfig" CACHE INTERNAL "Installation directory for pkgconfig (.pc) files" FORCE)
endif()

if(CMAKE_GENERATOR_TOOLSET MATCHES "v([0-9]+)_xp")
    add_definitions(-D_WIN32_WINNT=0x0501)
endif()

# setup package meta-data
include(util)

check_version(EXPAT_MAJOR_VERSION EXPAT_MINOR_VERSION EXPAT_REV_VERSION)
set(VERSION ${EXPAT_MAJOR_VERSION}.${EXPAT_MINOR_VERSION}.${EXPAT_REV_VERSION})

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${EXPAT_MAJOR_VERSION}")
endif()
report_version(${PROJECT_NAME} ${VERSION})


set(PACKAGE_BUGREPORT "expat-bugs@libexpat.org")
set(PACKAGE_NAME "expat")
set(PACKAGE_VERSION ${VERSION})
set(PACKAGE_STRING "${PACKAGE_NAME} ${PACKAGE_VERSION}")
set(PACKAGE_TARNAME "${PACKAGE_NAME}")

# configuration options
set(XML_CONTEXT_BYTES 1024 CACHE STRING "Define to specify how much context to retain around the current parse point")
option(XML_DTD "Define to make parameter entity parsing functionality available" ON)
option(XML_NS "Define to make XML Namespaces functionality available" ON)

if(XML_DTD)
    set(XML_DTD 1)
else()
    set(XML_DTD 0)
endif()
if(XML_NS)
    set(XML_NS 1)
else()
    set(XML_NS 0)
endif()

include(ConfigureChecks)

include_directories(${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR}/lib)
if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS -wd4996 -DXML_BUILDING_EXPAT)
endif()

set(expat_SRCS
    lib/xmlparse.c
    lib/xmlrole.c
    lib/xmltok.c
    lib/xmltok_impl.c
    lib/xmltok_ns.c
)

set(expat_HEADERS
    lib/expat.h
    lib/expat_external.h
)

if(WIN32 AND BUILD_SHARED_LIBS)
    set(expat_SRCS ${expat_SRCS} lib/libexpat.def)
endif()

set(LIBCURRENT 7)   # sync
set(LIBREVISION 2)  # with
set(LIBAGE 6)       # configure.ac!
math(EXPR LIBCURRENT_MINUS_AGE "${LIBCURRENT} - ${LIBAGE}")

set(LIB_NAME ${PROJECT_NAME})
if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${expat_SRCS} ${expat_HEADERS})
    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${LIBCURRENT_MINUS_AGE}.${LIBAGE}.${LIBREVISION}
        SOVERSION SOVERSION ${LIBCURRENT_MINUS_AGE}
        NO_SONAME ${NO_SONAME})
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
      SOVERSION SOVERSION ${LIBCURRENT_MINUS_AGE}
      NO_SONAME ${NO_SONAME}
      )
else()
    add_library(${LIB_NAME} STATIC ${expat_SRCS} ${expat_HEADERS})
    if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
        set( CMAKE_CXX_FLAGS "-fpic ${CMAKE_CXX_FLAGS}" )
        set( CMAKE_C_FLAGS   "-fpic ${CMAKE_C_FLAGS}" )
    endif()
endif()

if (REGISTER_PACKAGE)
    export(TARGETS ${LIB_NAME} FILE ${LIB_NAME}-exports.cmake)

    set(EXPORT_PACKAGE_NAME EXPAT)
    string(TOUPPER ${EXPORT_PACKAGE_NAME} EXPORT_PACKAGE_NAME_UPPER)
    set(EXPORT_PACKAGE_LIB_NAME ${LIB_NAME})

    export(PACKAGE ${EXPORT_PACKAGE_NAME})

    include(CMakePackageConfigHelpers)
    configure_package_config_file(
        ${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}Config.cmake
        INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR} )
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${EXPORT_PACKAGE_NAME}ConfigVersion.cmake
        VERSION ${VERSION}
        COMPATIBILITY AnyNewerVersion )
else()
    export(TARGETS ${LIB_NAME} FILE ${LIB_NAME}-exports.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
endif()

install(TARGETS ${LIB_NAME}
    RUNTIME DESTINATION ${INSTALL_BIN_DIR} COMPONENT applications
    LIBRARY DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
    ARCHIVE DESTINATION ${INSTALL_LIB_DIR} COMPONENT libraries
    FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
)

set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix "\${prefix}/bin")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
configure_file(expat.pc.in ${CMAKE_CURRENT_BINARY_DIR}/expat.pc)

if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL)
    install(FILES ${expat_HEADERS} DESTINATION ${INSTALL_INC_DIR})
endif()

if(NOT SKIP_INSTALL_FILES AND NOT SKIP_INSTALL_ALL)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/expat.pc DESTINATION ${INSTALL_PKGCONFIG_DIR})
endif()

if(BUILD_tools)
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
    if(NOT SKIP_INSTALL_DOCS AND NOT SKIP_INSTALL_ALL)
        install(FILES doc/xmlwf.1 DESTINATION ${INSTALL_MAN_DIR}/man1)
    endif()
endif()

# uninstall
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
