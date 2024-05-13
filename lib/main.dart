import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Events
abstract class ScanEvent {}

class KeyPressed extends ScanEvent {
  final KeyEvent keyEvent;
  KeyPressed(this.keyEvent);
}

class StartScan extends ScanEvent {}

class EndScan extends ScanEvent {}

// States
abstract class ScanState {}

class ScanInitial extends ScanState {}

class ScanResult extends ScanState {
  final String scannedCode;
  ScanResult(this.scannedCode);
}

// Bloc
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final StringBuffer _chars = StringBuffer();

  ScanBloc() : super(ScanInitial()) {
    on<KeyPressed>((event, emit) {
      final keyEvent = event.keyEvent;
      if (keyEvent is KeyDownEvent &&
          keyEvent.logicalKey.keyLabel.length == 1) {
        _chars.write(keyEvent.character ??
            keyEvent.logicalKey.keyLabel.characters.first);
      }
    });

    on<StartScan>((event, emit) {});

    on<EndScan>((event, emit) {
      emit(ScanResult(_chars.toString()));
      _chars.clear();
    });
  }

  @override
  Future<void> close() {
    return super.close();
  }
}

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

    return Scaffold(
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanResult) {
            focusNode
                .requestFocus(); // Ensures the focus is reset after a scan.
          }
        },
        builder: (context, state) {
          return KeyboardListener(
            focusNode: focusNode,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent) {
                context.read<ScanBloc>().add(KeyPressed(event));
              }
              if (event is KeyUpEvent) {
                switch (event.logicalKey.keyLabel.toUpperCase()) {
                  case 'F11':
                    // Potentially trigger a StartScan event here
                    break;
                  case 'ENTER':
                    context.read<ScanBloc>().add(EndScan());
                    break;
                }
              }
            },
            child: Center(
              child: state is ScanResult
                  ? Text(
                      state.scannedCode,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 22),
                      textAlign: TextAlign.center,
                    )
                  : const Text(
                      'Froza ATOL test:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          );
        },
      ),
    );
  }
}
