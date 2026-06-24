import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();

  List<dynamic> _employees = [];
  List<dynamic> _requests = [];
  List<dynamic> _attendance = [];
  Map<String, double> _officeLocation = {'lat': -6.200000, 'lng': 106.816666};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final employees = await _adminService.getAllUsers();
    final requests = await _adminService.getAllRequests();
    final attendance = await _adminService.getAllAttendance();
    final location = await _adminService.getOfficeLocation();

    if (mounted) {
      setState(() {
        _employees = employees;
        _requests = requests;
        _attendance = attendance;
        _officeLocation = location;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Employees'),
            Tab(icon: Icon(Icons.assignment), text: 'Requests'),
            Tab(icon: Icon(Icons.warning), text: 'Anomalies'),
            Tab(icon: Icon(Icons.settings), text: 'Office Settings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildEmployeesTab(),
                _buildRequestsTab(),
                _buildAnomaliesTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    int totalEmployees = _employees.length;
    int pendingRequests = _requests.where((r) => r['status'] == 'Pending').length;
    
    // Count today's attendance
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    int presentToday = _attendance.where((a) => a['checkInTime'].toString().startsWith(todayStr)).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Employees', totalEmployees.toString(), Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Present Today', presentToday.toString(), Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Pending Requests', pendingRequests.toString(), Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Total Records', _attendance.length.toString(), Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesTab() {
    if (_employees.isEmpty) return const Center(child: Text('No employees found.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _employees.length,
      itemBuilder: (context, index) {
        final emp = _employees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              child: Text((emp['name'] ?? 'U')[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
            title: Text(emp['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${emp['email']} • ${emp['department']}'),
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    if (_requests.isEmpty) return const Center(child: Text('No requests found.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final req = _requests[index];
        final isPending = req['status'] == 'Pending';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${req['type']} Request', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(req['date'] ?? '', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('From: ${req['userName']}'),
                const SizedBox(height: 16),
                if (isPending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await _adminService.updateRequestStatus(req['id'], 'Rejected');
                          _loadData();
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await _adminService.updateRequestStatus(req['id'], 'Approved');
                          _loadData();
                        },
                        child: const Text('Approve'),
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Status: ${req['status']}', style: TextStyle(color: req['status'] == 'Approved' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnomaliesTab() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final anomalies = appState.anomalyReports;
        
        if (anomalies.isEmpty) {
          return const Center(child: Text('No anomalies detected in the system.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: anomalies.length,
          itemBuilder: (context, index) {
            final anomaly = anomalies[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(anomaly.type.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                subtitle: Text(anomaly.description),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    final latController = TextEditingController(text: _officeLocation['lat'].toString());
    final lngController = TextEditingController(text: _officeLocation['lng'].toString());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Office Location Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Set the central coordinate for geofencing (radius is handled in backend/logic).'),
              const SizedBox(height: 16),
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final lat = double.tryParse(latController.text);
                    final lng = double.tryParse(lngController.text);
                    if (lat != null && lng != null) {
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await _adminService.updateOfficeLocation(lat, lng);
                      if (!mounted) return;
                      if (success) {
                        messenger.showSnackBar(const SnackBar(content: Text('Office location updated!')));
                        _loadData();
                      } else {
                        messenger.showSnackBar(const SnackBar(content: Text('Failed to update office location.')));
                      }
                    }
                  },
                  child: const Text('Save Office Location'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
