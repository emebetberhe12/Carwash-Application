import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/booking_model.dart';
import '../../services/api_service.dart';
import 'package:flutter/services.dart';

class AdminBookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const AdminBookingDetailScreen({super.key, required this.booking});

  @override
  State<AdminBookingDetailScreen> createState() =>
      _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends State<AdminBookingDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _vehicleController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _assignedToController;
  late TextEditingController _notesController;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.booking.customerName);
    _vehicleController =
        TextEditingController(text: widget.booking.vehicleType ?? 'Sedan');
    _dateController = TextEditingController(text: widget.booking.date);
    _timeController = TextEditingController(text: widget.booking.time);
    _assignedToController =
        TextEditingController(text: widget.booking.assignedTo ?? '');
    _notesController = TextEditingController(text: widget.booking.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vehicleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _assignedToController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(' ', '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // OPEN CUSTOMER LOCATION IN GOOGLE MAPS
  Future<void> _openCustomerLocation() async {
    if (widget.booking.customerLat == null ||
        widget.booking.customerLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer did not share location.')));
      return;
    }

    // Creates a link like: geo:9.0054,38.7636
    final Uri mapUri = Uri.parse(
        'geo:${widget.booking.customerLat},${widget.booking.customerLng}?q=${widget.booking.customerLat},${widget.booking.customerLng}');

    // Try to open native Google Maps app
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    } else {
      // Fallback: Open in web browser if no map app is installed
      final webUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${widget.booking.customerLat},${widget.booking.customerLng}');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      // Only send editable fields if status is 'pending'
      Map<String, dynamic> data = {
        "status": newStatus,
        "notes": _notesController.text,
        "assigned_to": _assignedToController.text,
      };

      if (widget.booking.status == 'pending') {
        data["customer_name"] = _nameController.text;
        data["vehicle_type"] = _vehicleController.text;
        data["date"] = _dateController.text;
        data["time"] = _timeController.text;
      }

      await ApiService.put('/bookings/${widget.booking.id}', data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(newStatus == 'approved'
                ? '✅ Approved!'
                : '🧼 Marked as Washed!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  // PRINTING LOGIC
  Future<void> _printReceipt() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('CarWash Pro - Wash Receipt',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Customer: ${widget.booking.customerName}',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Phone: ${widget.booking.customerPhone}',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Vehicle: ${widget.booking.vehicleType}',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Date: ${widget.booking.date} at ${widget.booking.time}',
                  style: const pw.TextStyle(fontSize: 16)),
              if (widget.booking.assignedTo != null &&
                  widget.booking.assignedTo!.isNotEmpty)
                pw.Text('Washed By: ${widget.booking.assignedTo}',
                    style: const pw.TextStyle(fontSize: 16)),
              pw.Divider(),
              if (widget.booking.notes != null &&
                  widget.booking.notes!.isNotEmpty)
                pw.Text('Notes: ${widget.booking.notes}',
                    style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 40),
              pw.Text('Thank you for your business!',
                  style: pw.TextStyle(
                      fontSize: 18, fontStyle: pw.FontStyle.italic)),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // Helper for read-only text display
  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  // Helper for editable text field
  Widget _buildEditField(String label, TextEditingController controller,
      {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.booking.status;
    final bool isPending = status == 'pending';
    final bool isApproved = status == 'approved';
    final bool isWashed = status == 'completed';

    return Scaffold(
      appBar: AppBar(
        title: Text(isWashed ? 'Washed Receipt' : 'Manage Request'),
        actions: [
          if (!isWashed)
            SizedBox(
              width: 20, // Makes the tap area smaller
              height: 20,
              child: IconButton(
                padding: EdgeInsets.zero, // Removes extra padding
                icon: const Icon(Icons.phone_outlined,
                    color: Colors.white, size: 20), // Thinner, smaller icon
                onPressed: () => _makePhoneCall(widget.booking.customerPhone),
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPending) ...[
              const Text('Edit Details:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildEditField('Customer Name', _nameController,
                  icon: Icons.person),
              _buildEditField('Vehicle Type', _vehicleController,
                  icon: Icons.directions_car),
              _buildEditField('Date (YYYY-MM-DD)', _dateController,
                  icon: Icons.calendar_today),
              _buildEditField('Time (HH:MM)', _timeController,
                  icon: Icons.access_time),
              const SizedBox(height: 12),
              // Minimized Location Button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _openCustomerLocation,
                  icon: const Icon(Icons.my_location,
                      color: Colors.red, size: 18),
                  label: const Text('View on Map',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ),
            ] else ...[
              // READ ONLY VIEW
              _buildReadOnlyRow('Customer', widget.booking.customerName),
              _buildReadOnlyRow('Phone', widget.booking.customerPhone),
              const SizedBox(height: 12),
              // Minimized Location Button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _openCustomerLocation,
                  icon: const Icon(Icons.my_location,
                      color: Colors.red, size: 18),
                  label: const Text('View on Map',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ),
              const SizedBox(height: 12),
              _buildReadOnlyRow('Vehicle', widget.booking.vehicleType ?? 'N/A'),
              _buildReadOnlyRow('Date & Time',
                  '${widget.booking.date} at ${widget.booking.time}'),
              if (widget.booking.assignedTo != null &&
                  widget.booking.assignedTo!.isNotEmpty)
                _buildReadOnlyRow('Washer', widget.booking.assignedTo!),
            ],

            const Divider(height: 32),

            // ASSIGNMENT & NOTES (Editable for Pending & Approved)
            if (!isWashed) ...[
              _buildEditField('Assign Worker', _assignedToController,
                  icon: Icons.person_pin),
              const Text('Internal Notes:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder())),
            ] else ...[
              if (widget.booking.notes != null &&
                  widget.booking.notes!.isNotEmpty)
                _buildReadOnlyRow('Notes', widget.booking.notes!),
            ],

            const SizedBox(height: 40),

            // ACTION BUTTONS BASED ON STATUS
            if (isPending)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isUpdating ? null : () => _updateStatus('approved'),
                  child: _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('APPROVE & ASSIGN',
                          style: TextStyle(fontSize: 18)),
                ),
              )
            else if (isApproved)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple),
                  onPressed:
                      _isUpdating ? null : () => _updateStatus('completed'),
                  child: _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('MARK AS WASHED',
                          style: TextStyle(fontSize: 18)),
                ),
              )
            else if (isWashed)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _printReceipt,
                  icon: const Icon(Icons.print),
                  label: const Text('PRINT / SAVE RECEIPT',
                      style: TextStyle(fontSize: 18)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(width: 2)),
                ),
              )
          ],
        ),
      ),
    );
  }
}
