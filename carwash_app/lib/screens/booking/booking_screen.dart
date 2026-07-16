import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../models/carwash_model.dart';
import '../../services/api_service.dart';
import '../../main.dart'; // Imports the HomeScreen
import '../admin/admin_dashboard_screen.dart';

class BookingScreen extends StatefulWidget {
  final CarWashModel? carWash; // Added ? to make it optional
  const BookingScreen({super.key, this.carWash}); // Removed 'required'
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedTime = '10:00 AM';
  String _selectedVehicleType = 'Sedan'; // Default value
  final List<String> _vehicleTypes = [
    'Sedan',
    'SUV',
    'Truck',
    'Van',
    'Motorcycle',
    'Other'
  ];
  bool _isSubmitting = false;

  String _currentLocation = 'Fetching location...';
  double? _userLat;
  double? _userLng;

  final List<String> _timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get phone's GPS location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _currentLocation = 'Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _currentLocation = 'Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() =>
          _currentLocation = 'Location permissions are permanently denied.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userLat = position.latitude;
      _userLng = position.longitude;
      _currentLocation = 'Location secured!';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitBooking() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Name and Phone')));
      return;
    }
    if (_userLat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waiting for GPS location...')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiService.post('/bookings', {
        "customer_name": _nameController.text.trim(),
        "customer_phone": _phoneController.text.trim(),
        "customer_lat": _userLat,
        "customer_lng": _userLng,
        "car_wash_id": widget.carWash?.id ?? 1,
        "date": DateFormat('yyyy-MM-dd').format(
            _selectedDate ?? DateTime.now().add(const Duration(days: 1))),
        "time": _selectedTime,
        "vehicle_type": _selectedVehicleType,
      });

      // Show Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                const Text('Success!', style: TextStyle(color: Colors.green)),
            content:
                const Text('Your request is sent. We will contact you soon.'),
            actions: [
              TextButton(
                onPressed: () {
                  _nameController.clear();
                  _phoneController.clear();
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showAdminLogin() {
    showDialog(
      context: context,
      builder: (context) {
        final passwordController = TextEditingController();
        return AlertDialog(
          title: const Text('Admin Login'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter admin password'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (passwordController.text == 'admin123') {
                  // SET YOUR PASSWORD HERE
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminDashboardScreen()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wrong password')));
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1), // Deep Blue App Bar
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.white), // Makes icons white
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            onPressed: () => _showAdminLogin(),
          )
        ],
      ),
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Medium Blue Header
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Center(
                child: Icon(Icons.directions_car_filled,
                    size: 80, color: Colors.white24),
              ),
            ),

            // THE FLOATING WHITE CARD
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text("Enter Your Details",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1))),
                          ),
                          const SizedBox(height: 24),

                          _buildModernField(Icons.person, 'Full Name',
                              _nameController, false),
                          const SizedBox(height: 16),

                          _buildModernField(Icons.phone, 'Phone Number',
                              _phoneController, false,
                              isPhone: true),
                          const SizedBox(height: 16),

                          // Vehicle Type Dropdown
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedVehicleType,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Type',
                                prefixIcon: Icon(Icons.directions_car,
                                    color: Color(0xFF0D47A1)),
                                border: InputBorder.none,
                              ),
                              items: _vehicleTypes.map((type) {
                                return DropdownMenuItem(
                                    value: type, child: Text(type));
                              }).toList(),
                              onChanged: (value) {
                                if (value != null)
                                  setState(() => _selectedVehicleType = value);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Auto Location Indicator (Blue tint)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF0D47A1)),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(_currentLocation,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Date Picker
                          const Text('Select Date',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.grey),
                                  const SizedBox(width: 12),
                                  Text(_selectedDate == null
                                      ? 'Pick a date'
                                      : DateFormat('yyyy-MM-dd')
                                          .format(_selectedDate!)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Time Picker
                          const Text('Select Time',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            children: _timeSlots.map((time) {
                              return ChoiceChip(
                                label: Text(time),
                                selected: _selectedTime == time,
                                onSelected: (selected) {
                                  if (selected)
                                    setState(() => _selectedTime = time);
                                },
                                selectedColor: Colors.blue.shade100,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 30),

                          // PREMIUM BLUE GRADIENT BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0D47A1),
                                    Color(0xFF42A5F5)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : _submitBooking,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isSubmitting
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text('SEND REQUEST',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Search Nearby Button
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeScreen(canBook: false)));
                            },
                            icon: const Icon(Icons.map_outlined,
                                color: Color(0xFF0D47A1)),
                            label: const Text('Search Nearby Car Washes',
                                style: TextStyle(
                                    color: Color(0xFF0D47A1),
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF0D47A1)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper method with Blue focus colors
  Widget _buildModernField(IconData icon, String label,
      TextEditingController controller, bool obscure,
      {bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)), // Blue icons
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFF0D47A1), width: 2), // Blue focus ring
        ),
      ),
      validator: isPhone
          ? (value) {
              if (value == null || value.isEmpty)
                return 'Phone number is required';
              final ethiopianRegex =
                  RegExp(r'^(09|07)\d{8}$|^\+251(9|7)\d{8}$');
              if (!ethiopianRegex.hasMatch(value.trim()))
                return 'Enter a valid Ethiopian number';
              return null;
            }
          : (value) {
              if (value == null || value.isEmpty)
                return 'This field is required';
              return null;
            },
    );
  }
}
