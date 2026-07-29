import 'dart:async';
import '../models/engine_info.dart';

class EngineManager {
  final Map<String, EngineInfo> _engines = {};
  final Map<String, StreamController<EngineInfo>> _controllers = {};

  void registerEngineMetadata(EngineInfo info) {
    _engines[info.id] = info;
    _getController(info.id).add(info);
  }

  Stream<EngineInfo> watchEngine(String engineId) {
    return _getController(engineId).stream;
  }

  Future<EngineInfo?> getEngineInfo(String engineId) async {
    return _engines[engineId];
  }

  Future<void> installEngine(String engineId) async {
    final info = _engines[engineId];
    if (info == null) throw Exception('Unknown engine: $engineId');
    if (info.status == EngineStatus.installed) return;
    
    // Simulate download
    var current = info.copyWith(status: EngineStatus.downloading, downloadProgress: 0.0);
    _updateEngine(current);
    
    // Fake 2 second download
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      current = current.copyWith(downloadProgress: i / 10.0);
      _updateEngine(current);
    }
    
    _updateEngine(current.copyWith(
      status: EngineStatus.installed,
      downloadProgress: 1.0,
    ));
  }

  StreamController<EngineInfo> _getController(String id) {
    return _controllers.putIfAbsent(id, () => StreamController<EngineInfo>.broadcast());
  }
  
  void _updateEngine(EngineInfo info) {
    _engines[info.id] = info;
    _getController(info.id).add(info);
  }
  
  void dispose() {
    for (final c in _controllers.values) {
      c.close();
    }
  }
}
