import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late final StreamSubscription _streamSubscription;
  final StringBuffer _chars = StringBuffer();

  ScanBloc() : super(ScanInitial()) {
    on<KeyPressed>((event, emit) {
      final keyEvent = event.keyEvent;
      if (keyEvent is KeyDownEvent &&
          keyEvent.logicalKey.keyLabel.length == 1) {
        _chars.write(keyEvent.character ??
            keyEvent.logicalKey.keyLabel.characters.first);
        _subject.add(_chars.toString());
      }
    });

    on<StartScan>((event, emit) {
      emit(ScanResult(_chars.toString()));
      _chars.clear();
    });

    on<EndScan>((event, emit) {
      emit(ScanResult(_chars.toString()));
      _chars.clear();
    });

    _streamSubscription = _subject.stream
        .debounceTime(const Duration(milliseconds: 10))
        .listen((code) {
      if (code == '404_PDA_SCAN_NOT_FOUND') {
        // Handle not found case
      } else {
        add(StartScan());
      }
    });
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
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
