import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_emel_cm/pages/report_gira_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/reportGira_dataBase.dart';
import '../main.dart';
import '../model/Gira.dart';
import '../model/ReportGira.dart';
import '../repository/gira_repository.dart';

class GiraDetailPage extends StatefulWidget {
  final String giraId;

  const GiraDetailPage({super.key, required this.giraId});

  @override
  State<GiraDetailPage> createState() => _GiraDetailPageState();
}

class _GiraDetailPageState extends State<GiraDetailPage> {
  Gira? _gira;
  List<ReportGira> _incidents = [];

  @override
  void initState() {
    super.initState();
    _loadGira();
    _loadIncidents();
  }

  Future<void> _loadGira() async {
    final repository = context.read<GiraRepository>();
    Gira? gira = await repository.getGira(widget.giraId);
    setState(() {
      _gira = gira;
    });
  }

  Future<void> _loadIncidents() async {
    final incidentesDatabase = ReportGiraDatabase.instance;
    final incidents = await incidentesDatabase.getIncidente(widget.giraId);
    setState(() {
      _incidents = incidents;
    });
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd/MM/yyyy, HH:mm:ss').format(dateTime);
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
          widget.giraId,
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
      body: Center(
        child: SingleChildScrollView(
          child: _gira == null
              ? CircularProgressIndicator()
              : buildGiraDetail(_gira!),
        ),
      ),
    );
  }

  Widget buildGiraDetail(Gira gira) {
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
        buildInfoRow(Icons.add_business_sharp, 'Morada', gira.nome.substring(gira.nome.indexOf('-') + 1).trim()),
        buildInfoRow(Icons.directions_bike, 'Número de docas', gira.numDocas.toString()),
        buildInfoRow(Icons.directions_bike, 'Bicicletas disponíveis', gira.numBicicletas.toString()),
        buildInfoRow(Icons.update, 'Último update', formatDateTime(gira.lastUpdate)),
        buildIncidentsSection(),
        buildReportsList(_incidents),
      ],
    );
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Icon(icon, size: 25, color: Colors.blue[900]),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 20),
            ),
          ),
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
                  builder: (context) => ReportGiraPage(initialStation: _gira!.nome),
                ),
              ).then((_) {
                _loadIncidents();
              });
            },
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.blue[900]),
                SizedBox(width: 5),
                Text(
                  'Adicionar',
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

  Widget buildReportsList(List<ReportGira> reports) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final ReportGira report = reports[index];
        return Container(
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
              "Tipo de problema: ${report.problema}",
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text(
              report.notas,
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      },
    );
  }
}

