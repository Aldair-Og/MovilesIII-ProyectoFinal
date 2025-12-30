import 'package:flutter/material.dart';
import 'package:taller1/screens/reproductor_pelicula.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetallePelicula extends StatefulWidget {
  final Map pelicula;

  const DetallePelicula({super.key, required this.pelicula});

  @override
  State<DetallePelicula> createState() => _DetallePeliculaState();
}

class _DetallePeliculaState extends State<DetallePelicula> {
  YoutubePlayerController? _youtubeController;
  String? videoId;

  @override
  void initState() {
    super.initState();

    if (widget.pelicula['trailer'] != null &&
        widget.pelicula['trailer'].toString().isNotEmpty) {
      videoId = YoutubePlayer.convertUrlToId(widget.pelicula['trailer']);

      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId!,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.pelicula['titulo']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_youtubeController != null)
              YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
              )
            else
              Container(
                height: 220,
                color: Colors.grey[900],
                child: const Center(
                  child: Text(
                    "Trailer no disponible",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pelicula['titulo'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Año: ${widget.pelicula['anio']}",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    widget.pelicula['descripcion'],
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReproductorPelicula(
                            url: widget.pelicula['pelicula'],
                            titulo: widget.pelicula['titulo'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_circle),
                    label: const Text("Ver película"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
