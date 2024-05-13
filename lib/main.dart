void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => ScanBloc(),
        child: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();
    focusNode.requestFocus();

    return Scaffold(
        body: KeyboardListener(
            focusNode: focusNode,
            onKeyEvent: (KeyEvent event) {
              context.read<ScanBloc>().add(KeyPressed(event));
              if (event is KeyUpEvent) {
                switch (event.logicalKey.keyLabel.toUpperCase()) {
                  case 'F11':
                    context.read<ScanBloc>().add(StartScan());
                    break;
                  case 'ENTER':
                    context.read<ScanBloc>().add(EndScan());
                    break;
                }
              }
            },
            child: mainScreenWidget()));
  }
}

Widget mainScreenWidget() {
  return Center(
    child: BlocBuilder<ScanBloc, ScanState>(
      builder: (context, state) {
        if (state is ScanResult) {
          return Text(
            state.scannedCode,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
            textAlign: TextAlign.center,
          );
        }
        return const Text(
          'Froza ATOL test:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        );
      },
    ),
  );
}
