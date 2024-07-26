class Gira {
  final String id;
  final String nome;
  final int numBicicletas;
  final double latitude;
  final double longitude;
  final int numDocas;
  final String estado;
  final String lastUpdate;

  Gira({
    required this.id,
    required this.nome,
    required this.numBicicletas,
    required this.latitude,
    required this.longitude,
    required this.numDocas,
    required this.estado,
    required this.lastUpdate,});

  factory Gira.fromJSON(Map<String, dynamic> json) {
    return Gira(
      id: json['properties']['id_expl'],
      nome: json['properties']['desig_comercial'],
      numBicicletas: json['properties']['num_bicicletas'],
      latitude: json['geometry']['coordinates'][0][1],
      longitude: json['geometry']['coordinates'][0][0],
      numDocas: json['properties']['num_docas'],
      estado: json['properties']['estado'],
      lastUpdate: json['properties']['update_date'],
    );
  }

  factory Gira.fromDB(Map<String, dynamic> db){
    return Gira(id: db['id_gira'], nome: db['nome'], numBicicletas: db['num_biciletas'],
        latitude: db['latitude'], longitude: db['longitude'], numDocas: db['numDocas'],
        estado: db['estado'], lastUpdate: db['data_update']);

  }

  Map<String, dynamic> toDB(){
    return {
      'id_gira': id,
      'nome': nome,
      'num_biciletas': numBicicletas,
      'latitude': latitude,
      'longitude': longitude,
      'num_docas': numDocas,
      'estado': estado,
      'data_update': lastUpdate,
    };
  }
}