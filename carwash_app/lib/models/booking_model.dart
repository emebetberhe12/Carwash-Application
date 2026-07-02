class BookingModel {
  final int id;
  final String customerName;
  final String customerPhone;
  final String? customerLat;
  final String? customerLng;
  final int carWashId;
  final String date;
  final String time;
  final String? vehicleType;
  final String? notes;
  final String? assignedTo; // <--- I ADDED THIS
  final String status;

  BookingModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerLat,
    this.customerLng,
    required this.carWashId,
    required this.date,
    required this.time,
    this.vehicleType,
    this.notes,
    this.assignedTo, // <--- I ADDED THIS
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      customerName: json['customer_name'] ?? 'Unknown',
      customerPhone: json['customer_phone'] ?? '',
      customerLat: json['customer_lat']?.toString(),
      customerLng: json['customer_lng']?.toString(),
      carWashId: json['car_wash_id'] ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      vehicleType: json['vehicle_type'] ?? 'Sedan',
      notes: json['notes'] ?? '',
      assignedTo: json['assigned_to'] ?? '', // <--- I ADDED THIS
      status: json['status'] ?? 'pending',
    );
  }
}
