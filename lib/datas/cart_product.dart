// Classe para construir os produtos do carrinho

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/datas/product_data.dart';

class CartProduct {
  // id do carrinho
  String cid;

  // Categoria do produto
  String category;

  //Titulo do produto
  String ptitle;

  // id do produto
  String pid;

  // quantidade do produto
  int quantity;

  // Tamanho do produto
  String size;

  // Armazena os dados do produto para serem carregados ao abrir o app
  ProductData productData;

  CartProduct();

  // Transforma o carrinho da conta em um CartProduct
  CartProduct.fromDocument(DocumentSnapshot document){
    cid = document.documentID;
    category = document.data["category"];
    pid = document.data["pid"];
    ptitle = document.data["ptitle"];
    quantity = document.data["quantity"];
    size = document.data["size"];
  }

  // Transforma as informações num Map para gravar no banco de dados
  Map<String, dynamic> toMap(){
    return {
      "category": category,
      "pid": pid,
      "quantity": quantity,
      "size": size,
      // salva um resumo do produto
      "product": productData.toResumeMap() 
    };
  }
}