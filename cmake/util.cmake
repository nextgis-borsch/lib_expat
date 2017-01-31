################################################################################
# Project:  CMake4GDAL
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
# Copyright (C) 2012,2013,2014 Dmitry Baryshnikov
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


function(check_version major minor rev)

    # parse the version number from expat.h and include in
    # major, minor and rev parameters

    file(READ ${CMAKE_CURRENT_SOURCE_DIR}/lib/expat.h _VERSION_H_CONTENTS)

    string(REGEX MATCH "XML_MAJOR_VERSION[ \t]+([0-9]+)"
      XML_MAJOR_VERSION ${_VERSION_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
      XML_MAJOR_VERSION ${XML_MAJOR_VERSION})
    string(REGEX MATCH "XML_MINOR_VERSION[ \t]+([0-9]+)"
      XML_MINOR_VERSION ${_VERSION_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
      XML_MINOR_VERSION ${XML_MINOR_VERSION})
    string(REGEX MATCH "XML_MICRO_VERSION[ \t]+([0-9]+)"
      XML_MICRO_VERSION ${_VERSION_H_CONTENTS})
    string (REGEX MATCH "([0-9]+)"
      XML_MICRO_VERSION ${XML_MICRO_VERSION})

    set(${major} ${XML_MAJOR_VERSION} PARENT_SCOPE)
    set(${minor} ${XML_MINOR_VERSION} PARENT_SCOPE)
    set(${rev} ${XML_MICRO_VERSION} PARENT_SCOPE)
    
    # Store version string in file for installer needs
    file(TIMESTAMP ${CMAKE_CURRENT_SOURCE_DIR}/lib/expat.h VERSION_DATETIME "%Y-%m-%d %H:%M:%S" UTC)
    file(WRITE ${CMAKE_BINARY_DIR}/version.str "${XML_MAJOR_VERSION}.${XML_MINOR_VERSION}.${XML_MICRO_VERSION}\n${VERSION_DATETIME}")
endfunction(check_version)

function(report_version name ver)

    string(ASCII 27 Esc)
    set(BoldYellow  "${Esc}[1;33m")
    set(ColourReset "${Esc}[m")
        
    message(STATUS "${BoldYellow}${name} version ${ver}${ColourReset}")
    
endfunction()    
