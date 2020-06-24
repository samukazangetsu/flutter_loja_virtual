import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

// É preciso extender a classe Model para usar o ScopedModel
class UserModel extends Model {
  // Usuário Atual

  // Cria o objeto _auth que instancia o FirebaseAuth.instance
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Objeto para obter o usuário
  FirebaseUser firebaseUser;

  // Map para armazenar as principais informações do usuário
  Map<String, dynamic> userData = Map();

  bool isLoading = false;

  // Cria o método estático UserModel.of(context) para acessar o UserModel de qualquer lugar do código
  static UserModel of(BuildContext context) =>
      ScopedModel.of<UserModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    _loadCurrentUser();
  }

  // Função para criar conta
  void signUp(
      {@required Map<String, dynamic> userData,
      @required String pass,
      @required VoidCallback onSucces,
      @required VoidCallback onFail}) {
    isLoading = true;
    notifyListeners();

    // Tenta realizar a criação do usuário
    _auth
        .createUserWithEmailAndPassword(
            email: userData["email"], password: pass)

        // Função caso a criação seja efetuada com sucesso
        .then((user) async {
      firebaseUser = user;

      // Espera salvar os dados no firebase
      await _saveUserData(userData);

      onSucces();
      isLoading = false;
      notifyListeners();

      // Função caso a criação do usuário apresente algum erro
    }).catchError((e) {
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  // Função para fazer login
  signIn(
      {@required String email,
      @required String pass,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail}) async {
    isLoading = true;
    notifyListeners();

    _auth
        .signInWithEmailAndPassword(email: email, password: pass)
        .then((user) async {
      firebaseUser = user;

      await _loadCurrentUser();

      onSuccess();
      isLoading = false;
      notifyListeners();
    }).catchError((e) {
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  // Função para fazer logout
  void signOut() async {
    await _auth.signOut();

    userData = Map();
    firebaseUser = null;

    notifyListeners();
  }

  // Função para recuperar senha
  void recoverPass(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  // Função para verificar se o usuário está logado
  bool isLoggedIn() {
    return firebaseUser != null;
  }

  // Função para gravar os dados do usuário no firebase
  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .setData(userData);
  }

  // Função para pegar os dados do usuário atual
  Future<Null> _loadCurrentUser() async {
    if (firebaseUser == null) firebaseUser = await _auth.currentUser();
    if (firebaseUser != null) {
      if (userData["name"] == null) {
        DocumentSnapshot docUser = await Firestore.instance
            .collection("users")
            .document(firebaseUser.uid)
            .get();
        userData = docUser.data;
      }
    }
    notifyListeners();
  }
}
