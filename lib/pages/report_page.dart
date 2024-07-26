import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto_emel_cm/data/incidentes_database.dart';
import 'package:provider/provider.dart';
import '../data/parque_database.dart';
import '../model/parque.dart';
import '../model/report.dart';
import '../repository/parques_repository.dart';
import 'dart:io';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? nome;
  int gravidade = 1;
  DateTime? data;
  TimeOfDay? hora;
  String notas = "";
  bool isSubmitEnabled = false;
  XFile? _pickedImage;
  List<Parque> parques = [];
  bool isLoading = true;

  Future<void> _pickImage() async {
    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
        _updateSubmitButtonState();
      });
    }
  }

  Future<void> _initializeAndLoadReports() async {
    final database = IncidentesDatabase.instance;
    await database.database;
  }

  Future<void> _loadParques() async {
    final repository = context.read<ParquesRepository>();
    final database = ParqueDatabase.instance;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      parques = await database.getParques();
    } else {
      parques = await repository.getParques();
    }

    setState(() {
      isLoading = false;
      if (parques.isNotEmpty) {
        nome = parques.first.nome;
      }
      _updateSubmitButtonState();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadParques();
    _initializeAndLoadReports();
  }

  List<DropdownMenuItem<String>> _getDropdownMenuItems() {
    return parques.map((parque) => DropdownMenuItem(
      value: parque.nome,
      child: Text(parque.nome),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '*Parque',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                      value: nome,
                      items: _getDropdownMenuItems(),
                      onChanged: (value) {
                        setState(() {
                          nome = value;
                          _updateSubmitButtonState();
                        });
                      },
                      hint: Text('Selecionar Parque'),
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '*Gravidade',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    DropdownButtonFormField<int>(
                      value: gravidade,
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(" 1 - Leve"),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(" 2 - Moderada"),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text(" 3 - Grave"),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text(" 4 - Muito Grave"),
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text(" 5 - Extremamente Grave"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          gravidade = value!;
                          _updateSubmitButtonState();
                        });
                      },
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '*Data',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _selectDate(context);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              child: Text(data != null
                                  ? "${data!.day.toString().padLeft(2, '0')}/${data!.month.toString().padLeft(2, '0')}/${data!.year}"
                                  : 'Selecionar Data'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '*Hora',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _selectTime(context);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              child: Text(hora != null
                                  ? "${hora!.hour.toString().padLeft(2, '0')}:${hora!.minute.toString().padLeft(2, '0')}"
                                  : 'Selecionar Hora'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Notas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Notas",
                      ),
                      onChanged: (value) {
                        setState(() {
                          notas = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' Fotografias',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 75,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _pickedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                        )
                            : Center(
                          child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      '* Campos obrigatórios',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isSubmitEnabled
                          ? () async {
                        List<Parque> parquesList = await context.read<ParquesRepository>().getParques();
                        String selectedParqueId = parquesList.firstWhere((parque) => parque.nome == nome).id;
                        IncidentesDatabase.instance.insert(Report(
                          id: '${Random().nextInt(100)}',
                          parqueId: selectedParqueId,
                          gravidade: gravidade,
                          data: data!,
                          hora: hora!,
                          notas: notas,
                          imagePath: _pickedImage?.path,
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Dados salvos com sucesso!"),
                            backgroundColor: Colors.greenAccent[700],
                          ),
                        );
                      }
                          : null,
                      child: Text(
                        'Submeter',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: data ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != data) {
      setState(() {
        data = picked;
        _updateSubmitButtonState();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: hora ?? TimeOfDay.now(),
    );
    if (picked != null && picked != hora) {
      setState(() {
        hora = picked;
        _updateSubmitButtonState();
      });
    }
  }

  void _updateSubmitButtonState() {
    setState(() {
      isSubmitEnabled = nome != null && data != null && hora != null;
    });
  }
}