# The following instructions were derived from this article:
# http://www.cmake.org/Wiki/index.php?title=CMake:Packaging_With_CPack#Using_CMake_variables_to_configure_CPack

include(InstallRequiredSystemLibraries)

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A library with a C part and a C++ part making sockets usage easy and clean")
#set(CPACK_PACKAGE_VENDOR "???")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
#set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/Copyright.txt")
set(CPACK_PACKAGE_VERSION_MAJOR "${libsocket_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${libsocket_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${libsocket_VERSION_PATCH}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "CMake ${CMake_VERSION_MAJOR}.${CMake_VERSION_MINOR}")

if(WIN32 AND NOT UNIX)
   # There is a bug in NSI that does not handle full unix paths properly.
   # Make sure there is at least one set of four (4) backlasshes.
   #set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/Utilities/Release\\\\InstallIcon.bmp")
   set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\libsocket-test.exe")
   set(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_INSTALL_DIRECTORY} ${PROJECT_NAME}")
   set(CPACK_NSIS_HELP_LINK "http:\\\\\\\\lbo.spheniscida.de/doc/libsocket/doxygen/index.html")
   set(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\lbo.spheniscida.de/doc/libsocket/doxygen/index.html")
   set(CPACK_NSIS_CONTACT "dermesser <lbo@spheniscida.de>")
   set(CPACK_NSIS_MODIFY_PATH ON)
else()
   set(CPACK_STRIP_FILES "bin/libsocket-test")
   set(CPACK_SOURCE_STRIP_FILES "")
endif()

# See also:
# * Message "CPack NSIS installer requires CPACK_PACKAGE_EXECUTABLES entry?"
#   by Sam Baker: http://www.cmake.org/pipermail/cmake/2008-October/024682.html
# * Report "CPACK_PACKAGE_EXECUTABLES creates start menu shortcuts for components that are not selected to be installed"
#   http://public.kitware.com/Bug/view.php?id=9846
# * http://vtk.org/Wiki/CMake:CPackConfiguration
set(CPACK_PACKAGE_EXECUTABLES "libsocket-test";"A test program for the ${PROJECT_NAME} library")

include(CPack)
