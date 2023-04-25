import 'package:Nimbus/viewModels/escalarVia/escalarVia_VM.dart';
import 'package:Nimbus/views/escalarVia/widgets/escalar_via_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:Nimbus/views/editVia/editPresas_screen/edit_presas_screen.dart';
import 'package:is_lock_screen/is_lock_screen.dart';

import 'package:provider/provider.dart';
import '../../../models/ListadoVias/AWS/ViaAWS.dart';

class EscalarVia extends StatefulWidget {
  final Vias via;
  final BluetoothDevice? server;

  const EscalarVia({
    required this.via,
    required this.server,
  });

  @override
  _EscalarViaState createState() => _EscalarViaState();
}

class _EscalarViaState extends State<EscalarVia> with WidgetsBindingObserver {
  late final _nameController;
  late final _idController;
  late final _autorController;
  late final _dificultadController;
  late final _comentarioController;
  late final _numPresasController;
  late var height;
  double width = 934;

  EscalarViaVM viewModel = EscalarViaVM();

  @override
  void initState() {
    super.initState();
    viewModel.startGoBackHomeTimer(context);
    viewModel.checkDataConnection(context);
    viewModel.connect(widget.server);
    // viewModel.startTimeoutTimer(widget.server);
    _nameController = widget.via.name;
    _idController = widget.via.sId;
    _autorController = widget.via.autor;
    _dificultadController = widget.via.dificultad;
    _comentarioController = Text(widget.via.comentario);
    _numPresasController = widget.via.presas.length;

    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (viewModel.isConnected) {
      viewModel.isDisconnecting = true;
      viewModel.connection?.dispose();
      viewModel.connection = null;
    }
    if (viewModel.isConnecting) {
      viewModel.isDisconnecting = true;
      viewModel.connection?.dispose();
      viewModel.connection = null;
    }

    viewModel.contador = 3;
    viewModel.timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      print('app inactive, is lock screen: ${await isLockScreen()}');
      viewModel.connection?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      print('app resumed');
      viewModel.connect(widget.server);
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width - 20;
    viewModel.showPared(widget.via.presas);

    return ChangeNotifierProvider<EscalarViaVM>(
        create: (BuildContext context) => viewModel,
        child: Consumer<EscalarViaVM>(builder: (context, viewModel, _) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: <Widget>[
                    circulo(_dificultadController),
                    SizedBox(width: 14),
                    descriptivoVia(_nameController, _autorController,
                        _numPresasController, context),
                    SizedBox(width: 15),
                  ],
                ),
                SizedBox(height: 20.0),
                //Text('Comentarios'),
                _comentarioController,
                SizedBox(height: 20.0),

                botoneraCargar(
                    widget.server,
                    viewModel.isConnected,
                    viewModel.isConnecting,
                    viewModel.connectionFailed,
                    viewModel.cargarViaTroncho,
                    widget.via,
                    context),

                Divider(
                  height: 24,
                ),

                esquematicoPared(width, viewModel.pared),
                Divider(
                  height: 24,
                ),
                Row(children: [
                  botonEditar(widget.via.isbloque!, _navigatetoEditPresas,
                      context, viewModel.botonEditarColor),
                  SizedBox(width: 5.0),
                  botonEliminar(
                      context,
                      _nameController,
                      _idController,
                      viewModel.cerrarConexion,
                      viewModel.eliminarVia,
                      viewModel.botonEliminarColor)
                ]),
              ],
            ),
          );
        }));
  }

  _navigatetoEditPresas() {
    viewModel.timer.cancel();
    viewModel.contador = 3;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EditPresas(connection: viewModel.connection, via: widget.via),
      ),
    );
  }
}
