package main

import "core:net"
import "core:fmt"

network_test :: proc() -> net.Network_Error{
    any_sock := net.create_socket(net.Address_Family.IP4, net.Socket_Protocol.UDP) or_return
    defer net.close(any_sock)

    sock: net.UDP_Socket = net.UDP_Socket(net.any_socket_to_socket(any_sock))
    s: string = "Hello, world!";
    b: []u8 = make([]u8, len(s)); // Create a new slice of the same length
    copy(b, s);

    endpoint := net.Endpoint{address=net.IP4_Address{127,0,0,1}, port=12345};

    bytes_writte := net.send_udp(sock, b, endpoint) or_return;
    fmt.println("Wrote bytes:", bytes_writte)

    recv_buff := make([]byte, 1024)
    bytes_read, recv_endpoint := net.recv_udp(sock, recv_buff) or_return
    fmt.println("Read bytes:", bytes_read, recv_buff[:100], recv_endpoint)
    return nil
}
