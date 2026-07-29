import '../contracts/abstract_engine.dart';

class _EngineEntry<T> {
  final T instance;
  final int priority;

  _EngineEntry(this.instance, this.priority);
}

class EngineRegistry {
  final Map<Type, List<_EngineEntry>> _registry = {};

  /// Registers an engine implementation for a specific contract type [T].
  /// Lower priority number means it will be checked first.
  void registerEngine<T extends AbstractEngine>(T instance, {int priority = 0}) {
    final entries = _registry.putIfAbsent(T, () => []);
    entries.add(_EngineEntry<T>(instance, priority));
    // Sort by priority ascending (0, 1, 2)
    entries.sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// Resolves the best available engine for contract [T].
  /// Goes through registered engines in priority order.
  /// Calls `isAvailable()` on each until it finds one that is ready.
  Future<T?> resolve<T extends AbstractEngine>() async {
    final entries = _registry[T];
    if (entries == null || entries.isEmpty) return null;

    for (final entry in entries) {
      final engine = entry.instance as T;
      if (await engine.isAvailable()) {
        return engine;
      }
    }
    return null;
  }
  
  /// Resolves the engine or throws an exception.
  Future<T> resolveOrThrow<T extends AbstractEngine>() async {
    final engine = await resolve<T>();
    if (engine == null) {
      throw Exception('No available engine found for ${T.toString()}');
    }
    return engine;
  }
}
