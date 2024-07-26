import '../model/report.dart';

class ReportsRepository {
  static List<Report> reports = [];

  static void addReport(Report report) {
    reports.add(report);
  }

  List<Report> getReports() {
    return reports;
  }

  List<Report> getReportsByParqueId(String parqueId) {
    return reports.where((report) => report.parqueId == parqueId).toList();
  }

  Report? getMostSevereReportByParqueId(String parqueId) {
    List<Report> parqueReports = getReportsByParqueId(parqueId);
    if (parqueReports.isEmpty) {
      return null;
    }

    parqueReports.sort((a, b) => b.gravidade.compareTo(a.gravidade));

    return parqueReports.first;
  }
}

