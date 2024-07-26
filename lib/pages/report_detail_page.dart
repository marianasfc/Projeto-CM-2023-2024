import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/report.dart';
import 'dart:io';

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {

    String formattedTime = '${report.hora.hour}:${report.hora.minute}';

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
          'Detalhes incidente',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    'Gravidade: ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${report.gravidade}',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              )
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    'Data: ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${report.data.day}/${report.data.month}/${report.data.year} - ${formattedTime}h',
                    style: TextStyle(fontSize: 20),
                  ),
                ]
              )
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Garantir que o conteúdo esteja no topo
                children: [
                  Text(
                    'Notas: ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded( // Envolver o Text com Expanded para evitar overflow
                    child: Text(
                      report.notas ?? '',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),
            if (report.imagePath != null)
              Container(
                width: MediaQuery.of(context).size.height,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fotografia:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(report.imagePath!),
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}


