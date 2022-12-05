// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:path/path.dart' as path;
import 'package:tuple/tuple.dart';

// void main() {
//   runApp(ImageGetter());
// }

// class ImageGetterPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ImageGetterWidget(model, epoch),
//     );
//   }
// }

class ImageGetterWidget extends StatefulWidget {
  late String model = 'Model 1';
  late String epoch = '500';
  ImageGetterWidget(String model, String epoch) {
    this.model = model;
    this.epoch = epoch;
  }

  @override
  State<ImageGetterWidget> createState() => _ImageGetterState(model, epoch);
}

class _ImageGetterState extends State<ImageGetterWidget> {
  late String model = 'Model 1';
  late String epoch = '500';
  _ImageGetterState(String model, String epoch) {
    this.model = model;
    this.epoch = epoch;
  }

  ImagePicker picker = ImagePicker();
  var gotImage;
  late File storedImageOnRoot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Model Selector"), backgroundColor: Colors.redAccent),
        body: Container(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      gotImage = await picker.pickImage(source: ImageSource.gallery);
                      storedImageOnRoot = File(gotImage!.path);

                      final fileName = path.basename(storedImageOnRoot.path);
                      var extPath = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
                      await storedImageOnRoot.copy('$extPath/$fileName');
                      log("Root path $storedImageOnRoot \nExt Fath File: '$extPath/$fileName");
                      setState(() {
                        //update UI
                      });
                    },
                    child: Text("Pick Image from Gallery")),
                ElevatedButton(
                    onPressed: () async {
                      gotImage = await picker.pickImage(source: ImageSource.camera);
                      storedImageOnRoot = File(gotImage!.path);

                      final fileName = path.basename(storedImageOnRoot.path);
                      var extPath = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
                      /* final File localImage = */ await storedImageOnRoot.copy('$extPath/$fileName');
                      log("Root path $storedImageOnRoot \nExt Fath File: '$extPath/$fileName");
                      setState(() {
                        // UI update
                      });
                    },
                    child: Text("Take Photo from Camera")),
                gotImage == null
                    ? Container()
                    : /* Image.file(storedImageOnRoot, width: 400, height: 400)*/
                    Stack(
                        children: <Widget>[
                          Image.file(storedImageOnRoot, width: 400, height: 400),
                          Positioned.fill(child: CustomPaint(painter: SquareDrawer(getRectAndAge()), child: Container()))
                        ],
                      )
              ],
            )));
  }

  Tuple2<Rect, int> getRectAndAge() {
    const drawInfo = Tuple2<Rect, int>(Rect.fromLTWH(80.0, 80.0, 115.0, 130.0), 7);
    return drawInfo;
  }
}

class SquareDrawer extends CustomPainter {
  Rect? square;
  int? age;

  // constructor
  SquareDrawer(Tuple2<Rect, int> drawInfo) {
    square = drawInfo.item1;
    age = drawInfo.item2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintFeatures = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    // write text
    TextSpan span = TextSpan(style: TextStyle(color: Colors.red, fontSize: 20.0), text: "Age: $age");
    // add span to text painter
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    // set position
    tp.layout();
    tp.paint(canvas, Offset(square!.right - 25.0, square!.top - 25.0));

    canvas.drawRect(square!, paintFeatures);
  }

  @override
  bool shouldRepaint(SquareDrawer oldDelegate) => true;
}
