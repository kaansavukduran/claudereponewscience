/// Clock and id generation ports, so tests can control time and ids.
library;

import 'dart:math';

abstract interface class Clock {
  DateTime nowUtc();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

abstract interface class IdGenerator {
  String newId();
}

/// RFC 4122 version-4 UUIDs from a cryptographically secure source.
class UuidV4Generator implements IdGenerator {
  UuidV4Generator([Random? random]) : _random = random ?? Random.secure();

  final Random _random;

  @override
  String newId() {
    final b = List<int>.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String hex(int i) => b[i].toRadixString(16).padLeft(2, '0');
    final h = [for (var i = 0; i < 16; i++) hex(i)].join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
