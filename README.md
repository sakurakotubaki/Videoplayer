# 動画アップロードアプリ
StatefulWidgetの場合
```dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Firebase Upload',
        theme: ThemeData(primarySwatch: Colors.green),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File? videoFile;

  @override
  Widget build(BuildContext context) {
    final fileName = videoFile != null ? basename(videoFile!.path) : 'No File Selected';

    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Upload'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: selectVideo,
              child: Text('Select Video'),
            ),
            SizedBox(height: 8),
            Text(
              fileName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 48),
            ElevatedButton(
              onPressed: uploadVideoToFirebase,
              child: Text('Upload Video'),
            ),
          ],
        ),
      ),
    );
  }

  Future selectVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => videoFile = File(path));
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
```

プロバイダーの場合
```dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => VideoUploadModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Firebase Upload',
        theme: ThemeData(primarySwatch: Colors.green),
        home: MainPage(),
      );
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<VideoUploadModel>(context);
    final fileName = model.videoFile != null ? basename(model.videoFile!.path) : 'No File Selected';

    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Upload'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: model.selectVideo,
              child: Text('Select Video'),
            ),
            SizedBox(height: 8),
            Text(
              fileName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 48),
            ElevatedButton(
              onPressed: model.uploadVideoToFirebase,
              child: Text('Upload Video'),
            ),
          ],
        ),
      ),
    );
  }
}

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
```

## 本格的なものを作る場合
userコレクションがあって、その配下にサブコレクションとして、動画のパスを保存するコレクションを作った方が良いと思われます。.setだとデータが上書きされます。

```dart
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
    // addにしないと、同じユーザーが複数の動画をアップロードしたときに、
    // 前の動画が上書きされてしまう。
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('videos');
    await docRef.add({'url': videoUrl});

    print('Download-Link:');
    print(videoUrl);
  }
}
```