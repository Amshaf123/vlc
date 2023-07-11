import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../General/app_colors.dart';
import '../Provider/video_player_provider.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key, required this.video}) : super(key: key);
  final String video;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}
class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController playerController;
  bool isFullScreen = false;
  bool isPlaying = true;
  late Timer sliderTimer;
  bool isForwarding = false;
  bool isRewinding = false;

  @override
  void initState() {
    Provider.of<VideoPlayerProvider>(context, listen: false).sliderValue = 0.0;
    FullScreenWindow.setFullScreen(true);
    super.initState();
    playerController = VideoPlayerController.file(File(widget.video))
      ..initialize().then((_) {
        playerController.play();
        setState(() {
          isPlaying = true;
        });
      });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    playerController.addListener(() {
      if (playerController.value.isPlaying) {
        Provider.of<VideoPlayerProvider>(context, listen: false).sliderValue =
            playerController.value.position.inSeconds.toDouble();
      }
    });
    startSliderTimer();
  }

  @override
  void dispose() {
    playerController.pause();
    playerController.dispose();
    FullScreenWindow.setFullScreen(false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    sliderTimer.cancel();
    super.dispose();
  }

  void togglePlayPause() {
    if (isPlaying) {
      playerController.pause();
    } else {
      playerController.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void onSliderChanged(double value) {
    setState(() {
      Provider.of<VideoPlayerProvider>(context, listen: false).sliderValue = value;
      playerController.seekTo(Duration(seconds: value.toInt()));
    });
  }

  void startSliderTimer() {
    sliderTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (playerController.value.isPlaying) {
        Provider.of<VideoPlayerProvider>(context, listen: false)
            .setSliderValue(playerController.value.position.inSeconds.toDouble());
      }
    });
  }

  String formatDuration(Duration duration) {
    String hours = (duration.inHours % 24).toString();
    String minutes =
        (duration.inMinutes.remainder(60)).toString().padLeft(2, '0');
    String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours == '0') {
      return '$minutes:$seconds';
    } else {
      return '${hours.padLeft(2, '')}:$minutes:$seconds';
    }
  }

  void forwardVideo() {
    log('Forwarding video');
    setState(() {
      isForwarding = true;
    });
    final currentPosition = playerController.value.position;
    final targetPosition = currentPosition + const Duration(seconds: 30);
    playerController.seekTo(targetPosition);
    startSliderTimer();
  }

  void rewindVideo() {
    log('Rewinding video');
    setState(() {
      isRewinding = true;
    });
    final currentPosition = playerController.value.position;
    final targetPosition = currentPosition - const Duration(seconds: 30);
    playerController.seekTo(targetPosition);
    startSliderTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onDoubleTap: () {
          forwardVideo();
        },
        onDoubleTapDown: (_) {
          rewindVideo();
        },
        onDoubleTapCancel: () {
          setState(() {
            isForwarding = false;
            isRewinding = false;
          });
          startSliderTimer();
        },
        onTap: () {
          Provider.of<VideoPlayerProvider>(context, listen: false).hideControls();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (playerController.value.isInitialized)
              AspectRatio(
                aspectRatio: playerController.value.aspectRatio,
                child: VideoPlayer(playerController),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: Provider.of<VideoPlayerProvider>(context, listen: false).isControls
                    ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                )
                    : null,
              ),
            ),
            if (!playerController.value.isInitialized)
              const Center(child: CircularProgressIndicator()),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Consumer<VideoPlayerProvider>(
                builder: (context, videoPlayerProvider, _) => Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 70,
                          child: Text(
                            formatDuration(playerController.value.position),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 5),
                        CustomVideoPlayerProgressBarSettings(
                          
                        )
                        VideoProgressIndicator(playerController, allowScrubbing: true,)
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColor.appColor,
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                              thumbColor: AppColor.appColor,
                              overlayColor: AppColor.appColor.withOpacity(0.2),
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 5.0),
                            ),
                            child: Slider(
                              value: videoPlayerProvider.sliderValue,
                              min: 0.0,
                              max: playerController.value.duration.inSeconds.toDouble(),
                              onChanged: onSliderChanged,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          alignment: Alignment.center,
                          width: 70,
                          child: Text(
                            formatDuration(playerController.value.duration),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          color: Colors.white,
                          iconSize: 50,
                          onPressed: togglePlayPause,
                          icon: isPlaying
                              ? const Icon(Icons.pause_circle_outline_outlined)
                              : const Icon(Icons.play_circle_outline_rounded),
                        ),
                        IconButton(
                          color: Colors.white,
                          iconSize: 30,
                          onPressed: () {
                          playerController.seekTo( Duration(seconds:videoPlayerProvider.sliderValue.toInt()+ 60));
                        setState(() {
                          
                        });
                        
                        
                          },
                          //forword 10s
                          icon: const Icon(Icons.forward_10_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
