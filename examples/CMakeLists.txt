option(libsocket_DEMO_STATIC_LINK "Link examples with static library")

if(libsocket_DEMO_STATIC_LINK)
   if(libsocket_DEMO_USE_LIB_FROM_BUILD_DIR)
      set(LIB static_libisocket static_libusocket)
   else()
      if(libsocket_USE_SPECIAL_FUNCTION)
         libsocket_determine_file_name(static_libisocket I)
         libsocket_determine_file_name(static_libusocket U)
      endif()

      set(LIB "libisocket.a" "libusocket.a")
      #set(LIB "${I}" "${U}")
   endif()
else()
   if(libsocket_DEMO_USE_LIB_FROM_BUILD_DIR)
      set(LIB libisocket libusocket)
   else()
      if(libsocket_USE_SPECIAL_FUNCTION)
         libsocket_determine_file_name(libisocket I)
         libsocket_determine_file_name(libusocket U)
      endif()

      set(LIB "libisocket.so" "libusocket.so")
      #set(LIB "${I}" "${U}")
   endif()
endif()

foreach(X
        echo_dgram_client
        echo_dgram_connect_client
        echo_dgram_server
        get_address_family
        http
        transmission_client
        transmission_server
        unix_dgram_client
        unix_dgram_connected_client
        unix_dgram_server
        unix_stream_client
        unix_stream_server)
   set(T "${X}_c")
   add_executable("${T}" "${X}.c")
   set_target_properties("${T}" PROPERTIES OUTPUT_NAME "${X}")
   target_link_libraries("${T}" ${LIB})
endforeach(X)

set(T "C-ex")
add_test("${T}1" get_address_family)
add_test("${T}2" http)
