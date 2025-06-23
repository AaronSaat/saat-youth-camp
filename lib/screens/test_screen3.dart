import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/api_service.dart';

class TestScreen3 extends StatefulWidget {
  @override
  _TestScreen3State createState() => _TestScreen3State();
}

class _TestScreen3State extends State<TestScreen3> {
  File? _imageFile;
  String _status = 'No image selected';
  String? _fetchedImageUrl;
  List<Map<String, dynamic>> _dataImage = [];
  String _dataImageString = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _status = 'Image selected';
      });
    } else {
      setState(() {
        _status = 'No image selected';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      setState(() {
        _status = 'Please select an image first';
      });
      return;
    }

    setState(() {
      _status = 'Uploading...';
    });

    try {
      final result = await ApiService.postImage(
        context,
        _imageFile!.path,
        body: {'user_id': '2', 'kategori_id': '2'},
      );
      setState(() {
        _status = 'Upload successful: ${result['message'] ?? ''}';
      });
    } catch (e) {
      setState(() {
        _status = 'Upload failed: $e';
      });
    }
  }

  Future<void> _fetchImageFromApi() async {
    setState(() {
      _status = 'Loading image from API...';
    });

    try {
      final brm = await ApiService.getimage(context);
      if (!mounted) return;
      setState(() {
        final dataImage = brm['data_brm'];
        print('Data Image: $_dataImage');
        final files = brm['files'];
        if (files != null && files is List && files.isNotEmpty) {
          final firstFile = files[3];
          _dataImageString = firstFile['direktori_file']?.toString() ?? '';
          _dataImage = [firstFile];
          _fetchedImageUrl =
              'http://172.172.52.9/website_backup/${_dataImageString}';
        } else {
          _dataImage = [];
          _dataImageString = '';
          _fetchedImageUrl = null;
        }
        print('Data Image String: $_fetchedImageUrl');
        _status = 'Image loaded from API';
      });
    } catch (e) {
      setState(() {
        _status = 'Image failed to load from API';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Upload Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickImage, child: Text('Select Image')),
            SizedBox(height: 16),
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : Container(height: 200, color: Colors.grey[200]),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchImageFromApi,
              child: Text('Load Image from API'),
            ),
            SizedBox(height: 16),
            _fetchedImageUrl != null
                ? Image.network(
                  // 'https://sysbksaat.seabs.ac.id/uploads/20250623092248_LOGO%20STORY%20PNG.png',
                  // 'http://172.172.52.9/website_backup/uploads/20250623092627_LOGO%20STORY%20PNG.png',
                  // 'https://picsum.photos/250?image=9',
                  _fetchedImageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                : Container(
                  child: Text('No image loaded from API'),
                  height: 200,
                  color: Colors.grey[200],
                ),
            SizedBox(height: 16),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
