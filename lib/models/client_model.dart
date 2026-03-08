class ClientModel {
  int? id;
  String image;
  String name;
  String email; // Case Category
  int age;      // Hearing Number
  String hearingDate; // 🌟 NAYA FEATURE: Hearing Date 🌟

  ClientModel({
    this.id,
    required this.image,
    required this.name,
    required this.email,
    required this.age,
    required this.hearingDate, // Initialize kiya
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'email': email,
      'age': age,
      'hearingDate': hearingDate, // Map mein add kiya
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'],
      image: map['image'] ?? '',
      name: map['name'] ?? 'Unknown',
      email: map['email'] ?? 'Uncategorized',
      age: map['age'] ?? 0,
      hearingDate: map['hearingDate'] ?? 'No Date Set', // DB se fetch kiya
    );
  }

  ClientModel copyWith({
    int? id,
    String? image,
    String? name,
    String? email,
    int? age,
    String? hearingDate,
  }) {
    return ClientModel(
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      hearingDate: hearingDate ?? this.hearingDate,
    );
  }
}