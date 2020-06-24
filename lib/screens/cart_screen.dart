import 'package:flutter/material.dart';
import 'package:loja_virtual/models/cart_model.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:loja_virtual/screens/login_screen.dart';
import 'package:loja_virtual/screens/order_screen.dart';
import 'package:loja_virtual/tiles/cart_tile.dart';
import 'package:loja_virtual/widgets/cart_price.dart';
import 'package:loja_virtual/widgets/discount_card.dart';
import 'package:loja_virtual/widgets/ship_card.dart';
import 'package:scoped_model/scoped_model.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meu Carrinho"), actions: <Widget>[
        // Quantidade de produtos na parte superior direta da tela
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(right: 8.0),
          child: ScopedModelDescendant<CartModel>(
              builder: (context, child, model) {
            // Armazena a quantidade de produtos no carrinho
            int p = model.products.length;
            return Text(
              "${p ?? 0} ${p == 1 ? "ITEM" : "ITENS"}",
              style: TextStyle(fontSize: 17.0),
            );
          }),
        )
      ]),
      body: ScopedModelDescendant<CartModel>(builder: (context, child, model) {
        // Caso CartModel esteja carregando
        if (model.isLoading && UserModel.of(context).isLoggedIn()) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        // Caso o usuário não esteja logado
        else if (!UserModel.of(context).isLoggedIn()) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.remove_shopping_cart,
                    size: 80.0, color: Theme.of(context).primaryColor),
                SizedBox(height: 16.0),
                Text(
                  "Faça o login para adicionar produtos!",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 16.0,
                ),
                SizedBox(
                  height: 44.0,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                    },
                    child: Text("Entrar", style: TextStyle(fontSize: 18.0)),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
            ),
          );
        }
        // Caso o carrinho esteja vazio
        else if (model.products == null || model.products.length == 0) {
          return Center(
            child: Text(
              "Nenhum produto no carrinho!",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          );
          // Caso tenha produtos no carrinho
        } else {
          return ListView(
            children: [
              Column(
                  children: model.products.map((product) {
                return CartTile(product);
              }).toList()),
              DiscountCard(),
              ShipCard(),
              CartPrice(() async {
                String orderId = await model.finishOrder();
                if (orderId != null)
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => OrderScreen(orderId)));
              })
            ],
          );
        }
      }),
    );
  }
}
