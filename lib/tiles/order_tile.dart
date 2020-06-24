// Tile de cada pedido
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  final String orderId;

  OrderTile(this.orderId);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        // Atualiza de acordo com as alterações no banco de dados
        child: StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection("orders")
                .document(orderId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else {
                // pega o status no bd
                int status = snapshot.data["status"];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Código do pedido
                    Text(
                      "Código do pedido: ${snapshot.data.documentID}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(_buildProductsText(snapshot.data)),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      "Status do Pedido:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    // Bolinhas de estado do pedido
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircle("1", "Preparação", status, 1),
                        Container(
                          height: 1.0,
                          width: 40.0,
                          color: Colors.grey[500],
                        ),
                        _buildCircle("2", "Transporte", status, 2),
                        Container(
                          height: 1.0,
                          width: 40.0,
                          color: Colors.grey[500],
                        ),
                        _buildCircle("3", "Entrega", status, 3),
                      ],
                    )
                  ],
                );
              }
            }),
      ),
    );
  }

  // Constrói textos da descrição
  String _buildProductsText(DocumentSnapshot snapshot) {
    String text = "Descrição:\n";
    for (LinkedHashMap p in snapshot.data["products"]) {
      text +=
          "${p["quantity"]} x ${p["product"]["title"]} (R\$ ${p["product"]["price"].toStringAsFixed(2)})\n";
    }
    text += "Total: R\$ ${snapshot.data["totalPrice"].toStringAsFixed(2)}";

    return text;
  }

  // Widget para construir as bolinhas de estado
  Widget _buildCircle(
      String title, String subtitle, int status, int thisStatus) {
    Color backColor;
    Widget child;

    // Caso o produto esteja em preparação
    if (status < thisStatus) {
      backColor = Colors.grey[500];
      child = Text(
        title,
        style: TextStyle(color: Colors.white),
      );
      // Caso o produto saia para entrega
    } else if (status == thisStatus) {
      backColor = Colors.blue;
      child = Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
        ],
      );
      // Caso a entrega já tenha sido realizada
    } else {
      backColor = Colors.green;
      child = Icon(Icons.check, color: Colors.white,);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 20.0,
          backgroundColor: backColor,
          child: child,
        ),
        Text(subtitle),
      ],
    );
  }
}
