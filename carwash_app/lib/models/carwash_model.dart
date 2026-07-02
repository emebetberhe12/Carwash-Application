class CarWashModel {
  final int id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final double rating;

  CarWashModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.rating,
  });

  factory CarWashModel.fromJson(Map<String, dynamic> json) {
    return CarWashModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      address: json['address'],
      // .parse() converts the String "9.0100" into a real double number
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      phone: json['phone'] ?? '',
      rating: double.parse(json['rating'].toString()),
    );
  }
}
