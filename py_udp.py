import socket

# Define the host and port to listen on
UDP_IP = "0.0.0.0"  # Listen on all available interfaces
UDP_PORT = 12345  # Arbitrary non-privileged port
TCP_IP = "0.0.0.0"  # Listen on all available interfaces
TCP_PORT = 12345  # Arbitrary non-privileged port

# Create a UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

print("Reload")
print(f"Listening for UDP messages on {UDP_IP}:{UDP_PORT}...")

try:
    while True:
        # Receive data from a client (up to 1024 bytes)
        data, addr = sock.recvfrom(1024)
        print(f"Received message from {addr}: {data.decode()}")
        # Prepare a response message
        response_message = f"Hello! Got your message: {data.decode()}"

        # Send the response to the sender's address
        print("Sending message")
        bytes_sent = sock.sendto(response_message.encode(), addr)
        print(f"Sent response back to {addr}: {bytes_sent} bytes")

        # break
        break
except KeyboardInterrupt:
    print("\nUDP receiver stopped.")
finally:
    sock.close()


# Create a UDP socket
sock1 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock1.bind((TCP_IP, TCP_PORT))
sock1.listen()
print("Listening tcp")
try:
    while True:
        # Receive data from a client (up to 1024 bytes)
        socket, addr = sock1.accept()
        data = socket.recv(1024)
        print(f"Received message from {addr}: {data.decode()}")
        # Prepare a response message
        response_message = f"Hello! Got your message: {data.decode()}"

        # Send the response to the sender's address
        bytes_sent = socket.send(response_message.encode())
        print(f"Sent response back to {addr}: {bytes_sent} bytes")
        # break
        break
except KeyboardInterrupt:
    print("\nUDP receiver stopped.")
finally:
    sock.close()
