import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_project/constants/colors.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_project/main.dart';
import 'package:tflite_project/screens/live_camera_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? image;
  late ImagePicker imagePicker;
  late ImageLabeler imageLabeler;
  late Interpreter interpreter;
  late List<String> labels;
  String results = "";

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    loadModel();
    // loadModelAndLabels();
  }

  // Future<void> loadModelAndLabels() async {
  //   try {
  //     // Load model
  //     final modelPath = await getModelPath('assets/ml/fruits2.tflite');
  //     interpreter = await Interpreter.fromAsset(modelPath);
  //
  //     // Load labels
  //     final labelData = await rootBundle.loadString('assets/ml/labels.txt');
  //     labels = labelData.split('\n');
  //   } catch (e) {
  //     print('Error loading model: $e');
  //   }
  // }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  loadModel()async{
    final modelPath = await getModelPath('assets/ml/mango.tflite');
    final options = LocalLabelerOptions(
      confidenceThreshold: 0.6,
      modelPath: modelPath,
    );
    imageLabeler = ImageLabeler(options: options);
  }

  chooseImage() async {
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      image = File(selectedImage.path);
      performImageLabeling();
      setState(() {
        image;
      });
    }
  }

  captureImage() async {
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (selectedImage != null) {
      image = File(selectedImage.path);
      performImageLabeling();
      setState(() {
        image;
      });
    }
  }

  performImageLabeling() async {
    results = "";
    InputImage inputImage = InputImage.fromFile(image!);

    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      results += "Name: "+text+"\n" + "Confidence: " + confidence.toStringAsFixed(2);
    }
    setState(() {
      results;
    });
  }
  // void classifyImage() async {
  //   if (image == null || interpreter == null) return;
  //
  //   // Load and preprocess the image
  //   final img = File(image!.path);
  //   final inputImage = ImageProcessorBuilder()
  //       .add(ResizeOp(224, 224, ResizeMethod.BILINEAR))
  //       .build()
  //       .processImage(img);
  //
  //   // Allocate buffers
  //   final input = TensorBuffer.createDynamic(TfLiteType.float32);
  //   input.loadImage(inputImage);
  //
  //   final output = TensorBufferFloat(interpreter.getOutputTensor(0).shape);
  //
  //   // Run inference
  //   interpreter.run(input.buffer, output.buffer);
  //
  //   // Get results
  //   final probabilities = output.getDoubleList();
  //   final maxIndex = probabilities.indexWhere((val) => val == probabilities.reduce((a, b) => a > b ? a : b));
  //   results = "Detected: ${labels[maxIndex]} (${(probabilities[maxIndex] * 100).toStringAsFixed(2)}%)";
  //
  //   setState(() {
  //     results;
  //   });
  // }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Image Recognizer',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: purpleColor,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Take a fruit picture',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: size.width,
                height: size.height / 2,
                decoration: BoxDecoration(
                  color: bgLightPurpleColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: image == null
                    ? Icon(
                        Icons.image_outlined,
                        size: 150,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          image!,
                          // fit: BoxFit.cover,
                        ),
                      ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      chooseImage();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(purpleColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: Colors.white,
                        ),
                        Text(
                          ' Choose image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      captureImage();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(purpleColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                        ),
                        Text(
                          ' Take a picture',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen()));
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(purpleColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.video_camera_back_outlined,
                          color: Colors.white,
                        ),
                        Text(
                          ' Live camera footage',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Fruit in picture is:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              results != "" ?
              Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: purpleColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      results,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(10),
              ) :
                  SizedBox(height: 10,),
            ],
          ),
        ));
  }
}
