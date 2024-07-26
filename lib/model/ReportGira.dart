
class ReportGira {
  String id;
  String giraId;
  String notas;
  String problema;

  ReportGira({
    required this.id,
    required this.giraId,
    required this.notas,
    required this.problema,
  });

  factory ReportGira.fromDB(Map<String, dynamic> db) {
    return ReportGira(
      id: db['id'],
      giraId: '',
      notas: db['notas'],
      problema: db['problema'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'giraId': giraId,
      'notas': notas,
      'problema': problema,
    };
  }
}