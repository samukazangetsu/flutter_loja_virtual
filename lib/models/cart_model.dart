// Classe para gerenciar as funções de adicionar, deletar, pegar user atual

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/datas/cart_product.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  UserModel user;

  // Lista para armazenar os produtos do carrinho
  List<CartProduct> products = [];

  String couponCode;
  int discountPercentage = 0;

  bool isLoading = false;

  bool hasItem = false;

  CartModel(this.user) {
    if (user.isLoggedIn()) _loadCartItems();
  }

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  // Adiciona um novo produto no carrinho
  void addCartItem(CartProduct cartProduct) {
    products.add(cartProduct);
    // Adiciona ao banco de dados
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .add(cartProduct.toMap())
        .then((doc) {
      // Salva o ID que o firebase cria como cid
      cartProduct.cid = doc.documentID;
    });
    notifyListeners();
  }

  // Remove um produto do carrinho
  void removeCartItem(CartProduct cartProduct) {
    // Remove do banco de dados
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .delete();

    // Remove da lista
    products.remove(cartProduct);

    notifyListeners();
  }

  // Adiciona mais um produto ao carrinho
  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity--;
    _uptadeItems(cartProduct);
  }

  // Decrementa um produto no carrinho
  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity++;
    _uptadeItems(cartProduct);
  }

  // Carrega os produtos do carrinho
  void _loadCartItems() async {
    QuerySnapshot query = await Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .getDocuments();

    products =
        query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();

    notifyListeners();
  }

  // Verifica se já existe um produto igual no carrinho
  Future verifyProduct(cartProduct) async {
    isLoading = true;
    for (var item in products) {
      if (cartProduct.ptitle == item.ptitle && cartProduct.size == item.size) {
        // Se já existe um produto igual, atualiza a informação no firebase
        item.quantity++;
        isLoading = false;
        hasItem = true;
        _uptadeItems(item);
        break;
      }
    }
    // Se não tem um item igual, adiciona ao carrinho
    if (!hasItem) {
      addCartItem(cartProduct);
      isLoading = false;
      hasItem = false;
    } else {
      isLoading = false;
      hasItem = false;
    }
  }

  // Função para inserir cupom de desconto
  void setCoupon(String couponCode, int discountPercentage) {
    this.couponCode = couponCode;
    this.discountPercentage = discountPercentage;
    notifyListeners();
  }

  void updatePrices() {
    notifyListeners();
  }

  // Retorna subtotal
  double getProductsPrice() {
    double price = 0.0;
    for (CartProduct c in products) {
      if (c.productData != null) price += c.quantity * c.productData.price;
    }
    return price;
  }

  // Retorna disconto
  double getDiscount() {
    return getProductsPrice() * discountPercentage.toDouble() / 100;
  }

  // Retorna preço do frete
  double getShipPrice() {
    return 9.99;
  }

  // Função para finalizar pedidos
  Future<String> finishOrder() async {
    if (products.length == 0) return null;

    isLoading = true;
    notifyListeners();
    double productsPrice = getShipPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscount();

    // Salva o pedido no Firebase
    DocumentReference refOrder =
        await Firestore.instance.collection("orders").add({
      "clientId": user.firebaseUser.uid,
      "products": products.map((CartProduct) => CartProduct.toMap()).toList(),
      "shipPrice": shipPrice,
      "productsPrice": productsPrice,
      "discount": discount,
      "totalPrice": productsPrice - discount + shipPrice,
      "status": 1
    });

    // Salva o id do pedido no registro do usuário
    await Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("orders")
        .document(refOrder.documentID)
        .setData({"oderId": refOrder.documentID});

    // Exclui os itens do carrinho
    QuerySnapshot query = await Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .getDocuments();
    for (DocumentSnapshot doc in query.documents) {
      doc.reference.delete();
    }

    products.clear();

    couponCode = null;
    discountPercentage = 0;

    isLoading = false;
    notifyListeners();

    return refOrder.documentID;
  }

  // Faz update do carrinho no Firebase
  void _uptadeItems(CartProduct cartProduct) {
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }
}
