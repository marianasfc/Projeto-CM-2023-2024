import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/reportGira_database.dart';
import '../main.dart';
import '../model/Gira.dart';
import '../model/ReportGira.dart';
import '../repository/gira_repository.dart';

class ReportGiraPage extends StatefulWidget {
  final String? initialStation;

  const ReportGiraPage({super.key, this.initialStation});

  @override
  State<ReportGiraPage> createState() => _ReportGiraPageState();
}

class _ReportGiraPageState extends State<ReportGiraPage> {
  String? nome;
  String? tipoProblema;
  String notas = "";
  bool isSubmitEnabled = false;
  List<Gira> giras = [];
  bool isLoading = true;

  Future<void> _initializeAndLoadReports() async {
    final database = ReportGiraDatabase.instance;
    await database.database;
  }

  Future<void> _loadGiras() async {
    final repository = context.read<GiraRepository>();
    giras = await repository.getGiras();
    final uniqueGiras = giras.toSet().toList();

    setState(() {
      isLoading = false;
      giras = uniqueGiras;
      if (giras.isNotEmpty && (nome == null || !giras.any((p) => p.nome == nome))) {
        nome = widget.initialStation ?? giras.first.nome;
      }
      _updateSubmitButtonState();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadGiras();
    _initializeAndLoadReports();

    if (widget.initialStation != null) {
      setState(() {
        nome = widget.initialStation;
        _updateSubmitButtonState();
      });
    }
  }

  List<DropdownMenuItem<String>> _getDropdownMenuItems() {
    return giras.map((gira) => DropdownMenuItem(
      value: gira.nome,
      child: Text(gira.nome),
    )).toList();
  }

  List<DropdownMenuItem<String>> _getProblemDropdownItems() {
    const problemas = [
      "Bicicleta vandalizada",
      "Doca não libertou bicicleta",
      "Outra situação",
    ];
    return problemas.map((problema) => DropdownMenuItem(
      value: problema,
      child: Text(problema),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.greenAccent[700],
          onPressed: () {
            Navigator.pop(context);
            context.read<MainPageViewModel>().selectedIndex = 3;
          },
        ),
        title: Text(
          'Reportar',
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
              color: Colors.greenAccent[700],
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
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
                      '*Estação GIRA',
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
                    hint: Text('Selecionar Estação GIRA'),
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
                      '*Tipo de problema',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: tipoProblema,
                    items: _getProblemDropdownItems(),
                    onChanged: (value) {
                      setState(() {
                        tipoProblema = value;
                        _updateSubmitButtonState();
                      });
                    },
                    hint: Text('Selecionar Tipo de Problema'),
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
                      '*Notas',
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
                        _updateSubmitButtonState();
                      });
                    },
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
                      try {
                        List<Gira> girasList = await context.read<GiraRepository>().getGiras();
                        String selectedGiraId = girasList.firstWhere((gira) => gira.nome == nome).id;
                        ReportGira newReport = ReportGira(
                          id: '${Random().nextInt(100)}',
                          giraId: selectedGiraId,
                          notas: notas,
                          problema: tipoProblema!,
                        );
                        await ReportGiraDatabase.instance.insert(newReport);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Dados salvos com sucesso!"),
                            backgroundColor: Colors.greenAccent[700],
                          ),
                        );
                        // Print the saved data to the terminal
                        print('Dados salvos:');
                        print('ID: ${newReport.id}');
                        print('Estação: ${newReport.giraId}');
                        print('Tipo de Problema: ${newReport.problema}');
                        print('Notas: ${newReport.notas}');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Erro ao salvar dados: $e"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
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
    );
  }

  void _updateSubmitButtonState() {
    setState(() {
      isSubmitEnabled = nome != null && tipoProblema != null && notas.length >= 20;
    });
  }
}

