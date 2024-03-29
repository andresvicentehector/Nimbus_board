import 'package:Nimbus/template/AppContextExtension.dart';
import 'package:flutter/material.dart';

Widget textoCabecera(String text, BuildContext context) {
  return Center(
    child: Text(text,
        textAlign: TextAlign.center,
        style: DefaultTextStyle.of(context).style.apply(
            fontFamily: context.resources.fonts.tittle, fontSizeFactor: 1.0)),
  );
}

Widget botonAnyadir(BuildContext context) {
  return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(17)),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Center(
            child: Text(context.resources.strings.editViaScreenButton,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontFamily: context.resources.fonts.tittle,
                )),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 35,
              height: 35,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ));
}
