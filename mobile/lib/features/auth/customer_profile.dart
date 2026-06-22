import 'dart:math';

class SavedPhone {
  const SavedPhone({
    required this.id,
    required this.label,
    required this.number,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String number;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'number': number,
        'isDefault': isDefault,
      };

  factory SavedPhone.fromJson(Map<String, dynamic> json) {
    return SavedPhone(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      number: (json['number'] ?? '').toString(),
      isDefault: json['isDefault'] == true,
    );
  }

  SavedPhone copyWith({
    String? label,
    String? number,
    bool? isDefault,
  }) {
    return SavedPhone(
      id: id,
      label: label ?? this.label,
      number: number ?? this.number,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static String newId() => 'ph_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';
}

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.city,
    required this.district,
    required this.addressDetails,
    this.deliveryNotes = '',
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String city;
  final String district;
  final String addressDetails;
  final String deliveryNotes;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'city': city,
        'district': district,
        'addressDetails': addressDetails,
        'deliveryNotes': deliveryNotes,
        'isDefault': isDefault,
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      city: (json['city'] ?? 'Obour City').toString(),
      district: (json['district'] ?? '').toString(),
      addressDetails: (json['addressDetails'] ?? '').toString(),
      deliveryNotes: (json['deliveryNotes'] ?? '').toString(),
      isDefault: json['isDefault'] == true,
    );
  }

  SavedAddress copyWith({
    String? label,
    String? city,
    String? district,
    String? addressDetails,
    String? deliveryNotes,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id,
      label: label ?? this.label,
      city: city ?? this.city,
      district: district ?? this.district,
      addressDetails: addressDetails ?? this.addressDetails,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static String newId() => 'ad_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';
}

class CustomerProfile {
  CustomerProfile({
    required this.name,
    required this.familyName,
    required this.mobile,
    required this.city,
    required this.district,
    required this.addressDetails,
    required this.deliveryNotes,
    List<SavedPhone>? phones,
    List<SavedAddress>? addresses,
  })  : phones = phones ?? const [],
        addresses = addresses ?? const [];

  final String name;
  final String familyName;
  final String mobile;
  final String city;
  final String district;
  final String addressDetails;
  final String deliveryNotes;
  final List<SavedPhone> phones;
  final List<SavedAddress> addresses;

  SavedPhone get defaultPhone {
    if (phones.isEmpty) {
      return SavedPhone(id: 'legacy', label: 'Mobile', number: mobile, isDefault: true);
    }
    return phones.firstWhere(
      (p) => p.isDefault,
      orElse: () => phones.first,
    );
  }

  SavedAddress get defaultAddress {
    if (addresses.isEmpty) {
      return SavedAddress(
        id: 'legacy',
        label: 'Home',
        city: city,
        district: district,
        addressDetails: addressDetails,
        deliveryNotes: deliveryNotes,
        isDefault: true,
      );
    }
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }

  CustomerProfile copyWith({
    String? name,
    String? familyName,
    String? mobile,
    List<SavedPhone>? phones,
    List<SavedAddress>? addresses,
  }) {
    return CustomerProfile(
      name: name ?? this.name,
      familyName: familyName ?? this.familyName,
      mobile: mobile ?? this.mobile,
      city: city,
      district: district,
      addressDetails: addressDetails,
      deliveryNotes: deliveryNotes,
      phones: phones ?? this.phones,
      addresses: addresses ?? this.addresses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': 2,
      'name': name,
      'familyName': familyName,
      'mobile': defaultPhone.number,
      'city': defaultAddress.city,
      'district': defaultAddress.district,
      'addressDetails': defaultAddress.addressDetails,
      'deliveryNotes': defaultAddress.deliveryNotes,
      'phones': phones.map((e) => e.toJson()).toList(),
      'addresses': addresses.map((e) => e.toJson()).toList(),
    };
  }

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    final version = (json['version'] as num?)?.toInt() ?? 1;
    final name = (json['name'] ?? '').toString();
    final familyName = (json['familyName'] ?? '').toString();
    final mobile = (json['mobile'] ?? '').toString();
    final city = (json['city'] ?? 'Obour City').toString();
    final district = (json['district'] ?? '').toString();
    final addressDetails = (json['addressDetails'] ?? '').toString();
    final deliveryNotes = (json['deliveryNotes'] ?? '').toString();

    if (version >= 2) {
      final phonesRaw = json['phones'] as List<dynamic>? ?? [];
      final addressesRaw = json['addresses'] as List<dynamic>? ?? [];
      return CustomerProfile(
        name: name,
        familyName: familyName,
        mobile: mobile,
        city: city,
        district: district,
        addressDetails: addressDetails,
        deliveryNotes: deliveryNotes,
        phones: phonesRaw
            .map((e) => SavedPhone.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        addresses: addressesRaw
            .map((e) => SavedAddress.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    }

    final phones = mobile.trim().isEmpty
        ? <SavedPhone>[]
        : [
            SavedPhone(
              id: SavedPhone.newId(),
              label: 'Mobile',
              number: mobile.trim(),
              isDefault: true,
            ),
          ];
    final addresses = district.trim().isEmpty && addressDetails.trim().isEmpty
        ? <SavedAddress>[]
        : [
            SavedAddress(
              id: SavedAddress.newId(),
              label: 'Home',
              city: city.trim().isEmpty ? 'Obour City' : city.trim(),
              district: district.trim(),
              addressDetails: addressDetails.trim(),
              deliveryNotes: deliveryNotes.trim(),
              isDefault: true,
            ),
          ];

    return CustomerProfile(
      name: name,
      familyName: familyName,
      mobile: mobile,
      city: city,
      district: district,
      addressDetails: addressDetails,
      deliveryNotes: deliveryNotes,
      phones: phones,
      addresses: addresses,
    );
  }
}
