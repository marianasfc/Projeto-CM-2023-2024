import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncidentFilterPage extends StatefulWidget {
  @override
  _IncidentFilterPageState createState() => _IncidentFilterPageState();
}

class _IncidentFilterPageState extends State<IncidentFilterPage> {
  double severity = 1.0;
  double minSeverity = 1.0;
  double maxSeverity = 5.0;
  double minCapacity = 0;
  double maxCapacity = 1000;
  String selectedFiltroPreco = '';

  List<String> sortingOptions = ['Data Crescente', 'Data Decrescente', 'Hora Crescente', 'Hora Decrescente'];
  String selectedSortingOption = 'Data Crescente';

  bool hasNote = false;
  bool hasPhoto = false;

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
          'Filtros incidentes',
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
                        'Gravidade',
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
                        value: severity,
                        min: minSeverity,
                        max: maxSeverity,
                        divisions: 4,
                        label: severity.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            severity = value;
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
                    value: selectedSortingOption,
                    items: sortingOptions.map((option) {
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
                        selectedSortingOption = value.toString();
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
                      'Contém: ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Notas',
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
                      'Fotografias',
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
                  final filterData = {
                    'capacidadeMin': minCapacity,
                    'capacidadeMax': maxCapacity,
                    'ordenacao': selectedFiltroPreco,
                  };
                  Navigator.pop(context, filterData);
                },
                child: Text(
                  'Aplicar Filtros',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              )

            )
          ],
        ),
      ),
    );
  }
}







