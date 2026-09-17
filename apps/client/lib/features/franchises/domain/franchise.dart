/// A brand or company that operates one or more escape rooms.
class Franchise {
  const Franchise({
    required this.id,
    required this.name,
    this.logoPath,
    this.updatedAt,
  });

  /// A UUID, minted when the franchise is first stored.
  final String id;
  final String name;

  /// Absolute path to a logo image stored in the app documents directory.
  final String? logoPath;

  /// When the franchise was last written. Null only before it is stored.
  final DateTime? updatedAt;

  Franchise copyWith({String? name, String? logoPath, bool clearLogo = false}) {
    return Franchise(
      id: id,
      updatedAt: updatedAt,
      name: name ?? this.name,
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Franchise &&
      other.id == id &&
      other.name == name &&
      other.logoPath == logoPath &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, name, logoPath, updatedAt);
}

/// Input for creating a franchise, before the store assigns an id.
class FranchiseDraft {
  const FranchiseDraft({required this.name, this.logoPath});

  final String name;
  final String? logoPath;
}
