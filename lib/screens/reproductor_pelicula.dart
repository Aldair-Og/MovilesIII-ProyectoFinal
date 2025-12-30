import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReproductorPelicula extends StatefulWidget {
  final String url;
  final String titulo;

  const ReproductorPelicula({
    super.key,
    required this.url,
    required this.titulo,
  });

  @override
  State<ReproductorPelicula> createState() => _ReproductorPeliculaState();
}

class _ReproductorPeliculaState extends State<ReproductorPelicula> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    void _togglePlay() {
      setState(() {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
      });
    }

    void _seekForward() {
      final position = _controller.value.position;
      _controller.seekTo(position + const Duration(seconds: 10));
    }

    void _seekBackward() {
      final position = _controller.value.position;
      _controller.seekTo(position - const Duration(seconds: 10));
    }

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(widget.titulo)),
      body: _controller.value.isInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),

                // CONTROLES
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // SLIDER
                      Slider(
                        activeColor: Colors.red,
                        inactiveColor: Colors.white24,
                        value: _controller.value.position.inSeconds.toDouble(),
                        max: _controller.value.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          _controller.seekTo(Duration(seconds: value.toInt()));
                        },
                      ),

                      // TIEMPOS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _format(_controller.value.position),
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            _format(_controller.value.duration),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // BOTONES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 36,
                            color: Colors.white,
                            icon: const Icon(Icons.replay_10),
                            onPressed: () {
                              _controller.seekTo(
                                _controller.value.position -
                                    const Duration(seconds: 10),
                              );
                            },
                          ),

                          IconButton(
                            iconSize: 48,
                            color: Colors.red,
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                          ),

                          IconButton(
                            iconSize: 36,
                            color: Colors.white,
                            icon: const Icon(Icons.forward_10),
                            onPressed: () {
                              _controller.seekTo(
                                _controller.value.position +
                                    const Duration(seconds: 10),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.red)),
    );
  }
}
