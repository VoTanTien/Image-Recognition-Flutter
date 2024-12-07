import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class CameraScreen extends StatefulWidget{
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> cameras = [];
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    _setupCameraController();

  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if(_cameras.isNotEmpty){
      setState(() {
        cameras = _cameras;
        controller = CameraController(_cameras[0], ResolutionPreset.max);
      });
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        controller.startImageStream((image) {
          print(image.width.toString()+"    "+image.height.toString());
        });
        setState(() {});
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
            // Handle access errors here.
              break;
            default:
            // Handle other errors here.
              break;
          }
        }
      });
    }
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
        child: controller.value.isInitialized ? CameraPreview(controller): Container(),
      ),
    );
  }
}