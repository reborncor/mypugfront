import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../util/config.dart';

class SocketService {
  late IO.Socket socket;

  initialise(String username) {
    socket = IO.io(URL, <String, dynamic>{
      'transports': ['websocket'],
      'upgrade': false,
      'autoConnect': false,
    });
    socket.connect();
    socket.onConnecting((data) => print(data));
    socket.onConnect((data) => {
          log("Connected"),
          socket.emit("credentials", username),
        });

    socket.onDisconnect(
      (data) => socket.emit("disconnect_user", username),
    );

    socket.onReconnect(
      (data) => {log("Reconnected !"), socket.emit("credentials", username)},
    );
  }

  onDisconnect(String user) {
    // socket.onDisconnect((data) =>  socket.emit("disconnect_user_game", user),);
  }

  Disconnect() {
    socket.disconnect();
  }

  getSocket() {
    return socket;
  }
}
