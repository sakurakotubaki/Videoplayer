import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

class VideoPlayerModel extends ChangeNotifier {
  VideoPlayerController? videoPlayerController;
  bool isPlaying = false;

  Future playVideo(String videoUrl) async {
    if (videoPlayerController == null) {
      videoPlayerController = VideoPlayerController.network(videoUrl)
        ..addListener(() {
          notifyListeners();
        })
        ..initialize().then((_) {
          notifyListeners();
        });
    } else {
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController!.pause();
      } else {
        videoPlayerController!.initialize();
        videoPlayerController!.play();
      }
    }
    notifyListeners();
  }

  void togglePlaying() {
    isPlaying = !isPlaying;
    if (isPlaying) {
      videoPlayerController!.play();
    } else {
      videoPlayerController!.pause();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }
}
