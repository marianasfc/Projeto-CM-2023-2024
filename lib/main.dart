import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_emel_cm/data/parque_database.dart';
import 'package:projeto_emel_cm/http/http_client.dart';
import 'package:projeto_emel_cm/pages/dashboard_page.dart';
import 'package:projeto_emel_cm/pages/lista_parques.dart';
import 'package:projeto_emel_cm/pages/mapa.dart';
import 'package:projeto_emel_cm/pages/report_page.dart';
import 'package:projeto_emel_cm/repository/gira_repository.dart';
import 'package:projeto_emel_cm/repository/parques_repository.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ParqueDatabase.instance.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainPageViewModel()),
        Provider<ParquesRepository>(create: (_) => ParquesRepository(client: HttpClient())),
        Provider<GiraRepository>(create: (_) => GiraRepository(client: HttpClient())),
        Provider<ParqueDatabase>(create: (_) => ParqueDatabase.instance)
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ParqueDatabase.instance.database,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Emel',
            theme: ThemeData(
              useMaterial3: true,
            ),
            home: MainPage(),
          );
        } else {
          return MaterialApp(
            home: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class MainPageViewModel extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainPageViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: Colors.greenAccent[700]),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          _titles[viewModel.selectedIndex],
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
              color: Colors.greenAccent[700],
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        color: Colors.green[100],
        child: _pages.elementAt(viewModel.selectedIndex),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[900],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/emel_logo.png', height: 80),
                    SizedBox(height: 16),
                    Text(
                      'Menu',
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                          color: Colors.greenAccent[700],
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 20)),
              onTap: () {
                viewModel.selectedIndex = 0;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.local_parking),
              title: Text('Parques', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 20)),
              onTap: () {
                viewModel.selectedIndex = 1;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text('Reportar parques', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 20)),
              onTap: () {
                viewModel.selectedIndex = 2;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Mapa', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 20)),
              onTap: () {
                viewModel.selectedIndex = 3;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

final List<Widget> _pages = [
  DashboardPage(),
  ListaParques(parques: []),
  ReportPage(),
  Mapa(),
];

final List<String> _titles = [
  'emel',
  'Parques',
  'Reportar',
  'Mapa',
];
