import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

void main() {
  FFIBridge.initialize();
  runApp(const MyApp());
}

class FFIBridge {
  static bool initialize() {
    nativeApiLib = Platform.isMacOS || Platform.isIOS
        ? DynamicLibrary.process()
        : (DynamicLibrary.open(Platform.isWindows ? 'api.dll' : 'libapi.so'));
    final _primeiro =
        nativeApiLib.lookup<NativeFunction<Void Function()>>('primeiro');
    primeiro = _primeiro.asFunction<void Function()>();

    return true;
  }

  static late DynamicLibrary nativeApiLib;
  static late Function primeiro;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrix Solver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Matrix Solver Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFileIn async {
    final path = await _localPath;
    return File('sistema.in');
  }

  Future<File> get _localFileOut async {
    final path = await _localPath;
    return File('sistema.out');
  }

  Future<File> writeSistema() async {
    final file = await _localFileIn;
    String text = '$n';
    for (int i = 0; i < n; i++) {
      text += '\n';
      text += matrix[i]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll(', ', ' ');
    }

    return file.writeAsString(text);
  }

  Future<List<String>> readSolucao() async {
    try {
      final file = await _localFileOut;

      final content = await file.readAsLines();
      print(content);
      return content;
    } catch (e) {
      return ["Error"];
    }
  }

  void _chamar_func() async {
    final fileWrite = await _localFileIn;
    String text = '$n';
    for (int i = 0; i < n; i++) {
      text += '\n';
      text += matrix[i]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll(', ', ' ');
    }

    fileWrite.writeAsString(text);

    FFIBridge.primeiro();

    final fileRead = await _localFileOut;
    final content = await fileRead.readAsLines();
    print(content);
    setState(() {
      flag = content[1];
    });

    if (flag == 'SPD') {
      for (int i = 2; i <= n; i++) {
        List<String> linha = content[i].split(' ');
        setState(() {
          solucoes[i - 1] = double.parse(linha[0]);
          solucoes[i] = double.parse(linha[1]);
        });
      }
    }
  }

  int n = 0;
  var matrix;
  var solucoes;
  String flag = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            Text(
              'Resolvedor de Matriz!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextField(
              onChanged: (text) {
                text == '' ? text = '0' : text = text;

                setState(() {
                  n = int.parse(text);
                });

                matrix = List<List>.generate(
                    n,
                    (index) => List<double>.generate(2 * n + 2, (index) => 0,
                        growable: false),
                    growable: false);
                solucoes =
                    List<double>.generate(n, (index) => 0.0, growable: false);
              },
            ),
            for (var i = 0; i < n; i++)
              Row(
                children: [
                  for (int j = 0; j < 2 * n + 2; j++)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: IntrinsicWidth(
                        stepWidth: 100,
                        child: TextField(
                          onChanged: (text) {
                            text == '' ? text = '0' : text = text;
                            if (text != '-') {
                              matrix[i][j] = double.parse(text);
                            }
                          },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText:
                                "${i + 1}, ${(j + 1) % 2 == 0 ? j : j + 1} ${j % 2 == 0 ? 'Real' : 'Imag'}",
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            if (flag == 'SPD') const Text('Sistema Possível Determinado'),
            if (flag == 'SI')
              const Text('Sistema Impossível')
            else if (flag == 'SPI')
              const Text('Sistema Possível Inderteminado')
            else if (flag == 'SPD')
              for (int i = 0; i < n - 1; i++)
                Text('${solucoes[i]} + ${solucoes[i + 1]}'),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const SizedBox(width: 16),
          FloatingActionButton.extended(
              onPressed: _chamar_func,
              label: const Text('Resolver Sistema'),
              icon: const Icon(Icons.all_inclusive_rounded)),
        ],
      ),
    );
  }
}
