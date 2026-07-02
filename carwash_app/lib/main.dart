import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/carwash/carwash_detail_screen.dart';
import 'utils/constants.dart';
import 'models/carwash_model.dart';
import 'services/api_service.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const CarWashApp());
}

class CarWashApp extends StatelessWidget {
  const CarWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      home: const SplashScreen(),
    );
  }
}

// --- SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToForm();
  }

  Future<void> _goToForm() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BookingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_car_wash, size: 120, color: Colors.blue[700]),
            const SizedBox(height: 24),
            Text(AppConstants.appName,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Book your wash in seconds',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// --- MAP / HOME SCREEN ---
class HomeScreen extends StatefulWidget {
  final bool canBook;

  const HomeScreen({super.key, this.canBook = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<Marker> _markers = {};
  bool _isLoading = true;
  LatLng _initialPosition =
      const LatLng(9.0054, 38.7636); // Default to Addis Ababa

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Get location first!
  }

  // NEW: Get the user's real GPS location
  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      print(
          "Error getting location: $e"); // If they deny permission, it just stays at default city
    }

    // Whether location works or fails, load the car wash pins
    _loadCarWashes();
  }

  Future<void> _loadCarWashes() async {
    try {
      final response = await ApiService.get('/carwashes');
      final List<CarWashModel> carWashes = (response.data['data'] as List)
          .map((e) => CarWashModel.fromJson(e))
          .toList();

      setState(() {
        _markers = carWashes.map((wash) {
          return Marker(
            markerId: MarkerId(wash.id.toString()),
            position: LatLng(wash.latitude, wash.longitude),
            infoWindow: InfoWindow(
              title: wash.name,
              snippet: 'Rating: ${wash.rating.toString()} ⭐',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarWashDetailScreen(
                      carWash: wash, canBook: widget.canBook),
                ),
              );
            },
          );
        }).toSet();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading car washes: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Car Washes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              // NOW IT USES THEIR REAL GPS LOCATION!
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0, // Zoomed in closer to their street
              ),
              markers: _markers,
              mapType: MapType.normal,
              myLocationEnabled:
                  true, // Shows the little blue dot for their location
              onMapCreated: (controller) {
                print('Map Created with ${_markers.length} markers!');
              },
            ),
    );
  }
}
