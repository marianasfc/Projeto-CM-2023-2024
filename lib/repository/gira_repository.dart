import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:projeto_emel_cm/http/http_client.dart';
import '../model/Gira.dart';
import 'package:http/http.dart' as http;

class GiraRepository {
  final HttpClient _client;
  GiraRepository({required HttpClient client}) : _client = client;

  Future<List<Gira>> getGiras() async {
    final response = await _client.get(
      url: ('https://emel.city-platform.com/opendata/gira/station/list'),
      headers: {
        'api_key': '93600bb4e7fee17750ae478c22182dda',
      },
    );

    if (response.statusCode == 200){
      final responseJSON = jsonDecode(response.body);
      List<Gira> docks = responseJSON['features'].map<Gira>((giraJSON) => Gira.fromJSON(giraJSON)).toList();
      return docks;
    } else {
      throw Exception('status code: ${response.statusCode}');
    }
  }

  Future<Gira?> getGira(String id) async {
    final String url = 'https://emel.city-platform.com/opendata/gira/station/$id';
    final Map<String, String> headers = {
      'api_key': '93600bb4e7fee17750ae478c22182dda',
      'accept': 'application/json',
    };

    debugPrint('Buscando estação Gira com ID: $id no servidor');

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> && data.containsKey('id_expl')) {
        return Gira(
          id: data['id_expl'] ?? '',
          nome: data['desig_comercial'] ?? '',
          numBicicletas: data['num_bicicletas'] ?? 0,
          latitude: data['latitude']?.toDouble() ?? 0.0,
          longitude: data['longitude']?.toDouble() ?? 0.0,
          numDocas: data['num_docas'] ?? 0,
          estado: data['estado'] ?? '',
          lastUpdate: DateTime.now().toIso8601String(),
        );
      } else {
        debugPrint('Nenhum dado válido encontrado na resposta');
        return null;
      }
    } else {
      throw Exception('Failed to fetch park data (status code: ${response.statusCode})');
    }
  }
}
