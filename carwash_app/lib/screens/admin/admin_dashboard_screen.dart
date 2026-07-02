import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/api_service.dart';
import 'admin_booking_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<BookingModel> _pendingBookings = [];
  List<BookingModel> _approvedBookings = [];
  List<BookingModel> _washedBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final pendingRes = await ApiService.get('/bookings?status=pending');
      final approvedRes = await ApiService.get('/bookings?status=approved');
      final washedRes = await ApiService.get('/bookings?status=completed');

      setState(() {
        _pendingBookings = (pendingRes.data['data'] as List)
            .map((e) => BookingModel.fromJson(e))
            .toList();
        _approvedBookings = (approvedRes.data['data'] as List)
            .map((e) => BookingModel.fromJson(e))
            .toList();
        _washedBookings = (washedRes.data['data'] as List)
            .map((e) => BookingModel.fromJson(e))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching admin data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // <--- CHANGED TO 3 TABS
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            isScrollable: true, // Prevents text squishing
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Washed'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildList(_pendingBookings, Colors.orange),
                  _buildList(_approvedBookings, Colors.blue),
                  _buildList(_washedBookings, Colors.green),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<BookingModel> bookings, Color color) {
    if (bookings.isEmpty) {
      return const Center(
          child:
              Text('No bookings here.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(booking.customerName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '📞 ${booking.customerPhone} | 🚗 ${booking.vehicleType}'),
                  Text('📅 ${booking.date} at ${booking.time}'),
                  if (booking.assignedTo != null &&
                      booking.assignedTo!.isNotEmpty)
                    Text('👷 Assigned to: ${booking.assignedTo}',
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: Icon(Icons.check_circle, color: color),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AdminBookingDetailScreen(booking: booking)),
                );
                if (result == true) _fetchBookings();
              },
            ),
          );
        });
  }
}
