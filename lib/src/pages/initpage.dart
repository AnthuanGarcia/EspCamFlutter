import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'campage.dart';

class InitPage extends StatefulWidget {
  final WebSocketChannel channel;

  InitPage({Key? key, required this.channel}) : super(key: key);

  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  Uint8List cam1Buffer = new Uint8List(7000);
  Uint8List cam2Buffer = new Uint8List(7000);

  PageController _pageController = PageController(viewportFraction: 0.2);
  StreamController _controller = StreamController<dynamic>.broadcast();
  //var cam1Key = new GlobalKey();
  //var cam2Key = new GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    widget.channel.sink.add('WEB_CLIENT');
    _controller.addStream(widget.channel.stream);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.channel.sink.close();
    super.dispose();
  }

  Route _routeToCamPage(String name) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) =>
          CamPage(channel: _controller, name: name),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8),
            child: Text(
              'Hola,\nNombre',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 48,
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: StreamBuilder(
                  stream: _controller.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var buf = snapshot.data as Uint8List;

                      if (buf[12] == 1) {
                        cam1Buffer = buf;
                      } else {
                        cam2Buffer = buf;
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Spacer(),
                              GestureDetector(
                                onTap: () => {
                                  Navigator.of(context)
                                      .push(_routeToCamPage('Patio')),
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    cam1Buffer,
                                    gaplessPlayback: true,
                                    width: 255,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 45),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => {
                                  Navigator.of(context)
                                      .push(_routeToCamPage('Cochera')),
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    cam2Buffer,
                                    gaplessPlayback: true,
                                    width: 255,
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ],
                      );
                      //return viewCam(snapshot.data as Uint8List);
                    } else {
                      return Text('XD');
                    }
                  },
                ),
              ),
              Positioned(
                child: Text(
                  'Patio',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 48,
                  ),
                ),
                right: MediaQuery.of(context).size.width * 0.08,
                top: MediaQuery.of(context).size.height * 0.27,
              ),
              Positioned(
                child: Text(
                  'Cochera',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 48,
                  ),
                ),
                left: MediaQuery.of(context).size.width * 0.08,
                top: MediaQuery.of(context).size.height * 0.64,
              )
            ],
          ),
        ],
      ),
    );
  }
}
