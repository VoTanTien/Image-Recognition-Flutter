import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_project/constants/colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? image;
  late ImagePicker imagePicker;
  late ImageLabeler labeler;
  String results = "";

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.7);
    labeler = ImageLabeler(options: options);
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

  performImageLabeling() async{
    results = "";
    InputImage inputImage = InputImage.fromFile(image!);

    final List<ImageLabel> labels = await labeler.processImage(inputImage);

    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      results +=text+":    "+confidence.toStringAsFixed(2)+"\n";
    }
    setState(() {
      results;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Image Recognition',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: purpleColor,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                image == null
                    ? Icon(
                        Icons.image_outlined,
                        size: 150,
                      )
                    : Image.file(image!),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        chooseImage();
                      },
                      child: Text('Choose Image'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        captureImage();
                      },
                      child: Text('Capture Image'),
                    ),
                  ],
                ),
                SizedBox(height: 5,),
                Text(results)
              ],
            ),
          ),
        ));
  }
}
