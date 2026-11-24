class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String locale;
  final String country;
  final String timezone;
  final String status;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.locale,
    required this.country,
    required this.timezone,
    required this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      locale: (json['locale'] as String?) ?? 'ar',
      country: (json['country'] as String?) ?? 'EG',
      timezone: (json['timezone'] as String?) ?? 'Africa/Cairo',
      status: (json['status'] as String?) ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'locale': locale,
    'country': country,
    'timezone': timezone,
    'status': status,
  };
}
