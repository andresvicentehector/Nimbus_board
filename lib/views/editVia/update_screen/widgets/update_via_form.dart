import 'package:Nimbus/template/AppContextExtension.dart';
import 'package:Nimbus/viewModels/editVia/update_screen_VM.dart';
import 'package:Nimbus/views/editVia/update_screen/utils/update_via_form_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_color_picker_wheel/models/button_behaviour.dart';
import 'package:flutter_color_picker_wheel/flutter_color_picker_wheel.dart';
import 'package:select_form_field/select_form_field.dart';

import '../../../../models/ListadoVias/AWS/ViaAWS.dart';
import '../../../../viewModels/bluetoothSetings/backup_functions.dart';

class UpdateViaForm extends StatefulWidget {
  final Vias via;
  final List<String> presas;

  const UpdateViaForm({required this.via, required this.presas});

  @override
  _UpdateViaFormState createState() => _UpdateViaFormState();
}

class _UpdateViaFormState extends State<UpdateViaForm> {
  final _viaFormKey = GlobalKey<FormState>();
  UpdateScreenVM viewModel = UpdateScreenVM();

  late var height;

  @override
  void initState() {
    super.initState();

    viewModel.nameController = TextEditingController(text: widget.via.name);
    viewModel.autorController = TextEditingController(text: widget.via.autor);
    viewModel.dificultadController = widget.via.dificultad;
    viewModel.comentarioController =
        TextEditingController(text: widget.via.comentario);
    viewModel.isBloqueController = widget.via.isbloque!;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _items = [
      {
        'value': "Bloque",
        'label': context.resources.strings.addViaScreenBloqueSelection,
        //'icon': Icon(Icons.fiber_manual_record),
        'textStyle': TextStyle(color: Theme.of(context).colorScheme.primary),
      },
      {
        'value': 'Travesía',
        'label': context.resources.strings.addViaScreenTraveSelection,
        //'icon': Icon(Icons.grade),
      },
    ];
    return Form(
      key: _viaFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textoCabecera(
              context.resources.strings.editViaScreenTraveBloqueTittle,
              context),
          SizedBox(height: 27.0),

          SelectFormField(
              type: SelectFormFieldType.dropdown,
              changeIcon: true,
              dialogTitle: 'Selecciona',
              dialogCancelBtn: 'CANCEL',
              items: _items,
              initialValue: widget.via.isbloque,
              onChanged: (val) => viewModel.setBloque(val),
              validator: (val) {
                viewModel.isBloqueController = val ?? widget.via.isbloque!;
                return null;
              },
              onSaved: (val) =>
                  viewModel.isBloqueController = val ?? widget.via.isbloque!),

          SizedBox(height: 27.0),

          textoCabecera(
              context.resources.strings.editViaScreenNameTraveTittle +
                  (viewModel.isBloqueController == "Bloque"
                      ? "del Bloque"
                      : "de la travesía"),
              context),
          TextFormField(
            controller: viewModel.nameController,
            validator: viewModel.fieldValidator,
          ),
          SizedBox(height: 20.0),
          textoCabecera(
              context.resources.strings.editViaScreenBAutorTraveTittle,
              context),
          TextFormField(
            controller: viewModel.autorController,
            validator: viewModel.fieldValidator,
          ),
          SizedBox(height: 20.0),
          textoCabecera(
              context.resources.strings.editViaScreenDificultyTraveTittle,
              context),
          SizedBox(height: 20.0),

          WheelColorPicker(
            onSelect: (Color newColor) {
              viewModel.setNewColor(newColor);
            },
            behaviour: ButtonBehaviour.clickToOpen,
            defaultColor: Color(widget.via.dificultad),
            animationConfig: fanLikeAnimationConfig,
            colorList: const [
              [
                Colors.black,
              ],
              [Colors.pinkAccent, Colors.pink],
              [
                Colors.orangeAccent,
                Colors.orange,
              ],
              [
                Colors.yellow,
              ],
              [
                Colors.green,
              ],
            ],
            buttonSize: 80,
            pieceHeight: 18,
            innerRadius: 80,
          ),

          SizedBox(height: 25.0),
          Divider(
            thickness: 2.0,
          ),
          SizedBox(height: 25.0),

          textoCabecera(
              context.resources.strings.editViaScreenCommentTraveTittle,
              context),
          TextFormField(
            style:
                DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.9),
            controller: viewModel.comentarioController,
            validator: viewModel.fieldValidator,
            keyboardType: TextInputType.multiline,
            minLines: 1, //Normal textInputField will be displayed
            maxLines: 10, // when user presses enter it will adapt to it
          ),
          SizedBox(height: 25.0),
          textoCabecera(
              widget.via.presas.length.toString() +
                  ' ' +
                  context.resources.strings.editViaScreenNumberHolds,
              context),
          //Text('Presas: \n verde:16711680 \n rojo:65280 \n azul: 255 \n Blanco:16777215 \n amarillo:16776960 \n morado:65535'),
          SizedBox(height: 25.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 104.0),
            child: Container(
              width: double.maxFinite,
              height: 50,
              child: GestureDetector(
                onTap: () async {
                  if (_viaFormKey.currentState!.validate()) {
                    await viewModel.updateInfo(
                        viewModel.nameController.text,
                        viewModel.autorController.text,
                        viewModel.dificultadController,
                        viewModel.comentarioController.text,
                        viewModel.isBloqueController,
                        widget.via.presas,
                        widget.via.sId!);
                    await createBackup(context);
                    await Navigator.pushReplacementNamed(context, '/');
                  }
                },
                child: botonAnyadir(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
