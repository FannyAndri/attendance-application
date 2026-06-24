import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class WFHScreen extends StatefulWidget {
  const WFHScreen({super.key});

  @override
  State<WFHScreen> createState() => _WFHScreenState();
}

class _WFHScreenState extends State<WFHScreen> {
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isLoading = false;
  List<Map<String, dynamic>> _myRequests = [];
  bool _loadingRequests = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMyRequests());
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadMyRequests() async {
    final appState = context.read<AppState>();
    if (appState.currentUser == null) return;

    setState(() => _loadingRequests = true);
    final requests = await appState.attendanceService.getMyRequests(appState.currentUser!.id);
    if (mounted) {
      setState(() {
        _myRequests = requests.where((r) => r['type'] == 'WFH').toList();
        _loadingRequests = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Work From Home Request',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildDateField(
            context,
            'Start Date',
            _selectedStartDate,
            () => _selectDate(context, true),
          ),
          const SizedBox(height: 16),
          _buildDateField(
            context,
            'End Date',
            _selectedEndDate,
            () => _selectDate(context, false),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Reason for WFH',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Submit WFH Request'),
                  ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My WFH Requests', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMyRequests),
            ],
          ),
          const SizedBox(height: 12),
          _loadingRequests
              ? const Center(child: CircularProgressIndicator())
              : _myRequests.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                      child: const Text('No WFH requests yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    )
                  : Column(
                      children: _myRequests.map((req) => _buildRequestCard(req)).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    final status = req['status'] ?? 'Pending';
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'Approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req['date'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text('WFH Request', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date != null ? '${date.day}/${date.month}/${date.year}' : 'Select date'),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = selectedDate;
        } else {
          _selectedEndDate = selectedDate;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedStartDate == null || _selectedEndDate == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    final appState = context.read<AppState>();
    final user = appState.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final dateStr = '${_selectedStartDate!.toIso8601String().split('T')[0]} to ${_selectedEndDate!.toIso8601String().split('T')[0]}';
    
    final success = await appState.attendanceService.submitRequest(user.id, 'WFH', dateStr);
    
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WFH request submitted successfully!'), backgroundColor: Colors.green),
      );
      _reasonController.clear();
      setState(() { _selectedStartDate = null; _selectedEndDate = null; });
      _loadMyRequests();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit. Make sure the server is running.'), backgroundColor: Colors.red),
      );
    }
  }
}
