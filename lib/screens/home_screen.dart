import 'dart:html';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Interpreter _interpreter;
  List? _outputs;
  File? _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    try {
      _interpreter =
      await Interpreter.fromAsset('model.tflite'); // Sửa tên model nếu cần
      print('Interpreter loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  classifyImage(File image) async {
    if (_interpreter == null) {
      print('Interpreter is not initialized');
      return;
    }

    img.Image imageInput = img.decodeImage(image.readAsBytesSync())!;
    img.Image resizedImage = img.copyResize(
        imageInput, width: 224, height: 224); // Điều chỉnh kích thước nếu cần

    var input = resizedImage.getBytes();
    var output = List.filled(1 * 1001, 0).reshape(
        [1, 1001]); // Điều chỉnh output tensor shape nếu cần

    _interpreter.run(input, output);


    setState(() {
      _loading = false;
      _outputs = output;
    });
  }


  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  pickImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = File(image.path as List<Object>);
    });
    classifyImage(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhận diện hình ảnh'),
      ),
      body: _loading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? Container() : Image.file(_image!),
            SizedBox(height: 20),
            _outputs != null ?
            Text(
              //  "${_outputs![0][0]}", // Chỉ hiển thị giá trị đầu tiên
              _outputs.toString(), // Hiển thị toàn bộ output
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  background: Paint()
                    ..color = Colors.white),
            )

                : Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.image),
      ),
    )
    ,
    );
  }
}