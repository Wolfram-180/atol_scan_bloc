import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

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
  final BehaviorSubject<String> _subject = BehaviorSubject();
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
    _subject.close();
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
    focusNode.requestFocus();

    return Scaffold(
      body: KeyboardListener(
        focusNode: focusNode,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            context.read<ScanBloc>().add(KeyPressed(event));
          }
          if (event is KeyUpEvent) {
            switch (event.logicalKey.keyLabel.toUpperCase()) {
              case 'ENTER':
                context.read<ScanBloc>().add(EndScan());
                break;
              default:
                break;
            }
          }
        },
        child: mainScreenWidget(context),
      ),
    );
  }

  Widget mainScreenWidget(BuildContext context) {
    return Center(
      child: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanResult) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Scan completed: ${state.scannedCode}")),
            );
          }
        },
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
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}



/*
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

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
  final BehaviorSubject<String> _subject = BehaviorSubject();
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
    _subject.close();
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
    focusNode.requestFocus();

    return Scaffold(
      body: KeyboardListener(
        focusNode: focusNode,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            context.read<ScanBloc>().add(KeyPressed(event));
          }
          if (event is KeyUpEvent) {
            switch (event.logicalKey.keyLabel.toUpperCase()) {
              case 'F11': // This could be used for start scan, if needed
                break;
              case 'ENTER':
                context.read<ScanBloc>().add(EndScan());
                break;
            }
          }
        },
        child: mainScreenWidget(),
      ),
    );
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
*/