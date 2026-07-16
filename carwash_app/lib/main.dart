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

// --- PREMIUM BLUE SPLASH SCREEN ---
// --- MINIMALIST PREMIUM SPLASH SCREEN ---
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
    await Future.delayed(
        const Duration(seconds: 2)); // Shorter time for a cleaner feel
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BookingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Just the icon, no circle, no background
            Icon(
              Icons.local_car_wash,
              size: 100,
              color: Color(0xFF0D47A1), // Deep Blue
            ),
            SizedBox(height: 30),

            // Clean, bold text
            Text(
              'CarWash Pro',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800, // Extra bold
                color: Color(
                    0xFF263238), // Dark Charcoal grey (softer than pure black)
                letterSpacing:
                    -0.5, // Slightly tighter letters looks more modern
              ),
            ),
            SizedBox(height: 10),

            // Subtle grey subtext
            Text(
              'Premium Car Care',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey, // Light grey
                fontWeight: FontWeight.w500,
              ),
            ),
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
