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
