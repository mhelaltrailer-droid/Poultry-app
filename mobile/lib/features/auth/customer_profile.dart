class CustomerProfile {
  CustomerProfile({
    required this.name,
    required this.familyName,
    required this.mobile,
    required this.city,
    required this.district,
    required this.addressDetails,
    required this.deliveryNotes,
  });

  final String name;
  final String familyName;
  final String mobile;
  final String city;
  final String district;
  final String addressDetails;
  final String deliveryNotes;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'familyName': familyName,
      'mobile': mobile,
      'city': city,
      'district': district,
      'addressDetails': addressDetails,
      'deliveryNotes': deliveryNotes,
    };
  }

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      name: (json['name'] ?? '').toString(),
      familyName: (json['familyName'] ?? '').toString(),
      mobile: (json['mobile'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      addressDetails: (json['addressDetails'] ?? '').toString(),
      deliveryNotes: (json['deliveryNotes'] ?? '').toString(),
    );
  }
}
