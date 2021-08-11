import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_view/photo_view.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'campage.dart';

class InitPage extends StatefulWidget {
  final List<WebSocketChannel> channels;

  InitPage({Key? key, required this.channels}) : super(key: key);

  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  //Uint8List cam1Buffer = new Uint8List(7000);
  //Uint8List cam2Buffer = new Uint8List(7000);

  PageController _pageController = PageController(
    viewportFraction: 0.3,
    initialPage: 0,
  );
  PageController _pageTextController = PageController();
  StreamController _controller = StreamController<dynamic>.broadcast();
  StreamController _controllercam2 = StreamController<dynamic>.broadcast();
  //var cam1Key = new GlobalKey();
  //var cam2Key = new GlobalKey();

  var cams = [];
  static const List<String> names = ['Patio', 'Cochera'];

  double? _currentPage = 0;
  double _textPage = 0;

  void _scrollListener() {
    setState(() {
      _currentPage = _pageController.page;
    });
  }

  void _textScroll() {
    _textPage = _currentPage!;
  }

  @override
  void initState() {
    // TODO: implement initState
    widget.channels[0].sink.add('WEB_CLIENT');
    widget.channels[1].sink.add('WEB_CLIENT');
    _controller.addStream(widget.channels[0].stream);
    _controllercam2.addStream(widget.channels[1].stream);

    _pageController.addListener(_scrollListener);
    _pageTextController.addListener(_textScroll);

    cams = [
      Container(
        margin: EdgeInsets.all(5),
        child: StreamBuilder(
          stream: _controller.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var buf = snapshot.data as Uint8List;

              return GestureDetector(
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return CamPage(name: names[0], channel: _controller);
                })),
                child: Transform.rotate(
                  angle: 3.141592,
                  child: Hero(
                    tag: names[0],
                    child: Image.memory(
                      buf,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              );
              //return viewCam(snapshot.data as Uint8List);
            } else {
              return Text('XD');
            }
          },
        ),
      ),
      Container(
        margin: EdgeInsets.all(5),
        child: StreamBuilder(
          stream: _controllercam2.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var buf = snapshot.data as Uint8List;

              return GestureDetector(
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return CamPage(name: names[1], channel: _controllercam2);
                })),
                child: Transform.rotate(
                  angle: 3.141592,
                  child: Hero(
                    tag: names[1],
                    child: Image.memory(
                      buf,
                      gaplessPlayback: true,
                      width: 255,
                    ),
                  ),
                ),
              );
              //return viewCam(snapshot.data as Uint8List);
            } else {
              return Text('XD');
            }
          },
        ),
      ),
    ];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.channels[0].sink.close();
    widget.channels[1].sink.close();

    _pageController.removeListener(_scrollListener);
    _pageController.dispose();
    _pageTextController.removeListener(_textScroll);
    _pageTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = Theme.of(context).textTheme.title!.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 48,
        );
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      extendBodyBehindAppBar: false,
      /*appBar: PreferredSize(
        child: Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: PageView.builder(
            itemCount: names.length,
            controller: _pageTextController,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, idx) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'Title',
                    child: Text(
                      names[idx],
                      style: style,
                    ),
                  )
                ],
              );
            },
          ),
        ),
        preferredSize: Size(MediaQuery.of(context).size.width, 90),
      ),*/
      body: Stack(
        alignment: AlignmentDirectional.topStart,
        children: [
          Transform.scale(
            scale: 1.3,
            alignment: Alignment.lerp(
              Alignment.center,
              Alignment.bottomCenter,
              0,
            ),
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: cams.length,
              onPageChanged: (val) {
                _pageTextController.animateToPage(
                  val,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              },
              itemBuilder: (context, idx) {
                final result = _currentPage! - idx;
                final value = -0.4 * result + 1;
                return Container(
                  child: Transform(
                    alignment: Alignment.topCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..translate(
                          0.0,
                          MediaQuery.of(context).size.height /
                              2.6 *
                              (1 - value).abs())
                      ..scale(value),
                    child: cams[idx],
                  ),
                );
              },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 130,
            child: PageView.builder(
              itemCount: names.length,
              controller: _pageTextController,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, idx) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'Title',
                      child: Text(
                        names[idx],
                        style: style,
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
