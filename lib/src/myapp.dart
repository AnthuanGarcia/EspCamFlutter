import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'pages/initpage.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Camaras",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
      ),
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        builder: (BuildContext context) => InitPage(channels: [
          WebSocketChannel.connect(Uri.parse("ws://camest.herokuapp.com")),
          WebSocketChannel.connect(Uri.parse("ws://camest2.herokuapp.com"))
        ]),
      ),
    );
  }
}
