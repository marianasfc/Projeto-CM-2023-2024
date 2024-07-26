import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projeto_emel_cm/http/http_client.dart';
import '../model/parque.dart';

class ParquesRepository {
  final HttpClient _client;
  ParquesRepository({required HttpClient client}) : _client = client;

  Future<List<Parque>> getParques() async {
    final response = await _client.get(
      url: ('https://emel.city-platform.com/opendata/parking/lots'),
      headers: {
        'api_key': '93600bb4e7fee17750ae478c22182dda',
      },
    );

    if (response.statusCode == 200){
      final responseJSON = jsonDecode(response.body);
      List parquesJSON = responseJSON;
      
      List<Parque> parques = parquesJSON.map((parqueJSON) => Parque.fromJSON(parqueJSON)).toList();

      return parques;
      
    } else {
      throw Exception('status code: ${response.statusCode}');
    }
  }

  Future<List<Parque>> getDetailParques() async {
    final response = await _client.get(
      url: ('https://emel.city-platform.com/opendata/parking/places'),
      headers: {
        'api_key': '93600bb4e7fee17750ae478c22182dda',
      },
    );

    if (response.statusCode == 200){
      final responseJSON = jsonDecode(response.body);
      List parquesJSON = responseJSON;

      List<Parque> parques = parquesJSON.map((parqueJSON) => Parque.fromJSON(parqueJSON)).toList();

      return parques;

    } else {
      throw Exception('status code: ${response.statusCode}');
    }
  }

  Future<Parque> getParque(String id) async {
    debugPrint('vou obter o parque do servidor');
    final response = await _client.get(
      url: 'https://emel.city-platform.com/opendata/parking/lots',
      headers: {'api_key': '93600bb4e7fee17750ae478c22182dda'},
    );

    if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>; // Cast to List
        final parque = data.firstWhere((parque) => parque['id_parque'] == id, orElse: () => null);

        if (parque != null) {
          return Parque.fromJSON(parque);
        } else {
          debugPrint('Park with ID: $id not found.');
          return Parque(id: "", nome: "", capacidade: 0, latitude: "", longitude: "", tipo: "", ocupacao: 0, lastUpdate: ""); // Indicate park not found
        }
    } else {
      throw Exception('Failed to fetch park data (status code: ${response.statusCode})');
    }
  }

  List<Parque> filtrarParquesPorCapacidade(
      int capacidadeMinima, int capacidadeMaxima, List<Parque> parques) {
    return parques.where((parque) {
      int capacidadeParque = parque.capacidade;
      return capacidadeParque >= capacidadeMinima &&
          capacidadeParque <= capacidadeMaxima;
    }).toList();
  }


}
