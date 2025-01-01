// import 'dart:io';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';
// import '../constants/colors.dart';
//
// class CameraScreen extends StatefulWidget {
//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends State<CameraScreen> {
//   List<CameraDescription> _cameras = [];
//   late CameraController controller;
//   late ImageLabeler imageLabeler;
//   bool isBusy = false;
//   String result = "";
//
//   @override
//   void initState() {
//     super.initState();
//     final ImageLabelerOptions options =
//         ImageLabelerOptions(confidenceThreshold: 0.5);
//     imageLabeler = ImageLabeler(options: options);
//     // loadModel();
//     _setupCameraController();
//   }
//
//   Future<void> _setupCameraController() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     _cameras = await availableCameras();
//     controller = CameraController(
//       _cameras[0],
//       ResolutionPreset.max,
//       imageFormatGroup: Platform.isAndroid
//           ? ImageFormatGroup.nv21 // for Android
//           : ImageFormatGroup.bgra8888,
//     );
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       controller.startImageStream((image) {
//         if (!isBusy) {
//           isBusy = true;
//           doImageLabeling(image);
//         }
//       });
//       setState(() {});
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         switch (e.code) {
//           case 'CameraAccessDenied':
//             // Handle access errors here.
//             break;
//           default:
//             // Handle other errors here.
//             break;
//         }
//       }
//     });
//   }
//
//   Future<String> getModelPath(String asset) async {
//     final path = '${(await getApplicationSupportDirectory()).path}/$asset';
//     await Directory(dirname(path)).create(recursive: true);
//     final file = File(path);
//     if (!await file.exists()) {
//       final byteData = await rootBundle.load(asset);
//       await file.writeAsBytes(byteData.buffer
//           .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
//     }
//     return file.path;
//   }
//
//   // loadModel() async {
//   //   final modelPath = await getModelPath('assets/ml/fruits2.tflite');
//   //   final options = LocalLabelerOptions(
//   //     confidenceThreshold: 0.6,
//   //     modelPath: modelPath,
//   //   );
//   //   imageLabeler = ImageLabeler(options: options);
//   // }
//
//   doImageLabeling(CameraImage img) async {
//     result = "";
//     InputImage? inputImg = _inputImageFromCameraImage(img);
//     if (inputImg != null) {
//       final List<ImageLabel> labels = await imageLabeler.processImage(inputImg);
//       for (ImageLabel label in labels) {
//         final String text = label.label;
//         final int index = label.index;
//         final double confidence = label.confidence;
//         result += "$text   ${confidence.toStringAsFixed(2)}\n";
//       }
//       setState(() {
//         result;
//         isBusy = false;
//       });
//     }
//   }
//
//   final _orientations = {
//     DeviceOrientation.portraitUp: 0,
//     DeviceOrientation.landscapeLeft: 90,
//     DeviceOrientation.portraitDown: 180,
//     DeviceOrientation.landscapeRight: 270,
//   };
//
//   InputImage? _inputImageFromCameraImage(CameraImage image) {
//     final camera = _cameras[0];
//     final sensorOrientation = camera.sensorOrientation;
//     InputImageRotation? rotation;
//     if (Platform.isIOS) {
//       rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
//     } else if (Platform.isAndroid) {
//       var rotationCompensation =
//           _orientations[controller!.value.deviceOrientation];
//       if (rotationCompensation == null) return null;
//       if (camera.lensDirection == CameraLensDirection.front) {
//         // front-facing
//         rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
//       } else {
//         // back-facing
//         rotationCompensation =
//             (sensorOrientation - rotationCompensation + 360) % 360;
//       }
//       rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
//     }
//     if (rotation == null) return null;
//
//     // get image format
//     final format = InputImageFormatValue.fromRawValue(image.format.raw);
//     // validate format depending on platform
//     // only supported formats:
//     // * nv21 for Android
//     // * bgra8888 for iOS
//     if (format == null ||
//         (Platform.isAndroid && format != InputImageFormat.nv21) ||
//         (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;
//
//     // since format is constraint to nv21 or bgra8888, both only have one plane
//     if (image.planes.length != 1) return null;
//     final plane = image.planes.first;
//
//     // compose InputImage using bytes
//     return InputImage.fromBytes(
//       bytes: plane.bytes,
//       metadata: InputImageMetadata(
//         size: Size(image.width.toDouble(), image.height.toDouble()),
//         rotation: rotation, // used only in Android
//         format: format, // used only in iOS
//         bytesPerRow: plane.bytesPerRow, // used only in iOS
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Camera Recognizer',
//           style: TextStyle(
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: purpleColor,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//           child: Column(
//             children: [
//               controller.value.isInitialized
//                   ? Stack(children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Container(
//                           height: size.height - 300,
//                           child: AspectRatio(
//                             child: CameraPreview(controller),
//                             aspectRatio: controller.value.aspectRatio,
//                           ),
//                         ),
//                       ),
//                       Container(
//                           height: size.height - 300,
//                           width: size.width,
//                           padding: EdgeInsets.all(6),
//                           child: Image.asset('assets/image/f1.png')),
//                     ])
//                   : Container(),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 'Fruit in picture is:',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//               ),
//               Container(
//                 width: size.width,
//                 decoration: BoxDecoration(
//                   color: bgLightPurpleColor,
//                   shape: BoxShape.rectangle,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       result,
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ],
//                 ),
//                 padding: EdgeInsets.all(10),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
