import 'dart:async';
import 'dart:convert';

import 'package:Nimbus/template/colors/ColorsFixed.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../data/response/ApiResponse.dart';
import '../../models/ListadoVias/AWS/ViaAWS.dart';
import '../../repository/vias/ViaRepoImp.dart';
import '../../template/configuration/ConstantesPropias.dart';
import '../../views/escalarVia/widgets/schema_howtoClimb_wallBuilder/wall15_show.dart';
import '../../views/escalarVia/widgets/schema_howtoClimb_wallBuilder/wall25_show.dart';
import 'package:is_lock_screen/is_lock_screen.dart';

class EscalarViaVM extends ChangeNotifier {
  final _myRepo = ViaRepoImp();
  ApiResponse<ViaAWS> viasMain = ApiResponse.loading();

  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();

  late bool isConnecting = false;
  bool get isConnected => (connection?.isConnected ?? false);
  late bool isDisconnecting = false;
  late bool connectionFailed = false;

  late Color botonEditarColor = t_primary;
  late Color botonEliminarColor = t_primary;

  late Widget pared;

  late int contador = 0;

  late Timer timer;

  void initObserverBlockinPage() {}

  void _deleteViasMain(ApiResponse<ViaAWS> response) {
    //print("Response :: $response");
    viasMain = response;
    notifyListeners();
  }

  //the only way to access to movie list from the ui
  Future<void> erraseVia(String id) async {
    print("id " + id);
    if (await InternetConnectionChecker().hasConnection) {
      _deleteViasMain(ApiResponse.loading());

      _myRepo
          .deleteVia(id)
          .then((value) => _deleteViasMain(ApiResponse.completed(value)))
          .onError((error, stackTrace) =>
              _deleteViasMain(ApiResponse.error(error.toString())));
    } else {
      // fetchViasFromHive();
    }
  }

  Future<void> connect(BluetoothDevice? server) async {
    if (server == null) {
      isConnecting = false;
    } else {
      isConnecting = true;
      BluetoothConnection.toAddress(server.address).then((_connection) {
        //print('Connected to the device');
        connection = _connection;

        isConnecting = false;
        isDisconnecting = false;
        notifyListeners();

        connection!.input!.listen(_onDataReceived).onDone(() {
          if (isDisconnecting) {
            print('Disconnecting locally!');
          } else {
            print('Disconnected remotely!');
          }

          notifyListeners();
        });
      }).catchError((error) {
        //print('Cannot connect, exception occured');
        //print(error);
        isConnecting = false;
        if (contador >= 3) {
          connectionFailed = true;
          notifyListeners();
        } else {
          reconnect(server);
          notifyListeners();
        }
        contador++;
      });
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      messages.add(
        _Message(
          1,
          backspacesCounter > 0
              ? _messageBuffer.substring(
                  0, _messageBuffer.length - backspacesCounter)
              : _messageBuffer + dataString.substring(0, index),
        ),
      );
      _messageBuffer = dataString.substring(index);
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
    notifyListeners();
  }

  Future _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;

        messages.add(_Message(clientID, text));
      } catch (e) {
        // Ignore error, but notify state
      }
    }
    notifyListeners();
  }

  Future cargarViaTroncho(List<String> presas) async {
    String troncho = presas.join(",");
    // await _sendMessage("clear");
    // sleep(new Duration(seconds:1));
    await _sendMessage(troncho + ", ");
    //sleep(new Duration(seconds:2));
    //print(troncho + ", ");
  }

  Future<void> cerrarConexion() async {
    isDisconnecting = true;
    notifyListeners();

    await connection?.close();
    //isConnected = false;
    isDisconnecting = false;
    notifyListeners();
  }

  Future eliminarVia(BuildContext context, String id) async {
    //  await box.delete(widget.xKey);
    await erraseVia(id);
    await Navigator.pushReplacementNamed(context, '/');
    notifyListeners();
  }

  Future<void> reconnect(BluetoothDevice? server) async {
    if (isConnected) {
      return;
    }

    if (server == null) {
      return;
    }

    try {
      print('reconecting');
      isConnecting = true;
      await connect(server);
    } catch (e) {
      throw e;
    }
  }

  Future<void> startTimeoutTimer(BluetoothDevice? server) async {
    const timeoutDuration = Duration(seconds: 6);

    Timer(timeoutDuration, () {
      if (isConnecting || isConnected || isDisconnecting) {
        return;
      }

      reconnect(server).catchError((e) {
        print('Failed to reconnect: $e');
      });
    });
    notifyListeners();
  }

  Future<void> startGoBackHomeTimer(BuildContext context) async {
    const timeoutDuration = Duration(minutes: 10);

    timer = Timer(timeoutDuration, () {
      Navigator.pushReplacementNamed(context, 'ListadoScreen');
    });
    notifyListeners();
  }

  void showPared(List<String> presas) {
    if (version == "25") {
      pared = Wall25Show(
        presas: presas,
      );
    } else if (version == "15") {
      pared = Wall15Show(presas: presas);
    }
  }

  void checkDataConnection(BuildContext context) async {
    if (await InternetConnectionChecker().hasConnection) {
      botonEditarColor = Theme.of(context).colorScheme.primary;
      botonEliminarColor = Theme.of(context).colorScheme.primary;
    } else {
      botonEditarColor = t_unactive;
      botonEliminarColor = t_unactive;
    }
    notifyListeners();
  }
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}
