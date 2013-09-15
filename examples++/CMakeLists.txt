option(libsocket_cpp_DEMO_STATIC_LINK "Link C++ examples with static library")

if(libsocket_cpp_DEMO_STATIC_LINK)
   if(libsocket_DEMO_USE_LIB_FROM_BUILD_DIR)
      set(LIB static_libsocket_cpp static_libisocket static_libusocket)
   else()
      set(LIB "libsocket_cpp.a" "libisocket.a" "libusocket.a")
   endif()
else()
   if(libsocket_DEMO_USE_LIB_FROM_BUILD_DIR)
      set(LIB libsocket_cpp libisocket libusocket)
   else()
      set(LIB "libsocket_cpp.so" "libisocket.so" "libusocket.so")
   endif()
endif()

foreach(X
        client
        echo_client_conn
        echo_client_sndto
        echo_server
        http_2
        http
        server
        unix_client_stream
        unix_dgram_client
        unix_dgram_server
        unix_dgram_syslogclient
        unix_server_stream)
   set(T "${X}_cpp")
   add_executable("${T}" "${X}.cpp")
   set_target_properties("${T}" PROPERTIES COMPILE_FLAGS "${EXTRA_CXXFLAGS}" OUTPUT_NAME "${X}")
   target_link_libraries("${T}" ${LIB})
endforeach(X)

set(T "C++-ex")
add_test("${T}1" http)
add_test("${T}2" http_2)
