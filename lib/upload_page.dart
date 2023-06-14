import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:video_upload/model/upload_model.dart';
import 'package:video_upload/sign_in_page.dart';
import 'package:video_upload/video_list.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<VideoUploadModel>(context);
    final fileName = model.videoFile != null
        ? basename(model.videoFile!.path)
        : 'No File Selected';

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await Firebase.initializeApp();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const SignInPage()),
                      (route) => false);
                }
              },
              icon: Icon(Icons.logout))
        ],
        title: Text('動画アップロード'),
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
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoListPage()));
                },
                child: const Text('動画を見る')),
          ],
        ),
      ),
    );
  }
}
