import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Widget do fundo
    Widget _buildBodyBack() => Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromARGB(255, 211, 118, 130),
            Color.fromARGB(255, 253, 181, 168)
          ], begin: Alignment.topLeft, end: Alignment.topRight)),
        );

    return Stack(
      children: <Widget>[
        _buildBodyBack(),
        CustomScrollView(
          slivers: <Widget>[
            // AppBar flutuante
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text("Novidades"),
                centerTitle: true,
              ),
            ),
            // Constrói o widget com base num valor futuro declarado no future
            FutureBuilder<QuerySnapshot>(
                future: Firestore.instance
                    .collection("home")
                    .orderBy("pos")
                    .getDocuments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                  // Animação de carregamento
                    return SliverToBoxAdapter(
                      child: Container(
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    );
                  else
                  // Widget grid com medidas
                    return SliverStaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0,
                      // o widget se constrói por uma List
                      // utiliza as informações do firebase para construir as tiles
                      staggeredTiles: snapshot.data.documents.map((doc) {
                        return StaggeredTile.count(
                            doc.data['x'], doc.data['y']);
                      }).toList(),
                      // constrói a grid usando o snapshot (transforma em map e depois em list)
                      children: snapshot.data.documents.map((doc) {
                        return FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: doc.data['image'],
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    );
                })
          ],
        )
      ],
    );
  }
}
