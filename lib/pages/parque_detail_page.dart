import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_emel_cm/data/incidentes_database.dart';
import 'package:projeto_emel_cm/model/parque.dart';
import 'package:projeto_emel_cm/repository/parques_repository.dart';
import 'package:connectivity/connectivity.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../data/parque_database.dart';
import '../main.dart';
import '../model/report.dart';
import 'report_detail_page.dart';
import 'incident_filter_page.dart';

class ParqueDetailPage extends StatefulWidget {
  final String parqueId;
  final Parque parque;

  const ParqueDetailPage({super.key, required this.parqueId, required this.parque});

  @override
  State<ParqueDetailPage> createState() => _ParqueDetailPageState();
}

class _ParqueDetailPageState extends State<ParqueDetailPage> {
  Parque? _parque;
  bool isLoading = true;
  String? _source;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadParque();
  }

  Future<void> _initializeAndLoadParque() async {
    await _loadParque();
  }

  Future<void> _loadParque() async {
    final repository = context.read<ParquesRepository>();
    final database = ParqueDatabase.instance;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _source = 'database';
      _parque = await database.getParque(widget.parqueId);
    } else {
      _source = 'network';
      _parque = await repository.getParque(widget.parqueId);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<List<Report>> _getReportsForCurrentParque() async {
    final incidentesDatabase = IncidentesDatabase.instance;
    return await incidentesDatabase.getIncidente(widget.parqueId);
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
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.greenAccent[700],
          onPressed: () {
            Navigator.pop(context);
            context.read<MainPageViewModel>().selectedIndex = 1;
          },
        ),
        title: Text(
          widget.parqueId,
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          child: _parque != null
              ? buildParque(_parque!)
              : Text('Parque não encontrado.'),
        ),
      ),
    );
  }

  Widget buildParque(Parque parque) {
    int lugaresOcupados = _calcularLugaresOcupados(parque);

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Image(
            width: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            image: AssetImage('assets/mapa_parque2.png'),
          ),
        ),
        buildInfoRow(Icons.add_business_sharp, ' Nome: ${parque.nome}', 20),
        buildInfoRow(Icons.accessibility_new_rounded, ' Capacidade: ${parque.capacidade} lugares', 20),
        buildInfoRow(Icons.access_time_filled_rounded, ' Tipo de parque: ${parque.tipo}', 20),
        buildInfoRow(Icons.account_circle_sharp, ' Lugares ocupados: $lugaresOcupados ', 20),
        buildIncidentsSection(),
        FutureBuilder<List<Report>>(
          future: _getReportsForCurrentParque(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error loading reports');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No reports available');
            } else {
              final reports = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final Report report = reports[index];
                  String formattedDate = DateFormat('dd/MM/yyyy').format(report.data);
                  String formattedTime = '${report.hora.hour}:${report.hora.minute}';
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportDetailPage(report: report),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.all(0),
                        leading: Icon(Icons.report_problem_rounded, size: 25, color: Colors.blue[900]),
                        title: Text(
                          "Gravidade: ${report.gravidade}",
                          style: TextStyle(fontSize: 20),
                        ),
                        subtitle: Text(
                          "$formattedDate - ${formattedTime}h",
                          style: TextStyle(fontSize: 20),
                        ),
                        trailing: report.imagePath != null ? Image.file(File(report.imagePath!)) : null,
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget buildInfoRow(IconData icon, String text, double fontSize) {
    return Container(
      width: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(5.0),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Icon(icon, size: 25, color: Colors.blue[900],),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: fontSize)),
        ],
      ),
    );
  }

  Widget buildIncidentsSection() {
    return Container(
      width: MediaQuery.of(context).size.height,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Incidentes',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IncidentFilterPage(),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.blue[900]),
                SizedBox(width: 5),
                Text(
                  'Filtrar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
