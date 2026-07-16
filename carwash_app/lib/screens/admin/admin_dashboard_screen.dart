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
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Very light grey background
        appBar: AppBar(
          title: const Text('Admin Dashboard',
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          backgroundColor: const Color(0xFF0D47A1), // Deep Blue
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white, // White underline for active tab
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Washed'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
            : TabBarView(
                children: [
                  _buildList(_pendingBookings, Colors.orange),
                  _buildList(_approvedBookings, Color(0xFF0D47A1)),
                  _buildList(_washedBookings, Colors.green),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<BookingModel> bookings, Color accentColor) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No bookings here.',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            elevation: 3, // Soft shadow
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)), // Rounded corners
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AdminBookingDetailScreen(booking: booking)),
                );
                if (result == true) _fetchBookings();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Left Color Indicator Bar
                    Container(
                      width: 5,
                      height: 50,
                      decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.customerName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF263238))),
                          const SizedBox(height: 6),
                          Text(
                              '📞 ${booking.customerPhone} | 🚗 ${booking.vehicleType}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text('📅 ${booking.date} at ${booking.time}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                          if (booking.assignedTo != null &&
                              booking.assignedTo!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                  '👷 Assigned to: ${booking.assignedTo}',
                                  style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                        ],
                      ),
                    ),
                    // Right Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: Icon(Icons.chevron_right, color: accentColor),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
