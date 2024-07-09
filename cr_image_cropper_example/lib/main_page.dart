import 'dart:io';

import 'package:cr_image_cropper/cr_image_cropper.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File? _image;
  File? _croppedImage;
  final androidUiSettings = AndroidUiSettings(
    toolbarTitle: 'Crop image',
    toolbarColor: Colors.blue,
    toolbarWidgetColor: Colors.white,
  );

  final iOSUiSettings = IOSUiSettings(
    minimumAspectRatio: 1,
    title: 'Crop image',
    aspectRatioLockEnabled: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image cropper example'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSelectionDialog(context);
        },
        child: Icon(Icons.image),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: _croppedImage == null ? SizedBox() : _croppedImageWidget(),
          ),
          _croppedImage == null
              ? SizedBox()
              : Text(
                  'Cropped image size: ${(_croppedImage!.lengthSync() / 1000000).toStringAsFixed(2)} MB'),
          _image == null
              ? SizedBox()
              : Text(
                  'Original image size: ${(_image!.lengthSync() / 1000000).toStringAsFixed(2)} MB'),
        ],
      ),
    );
  }

  void _showSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Material(
        child: Center(
          child: Container(
            height: 250,
            width: 300,
            child: Column(
              children: <Widget>[
                Text('Select image source:'),
                ElevatedButton(
                  onPressed: () {
                    _pickImageAndCrop(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                  child: Text('Camera'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _pickImageAndCrop(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                  child: Text('Gallery'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickImageAndCrop(ImageSource source) async {
    final cropper = CrCropper(
      iOSSettings: iOSUiSettings,
      androidUiSettings: androidUiSettings,
      maxWidth: 2000,
      maxHeight: 2000,
      cropCompressQuality: 100,
    );
    _croppedImage =
        await cropper.pickAndCropImage(source, useFilePicker: false);
    setState(() {});
  }

  Widget _croppedImageWidget() {
    if (_croppedImage != null) {
      return Image.file(_croppedImage!);
    } else {
      return SizedBox();
    }
  }
}
