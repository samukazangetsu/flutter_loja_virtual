import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/datas/cart_product.dart';
import 'package:loja_virtual/datas/product_data.dart';
import 'package:loja_virtual/models/cart_model.dart';

class CartTile extends StatelessWidget {
  // Pega as informações do produto
  final CartProduct cartProduct;

  // Construtor
  CartTile(this.cartProduct);
  @override
  Widget build(BuildContext context) {
    // Constrói a parte visual do carrinho
    Widget _buildContent() {

      CartModel.of(context).updatePrices();
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Imagem do produto
          Container(
            padding: EdgeInsets.all(8.0),
            width: 120.0,
            child: Image.network(cartProduct.productData.images[0]),
          ),
          // Informações e botões
          Expanded(
              child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título
                Text(
                  cartProduct.productData.title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                // Tamanho
                Text(
                  "Tamanho: ${cartProduct.size}",
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
                // Preço
                Text("R\$ ${cartProduct.productData.price.toStringAsFixed(2)}",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold)),
                // Botões
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botão de diminuir
                    IconButton(
                      icon: Icon(Icons.remove),
                      color: Theme.of(context).primaryColor,
                      onPressed: cartProduct.quantity > 1 ? () {
                        CartModel.of(context).decProduct(cartProduct);
                      } : null,
                    ),
                    // Quantidade
                    Text(cartProduct.quantity.toString()),
                    // Botão para incrementar
                    IconButton(
                      icon: Icon(Icons.add),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        CartModel.of(context).incProduct(cartProduct);
                      },
                    ),
                    // Botão de remover
                    FlatButton(
                      onPressed: () {
                        CartModel.of(context).removeCartItem(cartProduct);
                      },
                      child: Text("Remover"),
                      textColor: Colors.grey[500],
                    )
                  ],
                )
              ],
            ),
          ))
        ],
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: cartProduct.productData == null
          ? FutureBuilder<DocumentSnapshot>(
              future: Firestore.instance
                  .collection("products")
                  .document(cartProduct.category)
                  .collection("items")
                  .document(cartProduct.pid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Converte o documento recebido do firebase em um ProductData
                  cartProduct.productData =
                      ProductData.fromDocument(snapshot.data);
                  return _buildContent();
                } else {
                  return Container(
                    height: 70.0,
                    child: CircularProgressIndicator(),
                    alignment: Alignment.center,
                  );
                }
              },
            )
          : _buildContent(),
    );
  }
}
