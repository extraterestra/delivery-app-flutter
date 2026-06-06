double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) {
    final s = value.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
  return null;
}

double _parseDoubleOrZero(dynamic value) {
  final v = _parseNullableDouble(value);
  return v ?? 0.0;
}

class AuthUser {
  final String id;
  final String email;
  final List<String>? roles;

  AuthUser({required this.id, required this.email, this.roles});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      email: json['email'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
    );
  }
}

class Profile {
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final bool isAvailable;
  final double? currentLat;
  final double? currentLng;
  final double totalEarnings;

  Profile({
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.isAvailable,
    this.currentLat,
    this.currentLng,
    required this.totalEarnings,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      fullName: json['full_name'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      isAvailable: json['is_available'] ?? false,
      currentLat: _parseNullableDouble(json['current_lat']),
      currentLng: _parseNullableDouble(json['current_lng']),
      totalEarnings: _parseDoubleOrZero(json['total_earnings']),
    );
  }
}
