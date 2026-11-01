import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final String videoAssetPath;

  const VideoScreen({
    super.key,
    this.videoAssetPath = 'Data/gemini_generated_video_5418c219.mp4',
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoAssetPath);
      await _controller.initialize();
      _controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error loading video: $_errorMessage',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (!_isInitialized)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading video media...'),
                ],
              )
            else
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller),
                          // Overlay play/pause tap
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.play();
                                }
                              });
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: !_controller.value.isPlaying
                                  ? Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Timeline Slider
                  Slider(
                    value: _controller.value.position.inMilliseconds
                        .clamp(0, _controller.value.duration.inMilliseconds)
                        .toDouble(),
                    max: _controller.value.duration.inMilliseconds.toDouble(),
                    onChanged: (val) {
                      _controller.seekTo(Duration(milliseconds: val.toInt()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_controller.value.position)),
                        Text(_formatDuration(_controller.value.duration)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.replay_5),
                        onPressed: () {
                          final target =
                              _controller.value.position -
                              const Duration(seconds: 5);
                          _controller.seekTo(
                            target > Duration.zero ? target : Duration.zero,
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton(
                        heroTag: 'videoPlayPause',
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.forward_5),
                        onPressed: () {
                          final target =
                              _controller.value.position +
                              const Duration(seconds: 5);
                          _controller.seekTo(
                            target < _controller.value.duration
                                ? target
                                : _controller.value.duration,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
