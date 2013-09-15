cmake_minimum_required(VERSION 2.6)

if(DEFINED CMAKE_BUILD_TYPE)
   #set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING
   #    "Choose the build type: None, Debug, Release, RelWithDebInfo or MinSizeRel.")
else()
   # Set the preferred default type for the software generation here.
   set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING
       "Choose the build type: None, Debug, Release, RelWithDebInfo or MinSizeRel.")
endif()

project(libsocket)

set(libsocket_VERSION_MAJOR 2)
set(libsocket_VERSION_MINOR 2)
set(libsocket_VERSION_PATCH 1)

set(doc "Should the C++ source files be processed?")
option(libsocket_ENABLE_CPP_ELEMENTS "${doc}")

# http://stackoverflow.com/questions/10984442/how-to-detect-c11-support-of-a-compiler-with-cmake
if(CMAKE_COMPILER_IS_GNUCXX)
   execute_process(COMMAND "${CMAKE_C_COMPILER}" -dumpversion OUTPUT_VARIABLE GCC_VERSION)

   if(GCC_VERSION VERSION_GREATER 4.7 OR GCC_VERSION VERSION_EQUAL 4.7)
      message(STATUS "C++11 support activated.")
      #set(EXTRA_CXXFLAGS "-std=gnu++11")
      set(EXTRA_CXXFLAGS "-std=c++11") 
      set(libsocket_ENABLE_CPP_ELEMENTS YES CACHE BOOL "${doc}" FORCE)
   elseif(GCC_VERSION VERSION_GREATER 4.3 OR GCC_VERSION VERSION_EQUAL 4.3)
      message(WARNING "C++0x activated. If you get any errors, update to a compiler which fully supports C++11.")
      set(EXTRA_CXXFLAGS "-std=gnu++0x")
      set(libsocket_ENABLE_CPP_ELEMENTS YES CACHE BOOL "${doc}" FORCE)
   else()
      message(WARNING "It seems that your GCC compiler does not support C++11 as expected.
 The processing of C++ source files is excluded from this project now.")
   endif()
else()
   # http://stackoverflow.com/questions/10046114/in-cmake-how-can-i-test-if-the-compiler-is-clang
   if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
      set(EXTRA_CXXFLAGS "-std=c++11") 
      set(libsocket_ENABLE_CPP_ELEMENTS YES CACHE BOOL "${doc}" FORCE)
   elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
      set(EXTRA_CXXFLAGS "-std=c++11") 
      set(libsocket_ENABLE_CPP_ELEMENTS YES CACHE BOOL "${doc}" FORCE)
   elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
      set(EXTRA_CXXFLAGS "") 
      set(libsocket_ENABLE_CPP_ELEMENTS YES CACHE BOOL "${doc}" FORCE)
   else()
      message(WARNING "The support of C++11 should be checked in more detail for the compiler \"${CMAKE_CXX_COMPILER_ID}\".
 The processing of C++ source files is excluded from this project now.")
   endif()
endif()

configure_file("${libsocket_SOURCE_DIR}/config.h.in" "${libsocket_BINARY_DIR}/config.h")
include_directories("${libsocket_SOURCE_DIR}/headers" "${libsocket_SOURCE_DIR}")

set(SOURCES "C/libinetsocket.c")
add_library(libisocket SHARED ${SOURCES})
add_library(static_libisocket STATIC ${SOURCES})
set_target_properties(libisocket static_libisocket
                      PROPERTIES OUTPUT_NAME "isocket" CLEAN_DIRECT_OUTPUT 1)

set(SOURCES "C/libunixsocket.c")
add_library(libusocket SHARED ${SOURCES})
add_library(static_libusocket STATIC ${SOURCES})
set_target_properties(libusocket static_libusocket
                      PROPERTIES OUTPUT_NAME "usocket" CLEAN_DIRECT_OUTPUT 1)

option(libsocket_LOG_API_FAILURES "Should failed API calls be logged?")

if(libsocket_LOG_API_FAILURES)
   set_target_properties(libisocket libusocket static_libisocket static_libusocket
                         PROPERTIES COMPILE_FLAGS "-DVERBOSE")
endif()

set(libsocket_USE_SPECIAL_FUNCTION NO)

if(libsocket_USE_SPECIAL_FUNCTION)
   function(libsocket_determine_file_name T V)
     get_target_property(O "${T}" OUTPUT_NAME)
     get_target_property(P "${T}" PREFIX)
     get_target_property(S "${T}" SUFFIX)
     set("${V}" "${P}${O}${S}" PARENT_SCOPE)
     message(STATUS "POS: |${P}${O}${S}|")
   endfunction()

   libsocket_determine_file_name(libisocket I)
   libsocket_determine_file_name(libusocket U)
   message(STATUS "IU: |${I}|${U}|")
   libsocket_determine_file_name(static_libisocket I)
   libsocket_determine_file_name(static_libusocket U)
   message(STATUS "sIU: |${I}|${U}|")
endif()

option(libsocket_DEMO_USE_API_HEADERS_FROM_BUILD_DIR
       "Should the header files for the API be reused from the source directory?" YES)
option(libsocket_DEMO_USE_LIB_FROM_BUILD_DIR
       "Should the library be directly used from the build directory?" YES)
option(libsocket_DEMO_BUILD_C
       "Should the examples be built for the C library?" YES)

enable_testing()
#add_test(t1 "libsocket-test")

if(libsocket_DEMO_BUILD_C)
   add_subdirectory("examples")
endif()

if(CMAKE_BUILD_TYPE STREQUAL "")
   set(libsocket_INSTALL_BUILD_TYPE "/empty")
else()
   set(libsocket_INSTALL_BUILD_TYPE "/${CMAKE_BUILD_TYPE}")
endif()

set(libsocket_INSTALL_GENERATION_ID XYZ CACHE STRING
    "This setting should identify the tool chain that produced the installable files.
It is a kind of hash for the complete generation process.")
set(libsocket_INSTALL_COMMON_SUBDIR "${CMAKE_PROJECT_NAME}${libsocket_INSTALL_BUILD_TYPE}/${libsocket_INSTALL_GENERATION_ID}" CACHE STRING
    "This setting specifies the unique name for an installable build configuration.")
set(libsocket_INSTALL_SHARED_LIB_DIR "lib/${libsocket_INSTALL_COMMON_SUBDIR}" CACHE PATH
    "Installation directory for shared libraries")
set(libsocket_INSTALL_STATIC_LIB_DIR "${libsocket_INSTALL_SHARED_LIB_DIR}/static" CACHE PATH
    "Installation directory for static libraries")
install(TARGETS "libisocket" "libusocket" "static_libisocket" "static_libusocket"
        LIBRARY DESTINATION "${libsocket_INSTALL_SHARED_LIB_DIR}"
        ARCHIVE DESTINATION "${libsocket_INSTALL_STATIC_LIB_DIR})")

set(libsocket_INSTALL_INC_DIR "include/${libsocket_INSTALL_COMMON_SUBDIR}" CACHE PATH
    "Installation directory for header files")
install(FILES "${libsocket_BINARY_DIR}/config.h" "libinetsocket.h" "libunixsocket.h"
        DESTINATION "${libsocket_INSTALL_INC_DIR}")


if(libsocket_ENABLE_CPP_ELEMENTS)
   add_definitions(-DMIXED)

   set(SOURCES
       "C++/dgramclient.cpp"
       "C++/exception.cpp"
       "C++/inetbase.cpp"
       "C++/inetclientdgram.cpp"
       "C++/inetclientstream.cpp"
       "C++/inetdgram.cpp"
       "C++/inetserverdgram.cpp"
       "C++/inetserverstream.cpp"
       "C++/select.cpp"
       "C++/socket.cpp"
       "C++/streamclient.cpp"
       "C++/unixbase.cpp"
       "C++/unixclientdgram.cpp"
       "C++/unixclientstream.cpp"
       "C++/unixdgram.cpp"
       "C++/unixserverdgram.cpp"
       "C++/unixserverstream.cpp")
   add_library(libsocket_cpp SHARED ${SOURCES})
   add_library(static_libsocket_cpp STATIC ${SOURCES})
   set_target_properties(libsocket_cpp static_libsocket_cpp
                         PROPERTIES OUTPUT_NAME "socket_cpp"
                                    CLEAN_DIRECT_OUTPUT 1
                                    COMPILE_FLAGS "${EXTRA_CXXFLAGS}")

   option(libsocket_DEMO_BUILD_CPP
          "Should the examples be built for the C++ library?" YES)

   if(libsocket_DEMO_BUILD_CPP)
      add_subdirectory("examples++")
   endif()

   set(libsocket_cpp_INSTALL_SHARED_LIB_DIR "lib/${libsocket_INSTALL_COMMON_SUBDIR}" CACHE PATH
       "Installation directory for shared libraries (C++ variants)")
   set(libsocket_cpp_INSTALL_STATIC_LIB_DIR "${libsocket_INSTALL_SHARED_LIB_DIR}/static" CACHE PATH
       "Installation directory for static libraries (C++ variants)")
   install(TARGETS "libsocket_cpp" "static_libsocket_cpp"
           LIBRARY DESTINATION "${libsocket_cpp_INSTALL_SHARED_LIB_DIR}"
           ARCHIVE DESTINATION "${libsocket_cpp_INSTALL_STATIC_LIB_DIR})")

   set(libsocket_cpp_INSTALL_INC_DIR "include/${libsocket_INSTALL_COMMON_SUBDIR}" CACHE PATH
       "Installation directory for C++ header files")
   install(FILES "${libsocket_BINARY_DIR}/config.h"
                 "dgramclient.hpp"
                 "exception.hpp"
                 "inetbase.hpp"
                 "inetclientdgram.hpp"
                 "inetclientstream.hpp"
                 "inetdgram.hpp"
                 "inetserverdgram.hpp"
                 "inetserverstream.hpp"
                 "select.hpp"
                 "socket.hpp"
                 "streamclient.hpp"
                 "unixbase.hpp"
                 "unixclientdgram.hpp"
                 "unixclientstream.hpp"
                 "unixdgram.hpp"
                 "unixserverdgram.hpp"
                 "unixserverstream.hpp"
           DESTINATION "${libsocket_cpp_INSTALL_INC_DIR}")
endif()


include("package_settings.cmake")

# Tobias Rautenkranz can help to generate some documentation.
# http://tobias.rautenkranz.ch/cmake/doxygen/
include(UseDoxygen OPTIONAL)
