import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewOrdersScreen extends StatefulWidget {
  const ViewOrdersScreen({super.key});

  @override
  State<ViewOrdersScreen> createState() => _ViewOrdersScreenState();
}

class _ViewOrdersScreenState extends State<ViewOrdersScreen> {
  final CollectionReference ordersRef = FirebaseFirestore.instance.collection(
    'orders',
  );

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await ordersRef.doc(orderId).update({'status': newStatus});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order marked as $newStatus')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
    }
  }

  Widget _buildOrderTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List items = data['items'] ?? [];
    final total = data['total'] ?? 0.0;
    final address = data['address'] ?? 'No address';
    final status = data['status'] ?? 'Pending';
    final timestamp = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();

    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text('Order ID: ${doc.id.substring(0, 6)}...'),
        subtitle: Text('Status: $status\nTotal: ₹${total.toStringAsFixed(2)}'),
        children: [
          ListTile(
            title: const Text('Delivery Address'),
            subtitle: Text(address),
          ),
          ListTile(
            title: const Text('Ordered Items'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) {
                    return Text(
                      '${item['name']} × ${item['quantity']} @ ₹${item['price']}',
                    );
                  })
                  .toList()
                  .cast<Widget>(),
            ),
          ),
          ListTile(
            title: const Text('Order Time'),
            subtitle: Text(timestamp.toLocal().toString()),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _updateOrderStatus(doc.id, 'Delivered'),
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark Delivered'),
              ),
              ElevatedButton.icon(
                onPressed: () => _updateOrderStatus(doc.id, 'Cancelled'),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders available."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) => _buildOrderTile(orders[index]),
          );
        },
      ),
    );
  }
}
