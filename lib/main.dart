import 'package:flutter/material.dart';
import 'package:loja_virtual/models/cart_model.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:loja_virtual/screens/home_screen.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Os widgets dentro do ScopedModel terão acesso ao UserModel e
    // fará modificações de acordo com as mudanças no UserModel
    return ScopedModel<UserModel>(
        // Declara a Model
        model: UserModel(),
        // O corpo do app sera refeito quando o usuário atual mudar
        child: ScopedModelDescendant<UserModel>(builder: (context, child, model) {
          // Outro ScopedModel, dessa vez o do carrinho
          // O carrinho terá acesso ao usuário atual
          return ScopedModel<CartModel>(
              model: CartModel(model),
              child: MaterialApp(
                title: "Sam's Clothing",
                theme: ThemeData(
                  primaryColor: Color.fromARGB(255, 4, 125, 141),
                  primarySwatch: Colors.blue,
                ),
                debugShowCheckedModeBanner: false,
                home: HomeScreen(),
              ));
        }));
  }
}
