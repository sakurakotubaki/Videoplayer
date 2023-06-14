import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class VideoUploadModel extends ChangeNotifier {
  File? videoFile;

  Future selectVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result == null) return;
    final path = result.files.single.path!;

    videoFile = File(path);
    notifyListeners();
  }

  Future uploadVideoToFirebase() async {
    if (videoFile == null) return;

    final fileName = basename(videoFile!.path);
    final destination = 'videos/$fileName';

    final videoRef = FirebaseStorage.instance.ref(destination);
    final metadata = SettableMetadata(contentType: 'video/mp4');
    await videoRef.putFile(videoFile!, metadata);

    final videoUrl = await videoRef.getDownloadURL();

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('videos').doc(uid);
    await docRef.set({'url': videoUrl});

    print('Download-Link:');
    print(videoUrl);
  }
}