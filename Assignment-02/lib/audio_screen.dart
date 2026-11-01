import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioScreen extends StatefulWidget {
  final String audioAsset;

  const AudioScreen({super.key, this.audioAsset = 'Data/audio.mp3'});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  late final AudioPlayer _player;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription? _stateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    // Clear default 'assets/' prefix since our assets are directly at 'Data/'
    AudioCache.instance.prefix = '';

    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });

    _durationSub = _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _positionSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setSource(AssetSource(widget.audioAsset));
    } catch (_) {
      // Handled during playback
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await _player.play(AssetSource(widget.audioAsset));
  }

  Future<void> _pause() async {
    await _player.pause();
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() => _position = Duration.zero);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Music artwork card
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade300, Colors.indigo.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.music_note_rounded : Icons.headset_rounded,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'audio.mp3',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Assignment 2 Local Audio Media',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Timeline Slider
            Slider(
              value: _position.inMilliseconds
                  .clamp(0, _duration.inMilliseconds)
                  .toDouble(),
              max: _duration.inMilliseconds > 0
                  ? _duration.inMilliseconds.toDouble()
                  : 1.0,
              onChanged: (val) {
                _player.seek(Duration(milliseconds: val.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position)),
                  Text(_formatDuration(_duration)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.replay_5),
                  tooltip: 'Rewind 5s',
                  onPressed: () {
                    final target = _position - const Duration(seconds: 5);
                    _player.seek(
                      target > Duration.zero ? target : Duration.zero,
                    );
                  },
                ),
                const SizedBox(width: 12),
                FloatingActionButton.large(
                  heroTag: 'audioPlayPause',
                  onPressed: isPlaying ? _pause : _play,
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.stop),
                  tooltip: 'Stop',
                  onPressed: _stop,
                ),
                const SizedBox(width: 12),
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.forward_5),
                  tooltip: 'Forward 5s',
                  onPressed: () {
                    final target = _position + const Duration(seconds: 5);
                    _player.seek(target < _duration ? target : _duration);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
