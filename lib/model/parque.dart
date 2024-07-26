class Parque {
  final String id;
  final String nome;
  final int capacidade;
  final String latitude;
  final String longitude;
  final String tipo;
  late final int ocupacao;
  final String lastUpdate;

  Parque({
    required this.id,
    required this.nome,
    required this.capacidade,
    required this.latitude,
    required this.longitude,
    required this.tipo,
    required this.ocupacao,
    required this.lastUpdate,});

  factory Parque.fromJSON(Map<String, dynamic> json){
    return Parque(id: json['id_parque'], nome: json['nome'], capacidade: json['capacidade_max'],
        latitude: json['latitude'], longitude: json['longitude'], tipo: json['tipo'],
        ocupacao: json['ocupacao'], lastUpdate: json['data_ocupacao']);

  }

  factory Parque.fromDB(Map<String, dynamic> db){
    return Parque(id: db['id_parque'], nome: db['nome'], capacidade: db['capacidade_max'],
        latitude: db['latitude'], longitude: db['longitude'], tipo: db['tipo'],
        ocupacao: db['ocupacao'], lastUpdate: db['data_ocupacao']);

  }

  Map<String, dynamic> toDB(){
    return {
      'id_parque': id,
      'nome': nome,
      'capacidade_max': capacidade,
      'latitude': latitude,
      'longitude': longitude,
      'tipo': tipo,
      'ocupacao': ocupacao,
      'data_ocupacao': lastUpdate,
    };
  }

  double get LugaresLivresPer {
    int capacidadeTotal = capacidade;
    int lotacaoAtual = ocupacao;
    return ((capacidadeTotal - lotacaoAtual) / capacidadeTotal) * 100;
  }




}



