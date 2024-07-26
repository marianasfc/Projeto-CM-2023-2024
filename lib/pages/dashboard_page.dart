import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projeto_emel_cm/http/http_client.dart';
import 'package:projeto_emel_cm/pages/parque_detail_page.dart';
import '../model/parque.dart';
import '../model/report.dart';
import '../repository/parques_repository.dart';
import '../repository/report_repository.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Parque> parques = [];
  late double percentagemLivres;
  Parque? parqueMaisLotado;
  late List<Report> reportsForParque;
  Report? reportMaisGrave;
  ReportsRepository reportsRepository = ReportsRepository();

  @override
  void initState() {
    super.initState();
    _loadParques();
  }

  String formatPrice(String price) {
    return '${double.parse(price).toStringAsFixed(2)}€';
  }

  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  List<Parque> _searchParques(String searchText) {
    return parques.where((parque) => parque.nome.toLowerCase().contains(searchText.toLowerCase())).toList();
  }

  Future<void> _loadParques() async {
    final repository = ParquesRepository(client: HttpClient());
    parques = await repository.getParques();

    // Ordena a lista de parques pela diferença entre capacidade e ocupação
    parques.sort((a, b) => (a.capacidade - a.ocupacao).compareTo(b.capacidade - b.ocupacao));

    // O parque mais lotado será o primeiro da lista ordenada
    parqueMaisLotado = parques.first;

    // Carrega os relatórios
    List<Report> allReports = await reportsRepository.getReports(); // Certifique-se de que este método seja assíncrono
    if (allReports.isNotEmpty) {
      reportMaisGrave = allReports.reduce((a, b) => a.gravidade > b.gravidade ? a : b);
    }

    setState(() {});
  }

  Parque _findParqueName(String parqueId) {
    final foundParque = parques.firstWhere(
          (parque) => parque.id == parqueId,
      orElse: () => Parque(
        id: "0",
        nome: '',
        capacidade: 0,
        latitude: '',
        longitude: '',
        tipo: '',
        ocupacao: 0,
        lastUpdate: '',
      ),
    );
    return foundParque;
  }

  String formatDateTime(Report? report) {
    if (report != null) {
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      String formattedDate = dateFormat.format(report.data);
      String formattedTime = report.hora.format(context);

      return '$formattedDate $formattedTime';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {

    List<Parque> sortedParques = List.from(parques)
      ..sort((a, b) => ((b.capacidade - b.ocupacao) - (a.capacidade - a.ocupacao)));
    List<Parque> top7Parques = sortedParques.take(7).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (text) {
                    setState(() {
                      _searchText = text;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Pesquisar parque',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none, // Remove a borda padrão do TextField
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0), // Espaçamento interno do TextField
                  ),
                ),
              ),
            ),
          ),
          // Lista de Parques
          if (_searchText.isNotEmpty) // Mostra a lista somente se o texto de pesquisa não estiver vazio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _searchParques(_searchText).map((parque) {
                    return ListTile(
                      title: Text(parque.nome),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParqueDetailPage(parqueId: parque.id, parque: parque),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Dados em tempo real',
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Parques com mais lugares livres',
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 250,
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: BarChart(
                                      BarChartData(
                                        alignment: BarChartAlignment.spaceAround,
                                        groupsSpace: 5,
                                        maxY: 100,
                                        barTouchData: BarTouchData(
                                          enabled: false,
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          bottomTitles: SideTitles(
                                            showTitles: true,
                                            getTextStyles: (context, value) =>
                                                TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                            margin: 5,
                                            getTitles: (double value) {
                                              if (value.toInt() < top7Parques.length) {
                                                return (value + 1).toInt().toString();
                                              } else {
                                                return '';
                                              }
                                            },
                                          ),
                                          leftTitles: SideTitles(
                                            showTitles: true,
                                            getTextStyles: (context, value) =>
                                                TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                            margin: 0,
                                            reservedSize: 40.0,
                                            interval: 20,
                                            getTitles: (double value) {
                                              return '${value.toInt()}%';
                                            },
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: false,
                                        ),
                                        barGroups: top7Parques.map((parque) {
                                          double percentageFree = ((parque.capacidade - parque.ocupacao) / parque.capacidade) * 100;
                                          return BarChartGroupData(
                                            x: top7Parques.indexOf(parque),
                                            barRods: [
                                              BarChartRodData(
                                                y: percentageFree.clamp(0, 100), // Clamp the value to 100
                                                width: 16,
                                                colors: [Colors.blue],
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    )
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Legenda do Gráfico:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 5.0),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: top7Parques.length,
                              itemBuilder: (context, index) {
                                final parque = top7Parques[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    '${index + 1}. ${parque.nome}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Notificações',
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 20,
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Icon(
                    Icons.taxi_alert,
                    size: 25,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parque mais perto de lotar:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${parqueMaisLotado?.nome ?? 'N/A'} ',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Lotação atual: ${parqueMaisLotado?.ocupacao ?? 0}/'
                          '${parqueMaisLotado?.capacidade ?? 0}',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      '${parqueMaisLotado?.lastUpdate ?? 'N/A'}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 55.0),
                  child: Icon(
                    Icons.warning,
                    size: 25,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incidente mais grave:',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      reportMaisGrave != null
                          ? _findParqueName(reportMaisGrave!.parqueId)?.nome ?? ''
                          : '',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Nível de gravidade: ${reportMaisGrave?.gravidade ?? ''}',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      reportMaisGrave != null
                          ? formatDateTime(reportMaisGrave)
                          : '',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



