import "package:Nimbus/template/AppContextExtension.dart";
import 'package:Nimbus/template/colors/ColorsFixed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../models/ListadoVias/AWS/ViaAWS.dart';
import '../../../template/configuration/ConstantesPropias.dart';

Widget circulo(dynamic _dificultadController) {
  return Container(
    decoration: BoxDecoration(
        shape: BoxShape.circle, color: Color(_dificultadController)),
    width: 120,
    height: 120,
    padding: EdgeInsets.all(10),
  );
}

Widget descriptivoVia(dynamic _nameController, _autorController,
    _numPresasController, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width - 200,
        child: Text(
          _nameController,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              fontSize: context.resources.dimensions.textSizeSMedium),
        ),
      ),
      Text(
        _autorController,
        style: TextStyle(fontFamily: context.resources.fonts.fontMedium),
      ),
      Text(
          _numPresasController.toString() +
              context.resources.strings.homeScreenPresas,
          style: TextStyle(fontFamily: context.resources.fonts.fontMedium)),
    ],
  );
}

Widget botonCargar(BluetoothDevice? server, bool _isConnected,
    bool _isConnecting, bool _connectionFailed, BuildContext context) {
  return Container(
      decoration: BoxDecoration(
          color: (_isConnecting
              ? t_unactive
              : _isConnected
                  ? Theme.of(context).colorScheme.primary
                  : t_unactive),
          borderRadius: BorderRadius.circular(17.0)),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Center(
            child: Text(
                (server == null
                    ? context.resources.strings.escalarViaScreenButtonConnect
                    : (_isConnecting
                        ? context.resources.strings.escalarViaScreenConnecting
                        : _connectionFailed
                            ? context.resources.strings
                                .escalarViaScreenComeBacktoListView
                            : _isConnected
                                ? context.resources.strings
                                    .escalarViaScreenButtonClimb
                                : context.resources.strings
                                    .escalarViaScreenSomeoneisConnected)),
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
                child: _isConnecting
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.tertiary,
                        strokeWidth:
                            2.0 // increase this value to make the indicator bigger
                        )
                    : Icon(
                        _isConnected ? Icons.arrow_forward : Icons.arrow_back,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 20,
                      ),
              ),
            ),
          ),
        ],
      ));
}

Widget botonEditar(String isBloque, Function _gotoEditScreen,
    BuildContext context, Color botonEditarColor) {
  return Expanded(
    flex: 9,
    child: GestureDetector(
      onTap: () async {
        if (await InternetConnectionChecker().hasConnection) {
          _gotoEditScreen();
        }
      },
      child: Container(
          decoration: BoxDecoration(
              color: botonEditarColor,
              borderRadius: BorderRadius.circular(17.0)),
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Center(
                  child: Text(
                      context.resources.strings.escalarViaScreenButtonEdit +
                          (isBloque == "Bloque"
                              ? context.resources.strings
                                  .editViaScreenBloqueSelection
                              : context.resources.strings
                                  .editViaScreenTraveSelection),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontFamily: context.resources.fonts.tittle,
                      ))),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          )),
    ),
  ); //boton de editar
}

Widget botonEliminar(
    BuildContext context,
    dynamic _nameController,
    dynamic _idController,
    Function _cerrarConexion,
    Function _eliminarVia,
    Color botonEliminarColor) {
  return Expanded(
    flex: 2,
    child: GestureDetector(
        onTap: () async {
          if (await InternetConnectionChecker().hasConnection) {
            _cerrarConexion();
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialogEliminar(
                  context, _nameController, _idController, _eliminarVia),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: botonEliminarColor,
              borderRadius: BorderRadius.circular(17.0)),
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Stack(alignment: Alignment.center, children: [
            Container(
              width: 35,
              height: 35,
            ),
            Icon(Icons.delete,
                color: Theme.of(context).colorScheme.tertiary, size: 25),
          ]),
        )),
  ); //botón de eliminar
}

Widget _buildPopupDialogEliminar(BuildContext context, dynamic _nameController,
    dynamic _idController, Function _eliminarVia) {
  return new AlertDialog(
    title: Text(
      _nameController.toString(),
      style: TextStyle(fontFamily: context.resources.fonts.tittle),
    ),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(context.resources.strings.escalarViaScreeDeleteDescription)
      ],
    ),
    actions: <Widget>[
      new ElevatedButton(
        onPressed: () async {
          _eliminarVia(
            context,
            _idController,
          );
        },
        // buttonstyle:(textColor: Theme.of(context).primaryColor),
        child: Text(
          context.resources.strings.escalarViaScreeDeleteDescriptionButton,
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
    ],
  );
}

Widget botoneraCargar(
    BluetoothDevice? server,
    bool isConnected,
    bool isConnecting,
    bool connectionFailed,
    Function _cargarViaTroncho,
    Vias via,
    BuildContext context) {
  return GestureDetector(
      onTap: () async {
        if (isConnected == true) {
          await _cargarViaTroncho(via.presas);
          ViaData = via;
          indexData = via.sId;
        }
      },
      child: botonCargar(
          server, isConnected, isConnecting, connectionFailed, context));
}

Widget esquematicoPared(double width, Widget pared) {
  return Center(
    child: GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: width,
        height: width / 1.5,
        child: Stack(
          children: <Widget>[
            // Container(color: Color.fromARGB(255, 95, 95, 95)),
            Container(
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 95, 95, 95),
                  borderRadius: BorderRadius.circular(17.0),
                  image: DecorationImage(
                    image: AssetImage(paredTrans),
                  )),
            ),
            pared,
          ],
        ),
      ),
    ),
  );
}
