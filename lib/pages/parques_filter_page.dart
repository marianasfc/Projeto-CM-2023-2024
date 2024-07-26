import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_emel_cm/http/http_client.dart';
import 'package:projeto_emel_cm/repository/parques_repository.dart';
import '../model/parque.dart';
import 'lista_parques.dart';

class ParqueFilterPage extends StatefulWidget {
  @override
  _ParqueFilterPageState createState() => _ParqueFilterPageState();
}

class _ParqueFilterPageState extends State<ParqueFilterPage> {
  double capacity = 0.0;
  double minCapacity = 0.0;
  double maxCapacity = 100.0;
  String selectedFiltroPreco = 'Preço crescente';
  bool hasNote = false;
  bool hasPhoto = false;
  List<Parque> parques = [];
  List<String> filtroPreco = ['Preço crescente', 'Preço decrescente'];
  late HttpClient httpClient;
  late ParquesRepository repository;

  @override
  void initState() {
    super.initState();
    httpClient = HttpClient();
    repository = ParquesRepository(client: HttpClient());
    _loadParques();
  }

  Future<void> _loadParques() async {
    parques = await repository.getParques();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        leading:
        IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.greenAccent[700],
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Filtros parques',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Capacidade',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Slider(
                        activeColor: Colors.blue[900],
                        inactiveColor: Colors.blue[200],
                        value: capacity,
                        min: minCapacity,
                        max: maxCapacity,
                        divisions: 4,
                        label: capacity.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            capacity = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(12.0),
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Ordenar Por',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  DropdownButtonFormField(
                    value: selectedFiltroPreco,
                    items: filtroPreco.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text('  $option',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue[900],
                          ),),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFiltroPreco = value.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(12.0),
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tipo de parque: ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Estrutura',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue[900],
                      ),
                    ),
                    value: hasNote,
                    onChanged: (value) {
                      setState(() {
                        hasNote = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Superfície',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue[900],
                      ),
                    ),
                    value: hasPhoto,
                    onChanged: (value) {
                      setState(() {
                        hasPhoto = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  final parquesOrdenados = repository.filtrarParquesPorCapacidade(minCapacity as int, maxCapacity as int, []);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListaParques(parques: parquesOrdenados),
                    ),
                  );
                },
                child: Text(
                  'Aplicar Filtros',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}