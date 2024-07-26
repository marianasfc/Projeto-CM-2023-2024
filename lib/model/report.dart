import 'package:flutter/material.dart';

class Report {
  String id;
  String parqueId;
  int gravidade;
  DateTime data;
  TimeOfDay hora;
  String? notas;
  String? imagePath;

  Report({
    required this.id,
    required this.parqueId,
    required this.gravidade,
    required this.data,
    required this.hora,
    this.notas,
    this.imagePath,
  });

  factory Report.fromDB(Map<String, dynamic> db) {
    return Report(
      id: db['id'],
      parqueId: db['parqueId'],
      gravidade: db['gravidade'],
      data: DateTime.parse(db['data']),
      hora: TimeOfDay(
        hour: int.parse(db['hora'].split(':')[0]),
        minute: int.parse(db['hora'].split(':')[1]),
      ),
      notas: db['notas'],
      imagePath: db['fotografia'],
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'parqueId': parqueId,
      'gravidade': gravidade,
      'data': data.toIso8601String(),
      'hora': '${hora.hour}:${hora.minute}',
      'notas': notas,
      'fotografia': imagePath,
    };
  }
}