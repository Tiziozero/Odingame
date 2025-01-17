import socket
# Define the host and port to listen on
UDP_IP = "0.0.0.0"  # Listen on all available interfaces
UDP_PORT = 8878  # Arbitrary non-privileged port
TCP_IP = "0.0.0.0"  # Listen on all available interfaces
TCP_PORT = 3845  # Arbitrary non-privileged port
class Server:
    def __init__(self, addr: str = "0.0.0.0", port: int = 3845) -> None:
        self.message_addr: str = addr
        self.message_port: int = port
        self.message_stream: socket.socket;
        self.game_sock: socket.socket;
        self.__server_is_on: bool;
        self.start()
    def start(self):
        ...

    def restart_connection(self) -> None:
        try:
            self.game_sock.close()
            self.message_stream.close()
        finally: ... 
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.bind((self.message_addr, self.message_port))
            sock.listen()
            self.message_stream = sock
            self.__server_is_on = True
        finally:
            ...

    def run(self):
        try: 
            while self.__server_is_on:
                print("I ran");
        finally:
            ...


if __name__ == "__main__":
    s = Server();
    s.run();

