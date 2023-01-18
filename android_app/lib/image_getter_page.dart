import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img_pack;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';
import 'package:external_path/external_path.dart';
// import 'package:ext_storage/ext_storage.dart';

class ImageGetterWidget extends StatefulWidget {
  late String model = 'age_model_a';
  late String epoch = '20';
  // ImageGetterWidget(String model, String epoch) {
  //   this.model = model;
  //   this.epoch = epoch;
  // }
  ImageGetterWidget({required this.model, required this.epoch});

  @override
  State<ImageGetterWidget> createState() => _ImageGetterState(model, epoch);
}

class _ImageGetterState extends State<ImageGetterWidget> {
  late String model = 'age_model_a';
  late String epoch = '20';

  bool imageSelected = false;
  bool predictEnabled = false;
  bool waitingForResponse = false;
  bool drawable = false;
  bool visibleAge = false;
  //"modals/modal_1_50.modal"
  String modelsPath = "models/";

  dynamic imageWidth = 400;
  dynamic imageHeight = 400;

  List<String> incomeResults = ['116.00', '208.01', '372.00, 372.00, 58.00'];
  List<int> incomeResultsInt = [100, 0, 0, 0, 10];
  String secretKey = "eYw6HywLbFXu4PBLDIVZsbKzdgKALxI1AvPuptiDtgQbAzFuRsMLCw=="; // Secret key from Azure
  // website: https://agepredictor2.azurewebsites.net/api/HttpTrigger1?code=EoMowN0V-Ix-SOIX5Xlm83wdqSbQWQvFQTTAw9VMnkxIAzFuxD_v1w==

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
        appBar: AppBar(title: const Text("Age Predictor"), backgroundColor: Colors.redAccent),
        body: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      gotImage = await picker.pickImage(source: ImageSource.gallery);
                      storedImageOnRoot = File(gotImage!.path);

                      // Getting dimensions of image
                      final bytes = await File(storedImageOnRoot.path).readAsBytes();
                      final img_pack.Image? image = img_pack.decodeImage(bytes);
                      log("Image sizes: ${image?.height} ${image?.width}");
                      imageWidth = image?.width;
                      imageHeight = image?.height;

                      log("Image sizes2: h${Image.file(storedImageOnRoot, width: 400).height} w${Image.file(storedImageOnRoot, width: 400).width}");

                      final fileName = path.basename(storedImageOnRoot.path);
                      var extPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
                      // await storedImageOnRoot.copy('$extPath/$fileName');
                      log("Root path $storedImageOnRoot \nExt Fath File: '$extPath/$fileName");
                      // log("Size width: ${storedImageOnRoot.width} height: ${storedImageOnRoot.height}"),
                      setState(() {
                        imageSelected = true;
                      });
                    },
                    child: const Text("Pick Image from Gallery")),
                ElevatedButton(
                    onPressed: () async {
                      gotImage = await picker.pickImage(source: ImageSource.camera);
                      storedImageOnRoot = File(gotImage!.path);

                      // Getting dimensions of image
                      final bytes = await File(storedImageOnRoot.path).readAsBytes();
                      final img_pack.Image? image = img_pack.decodeImage(bytes);
                      log("Image sizes: ${image?.height} ${image?.width}");
                      imageWidth = image?.width;
                      imageHeight = image?.height;

                      final fileName = path.basename(storedImageOnRoot.path);
                      var extPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
                      // var extPath = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
                      /* final File localImage = */ await storedImageOnRoot.copy('$extPath/$fileName');
                      log("Root path $storedImageOnRoot \nExt Fath File: '$extPath/$fileName");
                      setState(() {
                        imageSelected = true;
                      });
                    },
                    child: const Text("Take Photo from Camera")),
                Visibility(
                  visible: !predictEnabled && imageSelected,
                  child: TextButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
                    onPressed: () async {
                      setState(() {
                        predictEnabled = true;
                        drawable = false;
                        visibleAge = false;
                        waitingForResponse = true;
                      });

                      String tempIncome = await trialPost(); // get response of model
                      setState(() {
                        visibleAge = true;
                        waitingForResponse = false;
                      });

                      log(tempIncome);
                      tempIncome = tempIncome.substring(14, tempIncome.length - 3);

                      incomeResults = tempIncome.split(', ');
                      for (int i = 0; i < incomeResults.length; i++) {
                        incomeResultsInt[i] = int.parse(incomeResults[i]);
                      }
                      setState(() {
                        drawable = true;
                        predictEnabled = false;
                      });
                    },
                    child: const Text(
                      'Predict',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Visibility(
                  visible: waitingForResponse,
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: const [
                          Text('Waiting for response'),
                          SizedBox(
                            height: 15,
                          ),
                          LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation(Colors.red)),
                        ],
                      )),
                ),
                Visibility(
                  visible: visibleAge,
                  child: Column(children: [
                    Text(
                      'Predicted Age:${incomeResultsInt[4]}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ]),
                ),
                (gotImage == null)
                    ? Container()
                    : Stack(
                        children: <Widget>[
                          SizedBox(
                            width: 350,
                            // height: 350,
                            child: Image.file(
                              storedImageOnRoot,
                              fit: BoxFit.fitHeight,
                              height: 350,
                            ),
                          ),
                          if (visibleAge) Positioned.fill(child: CustomPaint(painter: SquareDrawer(getRectAndAge()), child: Container()))
                        ],
                      )
                // (gotImage == null)
                //     ? Container()
                //     : Stack(
                //         children: [
                //           //Image.file(storedImageOnRoot, width: 400, height: 400),
                //           SizedBox(
                //             width: 400,
                //             height: 400,
                //             child: Image.file(storedImageOnRoot),
                //           ),
                //           if (visibleAge)
                //             SizedBox(
                //                 width: 400,
                //                 height: 400,
                //                 child: Positioned.fill(child: CustomPaint(painter: SquareDrawer(getRectAndAge()), child: Container()))),
                //         ],
                //       )
              ],
            )));
  }

  Future<String> convertFileToImage(File picture) async {
    File picture = await FlutterNativeImage.compressImage(storedImageOnRoot.path, quality: 30, percentage: 100);
    List<int> imageBytes = picture.readAsBytesSync();

    String base64Image = base64.encode(imageBytes);
    return base64Image;
  }

  Future<String> trialPost() async {
    if (model == "age_model_a") model = "age_model_a/weights.18-4.06.hdf5";
    // convert image to json using base64 encoding
    var imageJson = await convertFileToImage(storedImageOnRoot);
    var jsonCode = {"model_path": modelsPath + model, "image": imageJson};
    var body = jsonEncode(jsonCode);

    var response = await http.post(Uri.parse("http://192.168.43.136:7072/api/HttpTrigger1"),
        // Uri.parse("http://172.16.92.156:7072/api/HttpTrigger1"),
        body: body,
        headers: {"x-functions-key": secretKey});
    // await http.post(Uri.https('agepredictorwin2.azurewebsites.net', '/api/HttpTrigger1'), body: body, headers: {"x-functions-key": secretKey});

    log("Response from model: ${response.body}");
    return response.body.toString();
  }

  Tuple2<Rect, int> getRectAndAge() {
    // const drawInfo = Tuple2<Rect, int>(Rect.fromLTWH(80.0, 80.0, 115.0, 130.0), 7);
    var widthRatio = 350 / imageWidth;
    var ratio = 350 / imageHeight;
    var widthHeightRatio = imageWidth / imageHeight;
    var heightWidthRatio = imageHeight / imageWidth;
    log("Width: $imageWidth, Height: $imageHeight");

    // double x = incomeResultsInt[0] * ratio * widthHeightRatio;
    double y = incomeResultsInt[1] * ratio;
    double x, w;
    if (imageHeight > imageWidth) {
      x = incomeResultsInt[0] * widthRatio;
      w = incomeResultsInt[2] * ratio;
    } else {
      x = incomeResultsInt[0] * ratio * heightWidthRatio;
      w = incomeResultsInt[2] * widthRatio;
    }
    // double w = incomeResultsInt[2] * ratio * widthHeightRatio;
    double h = incomeResultsInt[3] * ratio;

    // double x = incomeResultsInt[0] * 3 / 10;
    // double y = incomeResultsInt[1] * 3 / 10;
    // double w = incomeResultsInt[2] * 3 / 10;
    // double h = incomeResultsInt[3] * 3 / 10;

    var drawInfo = Tuple2<Rect, int>(Rect.fromLTWH(x, y, w, h), incomeResultsInt[4]);

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
    TextSpan span = TextSpan(style: const TextStyle(color: Colors.red, fontSize: 20.0), text: "Age: $age");
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
