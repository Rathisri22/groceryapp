import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/screens/admin/manage_products_screen.dart';
import 'package:grocery_app/screens/admin/view_orders_screen.dart';
import 'package:grocery_app/services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _productCount = 0;
  int _orderCount = 0;
  double _totalSales = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productSnap = await FirebaseFirestore.instance.collection('products').get();
      final orderSnap = await FirebaseFirestore.instance.collection('orders').get();

      int totalProducts = productSnap.docs.length;
      int totalOrders = orderSnap.docs.length;
      double totalSales = 0.0;

      for (var doc in orderSnap.docs) {
        final data = doc.data();
        if (data.containsKey('total')) {
          totalSales += (data['total'] as num).toDouble();
        }
      }

      setState(() {
        _productCount = totalProducts;
        _orderCount = totalOrders;
        _totalSales = totalSales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading dashboard: $e")),
      );
    }
  }

  void _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(icon, size: 36, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildStatCard("Total Products", _productCount.toString(), Icons.inventory, Colors.orange),
                  _buildStatCard("Total Orders", _orderCount.toString(), Icons.receipt_long, Colors.blue),
                  _buildStatCard("Total Sales", "₹${_totalSales.toStringAsFixed(2)}", Icons.attach_money, Colors.green),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text("Manage Products"),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManageProductsScreen()),
                            );
                            _fetchDashboardData(); // Refresh on return
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.list),
                          label: const Text("View Orders"),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ViewOrdersScreen()),
                            );
                            _fetchDashboardData(); // Refresh on return
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
