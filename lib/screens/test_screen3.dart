import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TestScreen3 extends StatefulWidget {
  @override
  _TestScreen3State createState() => _TestScreen3State();
}

class _TestScreen3State extends State<TestScreen3> {
  File? _imageFile;
  String _status = 'No image selected';

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

    var uri = Uri.parse('https://your-api-url.com/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        setState(() {
          _status = 'Upload successful';
        });
      } else {
        setState(() {
          _status = 'Upload failed: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
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
            _imageFile != null ? Image.file(_imageFile!, height: 200) : Container(height: 200, color: Colors.grey[200]),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _uploadImage, child: Text('Upload Image')),
            SizedBox(height: 16),
            Text(_status),

            // scatter chart example
            ScatterChart(
              ScatterChartData(
                scatterSpots: [
                  ScatterSpot(2, 3),
                  ScatterSpot(4, 7),
                  ScatterSpot(6, 2),
                  ScatterSpot(8, 5),
                  ScatterSpot(3, 8),
                ],
                minX: 0,
                maxX: 10,
                minY: 0,
                maxY: 10,
                borderData: FlBorderData(show: true),
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
