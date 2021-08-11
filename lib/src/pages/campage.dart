import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:web_socket_channel/web_socket_channel.dart';

class CamPage extends StatefulWidget {
  final StreamController channel;
  final String name;

  CamPage({Key? key, required this.channel, required this.name})
      : super(key: key);

  @override
  _CamPageState createState() => _CamPageState();
}

class _CamPageState extends State<CamPage> {
  //int numCam = 0;
  //Uint8List cam = new Uint8List(7000);
  bool tapping = false;

  final _globalkey = new GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    //numCam = widget.name == 'Patio' ? 1 : 2;
    _requestPermission();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
  }

  void takePhoto() async {
    setState(() {
      tapping = true;
    });

    RenderRepaintBoundary boundary =
        _globalkey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    var image = await boundary.toImage();
    var bytes = await image.toByteData(format: ImageByteFormat.png);
    var bufpng = bytes!.buffer.asUint8List();

    final res = await ImageGallerySaver.saveImage(bufpng);

    Fluttertoast.showToast(
      msg: res["isSuccess"] ? 'Captura Guardada' : 'Error al guardar',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color.fromARGB(125, 210, 210, 210),
      textColor: Colors.black,
      fontSize: 14.0,
    );

    setState(() {
      tapping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = Theme.of(context).textTheme.title!.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 48,
      shadows: [
        Shadow(
            // bottomLeft
            offset: Offset(-1, -1),
            color: Colors.white),
        Shadow(
            // bottomRight
            offset: Offset(1, -1),
            color: Colors.white),
        Shadow(
            // topRight
            offset: Offset(1, 1),
            color: Colors.white),
        Shadow(
            // topLeft
            offset: Offset(-1, 1),
            color: Colors.white),
      ],
    );
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        child: Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(
            top: 15,
            left: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: SvgPicture.asset('assets/svg/backbord.svg'),
              ),
              SizedBox(width: 15),
              Hero(
                tag: 'Title',
                child: Text(
                  widget.name,
                  textAlign: TextAlign.left,
                  style: style,
                ),
              ),
            ],
          ),
        ),
        preferredSize: Size(MediaQuery.of(context).size.width, 75),
      ),
      body: Stack(
        children: [
          Container(
            child: StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var buf = snapshot.data as Uint8List;

                  return Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height,
                    child: PhotoView.customChild(
                      initialScale: 1.0,
                      backgroundDecoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                      ),
                      child: RepaintBoundary(
                        key: _globalkey,
                        child: Transform.rotate(
                          angle: 3.141592,
                          child: Hero(
                            tag: widget.name,
                            child: Image.memory(
                              buf,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Text('No JalaX2');
                }
              },
            ),
          ),
          Positioned(
            child: GestureDetector(
              onTap: takePhoto,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 800),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: !tapping ? Colors.white : Colors.black,
                  //borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.20),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/svg/cam.svg',
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            top: MediaQuery.of(context).size.height * 0.75,
            left: MediaQuery.of(context).size.width * 0.40,
          ),
        ],
      ),
    );
  }
}
