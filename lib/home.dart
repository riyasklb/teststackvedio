import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:teststackvedio/export.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NewsVideoEditor extends StatefulWidget {
  @override
  _NewsVideoEditorState createState() => _NewsVideoEditorState();
}

class _NewsVideoEditorState extends State<NewsVideoEditor> {
  File? _videoFile;
  File? _watermarkImage;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();

  String reporterName = 'Reporter Name';
  String channelName = 'Channel Name';
  String breakingNewsText = 'Breaking News';

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        _videoController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoController?.play();
          });
      });
    }
  }

  Future<void> _pickWatermarkImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _watermarkImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _exportVideo() async {
    if (_videoFile == null || _watermarkImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a video and a watermark image.'),
      ));
      return;
    }

    // Call the export function
    String? outputPath = await exportVideoWithOverlay(
      videoFile: _videoFile!,
      watermarkImage: _watermarkImage!,
      reporterName: reporterName,
      channelName: channelName,
      breakingNewsText: breakingNewsText,
    );

    if (outputPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Video exported successfully: $outputPath'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to export video.'),
      ));
    }
  }

  Future<void> _requestPermissions() async {
    // For Android 11 and above, request manage external storage permission
  if (await Permission.manageExternalStorage.request().isGranted) {
    print('====================Manage external storage permission is granted===========================');
    // Manage external storage permission is granted
  } else {
    // Manage external storage permission is denied
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Manage external storage permission is required to continue.')),
    );
    return;
  }

  }

  @override
  void initState() {
    _requestPermissions();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News Video Editor')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _videoController != null && _videoController!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: Stack(
                    children: [
                      VideoPlayer(_videoController!), // Video at the bottom
                      if (_watermarkImage != null)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Image.file(
                            _watermarkImage!,
                            width: 100,
                            height: 100,
                          ),
                        ), // Watermark Image
                      Positioned(
                        bottom: 40,
                        left: 10,
                        child: Text(
                          reporterName,
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              backgroundColor: Colors.black54),
                        ),
                      ), // Reporter Name
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Text(
                          channelName,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.yellow,
                              backgroundColor: Colors.black54),
                        ),
                      ), // Channel Name
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Text(
                          breakingNewsText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.red,
                              backgroundColor: Colors.black54),
                        ),
                      ), // Breaking News Text
                    ],
                  ),
                )
              : Text('No video selected or video not initialized.'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickVideo,
            child: Text('Pick Video from Gallery'),
          ),
          ElevatedButton(
            onPressed: _pickWatermarkImage,
            child: Text('Pick Watermark Image from Gallery'),
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(labelText: 'Reporter Name'),
            onChanged: (value) {
              setState(() {
                reporterName = value;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Channel Name'),
            onChanged: (value) {
              setState(() {
                channelName = value;
              });
            },
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Breaking News Text'),
            onChanged: (value) {
              setState(() {
                breakingNewsText = value;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _exportVideo,
            child: Text('Export Video'),
          ),
        ],
      ),
    );
  }
}
