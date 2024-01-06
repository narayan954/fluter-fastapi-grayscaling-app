import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Grayscaling App!',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController imageUrlController = TextEditingController();
  String processedImage = '';
  bool isLoading = false;

  Future<void> processImage() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/process_image'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'image_url': imageUrlController.text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String base64Image = data['image'];

        setState(() {
          processedImage = base64Image;
          isLoading = false;
        });

        print('Image processing successful');
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to process image');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Processing App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(labelText: 'Enter Image URL'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                processImage();
              },
              child: Text('Process Image'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : processedImage.isNotEmpty
                    ? Image.memory(
                        base64Decode(processedImage),
                        width: 200,
                        height: 200,
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}
