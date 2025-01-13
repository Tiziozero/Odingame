package main

import "core:net"
import "core:fmt"
import "core:strings"

network_test :: proc() -> net.Network_Error{
    fmt.println("UDP")
    udp_funct() or_return;
    
    fmt.println("TCP")
    tcp_funct() or_return;
    return nil
}

udp_funct :: proc() -> net.Network_Error{
    // create socket/any_socket
    any_sock := net.create_socket(net.Address_Family.IP4, net.Socket_Protocol.UDP) or_return
    // defer it's closure
    defer net.close(any_sock)

    // cast to udp socket ( to use with udp methods )
    sock: net.UDP_Socket = net.UDP_Socket(net.any_socket_to_socket(any_sock))
    // prepere message
    s: string = "Hello, world!";
    b: []u8 = make([]u8, len(s)); // Create a new slice of the same length
    copy(b, s);

    // create endpoint
    endpoint := net.Endpoint{address=net.IP4_Address{127,0,0,1}, port=12345};

    // write bytes
    bytes_writte := net.send_udp(sock, b, endpoint) or_return;
    fmt.println("Wrote bytes:", bytes_writte)

    // make receive buffer
    recv_buff := make([]byte, 1024)
    // receive into buffer
    bytes_read, recv_endpoint := net.recv_udp(sock, recv_buff) or_return
    // cast tp string
    recv_str := string(recv_buff[:]);
    fmt.println("Read bytes:", recv_str, ",\nRead:", bytes_read, ",\nFrom:", recv_endpoint)


    return nil
}
tcp_funct :: proc() -> net.Network_Error{
    /*
    any_sock := net.create_socket(net.Address_Family.IP4, net.Socket_Protocol.TCP) or_return
    defer net.close(any_sock)


    sock: net.TCP_Socket = net.TCP_Socket(net.any_socket_to_socket(any_sock))

    endpoint := net.Endpoint{address=net.IP4_Address{127,0,0,1}, port=12345};
    // connect to host
    net.bind(sock, endpoint)
    */
    // prepere message
    s: string = "Hello, world!";
    b: []u8 = make([]u8, len(s)); // Create a new slice of the same length
    copy(b, s);

    // for tcp, need to use tcp_dial_from_endpoint to create connection with endpoint
    // connect method not available in net package
    endpoint := net.Endpoint{address=net.IP4_Address{127,0,0,1}, port=12345};
    sock := net.dial_tcp_from_endpoint(endpoint) or_return;

    // write
    bytes_writte := net.send_tcp(sock, b) or_return;
    fmt.println("Wrote bytes:", bytes_writte)

    // make buff
    recv_buff := make([]byte, 1024)
    // read
    bytes_read := net.recv_tcp(sock, recv_buff) or_return
    recv_str := string(recv_buff[:]);
    fmt.println("Read bytes:", recv_str, ",\nRead:", bytes_read, ",\n")


    return nil
}
