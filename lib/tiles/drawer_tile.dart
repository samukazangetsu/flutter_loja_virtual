import 'package:flutter/material.dart';

// tile que constrói os menus Início, Produtos, Lojas e Meus Pedidos
class DrawerTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final PageController controller;
  final int page;

  const DrawerTile(this.icon, this.text, this.controller, this.page);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      // Funciona como um botão
      child: InkWell(
        onTap: () {
          // No onTap ele navega para a página armazenada no int passado pelo drawer clicado
          Navigator.of(context).pop();
          controller.jumpToPage(page);
        },
        child: Container(
          height: 60.0,
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: 32.0,
                color: controller.page.round() == page
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              SizedBox(
                width: 32.0,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16.0,
                  color: controller.page.round() == page
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
