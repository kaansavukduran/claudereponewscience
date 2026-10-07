/// Profile identity. The id is a UUID stored inside the vault, so moving a
/// portable folder never creates a new person (filesystem path ≠ identity).
library;

import '../records/health_record.dart' show SchemaTooNewError;

enum ProfileType { self, realOther, synthetic, scenario }

class Profile {
  const Profile({
    required this.id,
    required this.type,
    required this.createdAt,
    this.displayName,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  final String id;
  final ProfileType type;
  final DateTime createdAt;
  final String? displayName;
  final int schemaVersion;

  Map<String, Object?> toJson() => {
    'schema_version': schemaVersion,
    'id': id,
    'type': type.name,
    'created_at': createdAt.toIso8601String(),
    'display_name': displayName,
  };

  static Profile fromJson(Map<String, Object?> j) {
    final version = (j['schema_version'] as num?)?.toInt() ?? 1;
    if (version > currentSchemaVersion) {
      throw SchemaTooNewError('profile', version, currentSchemaVersion);
    }
    return Profile(
      schemaVersion: version,
      id: j['id']! as String,
      type: ProfileType.values.byName(j['type']! as String),
      createdAt: DateTime.parse(j['created_at']! as String).toUtc(),
      displayName: j['display_name'] as String?,
    );
  }
}
