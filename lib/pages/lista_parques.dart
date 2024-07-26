import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:projeto_emel_cm/data/parque_database.dart';
import 'package:projeto_emel_cm/model/parque.dart';
import 'package:projeto_emel_cm/pages/parque_detail_page.dart';
import 'package:projeto_emel_cm/pages/parques_filter_page.dart';
import 'package:projeto_emel_cm/repository/parques_repository.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class ListaParques extends StatefulWidget {
  const ListaParques({Key? key, required this.parques}) : super(key: key);

  final List<Parque> parques;

  @override
  State<ListaParques> createState() => _ListaParquesState();
}

class _ListaParquesState extends State<ListaParques> {
  bool isLoading = true;
  String? _source;
  List<Parque> parques = [];

  @override
  void initState() {
    super.initState();
    _initializeAndLoadParques();
  }

  Future<void> _initializeAndLoadParques() async {
    final database = ParqueDatabase.instance;
    await database.database;

    await _loadParques();
  }

  Future<void> _loadParques() async {
    final repository = context.read<ParquesRepository>();
    final database = ParqueDatabase.instance;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _source = 'database';
      parques = await database.getParques();
    } else {
      _source = 'network';
      parques = await repository.getParques();
    }

    setState(() {
      isLoading = false;
    });
  }

  int _calcularLugaresOcupados(Parque parque) {
    if (parque.ocupacao <= 0) {
      return parque.capacidade;
    } else {
      return parque.ocupacao;
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = ParqueDatabase.instance;

    return Scaffold(
      backgroundColor: Colors.green[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : buildList(parques, database),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParqueFilterPage(),
            ),
          );
        },
        child: Icon(
          Icons.filter_list,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildList(List<Parque> parques, ParqueDatabase database) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: parques.length,
      itemBuilder: (_, index) {
        int lugaresOcupados = _calcularLugaresOcupados(parques[index]);
        int lugaresLivres = parques[index].capacidade - lugaresOcupados;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FutureBuilder(
                  future: _source == 'network'
                      ? context.read<ParquesRepository>().getParque(parques[index].id.toString())
                      : database.getParques(),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error!'));
                      } else {
                        final Parque? parque = snapshot.data as Parque?;
                        if (parque != null) {
                          return ParqueDetailPage(parqueId: parques[index].id.toString(), parque: parque);
                        } else {
                          return Center(child: Text('Parque não encontrado.'));
                        }
                      }
                    }
                  },
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.airport_shuttle, size: 20),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parques[index].nome,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Lugares livres: $lugaresLivres',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        parques[index].lastUpdate,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                if (_source == 'network')
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      database.insert(Parque(
                        id: parques[index].id,
                        nome: parques[index].nome,
                        capacidade: parques[index].capacidade,
                        ocupacao: parques[index].ocupacao,
                        lastUpdate: parques[index].lastUpdate,
                        latitude: parques[index].latitude,
                        longitude: parques[index].longitude,
                        tipo: parques[index].tipo,
                      ));
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildInsertParqueButton(ParqueDatabase database) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          database.insert(Parque(
            id: '${Random().nextInt(100)}',
            nome: 'Novo Parque',
            capacidade: Random().nextInt(100),
            latitude: Random().nextDouble().toString(),
            longitude: Random().nextDouble().toString(),
            tipo: 'superficie',
            ocupacao: Random().nextInt(100),
            lastUpdate: DateTime.now().toString(),
          ));
        },
        child: Text('Adicionar parque'),
      ),
    );
  }
}
