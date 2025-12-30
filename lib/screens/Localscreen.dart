import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:taller1/screens/detalle_pelicula.dart';

class Localscreen extends StatelessWidget {
  const Localscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Películas"),
        automaticallyImplyLeading: false, 
      ),
      body: listaPeliculas(context),
    );
  }
}

Future<List<dynamic>> leerLista(BuildContext context) async {
  final jsonString = await DefaultAssetBundle.of(
    context,
  ).loadString("assets/data/peliculas1.json");

  final Map<String, dynamic> jsonData = json.decode(jsonString);
  return jsonData['peliculas'];
}

Widget listaPeliculas(BuildContext context) {
  return FutureBuilder(
    future: leerLista(context),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        List data = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      backgroundColor: Colors.black,
                      body: DetallePelicula(pelicula: item),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(item['image'], fit: BoxFit.cover),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        item['titulo'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    },
  );
}
