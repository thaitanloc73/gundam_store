import 'package:flutter/material.dart';

class AdminCustomerScreen extends StatelessWidget {
  const AdminCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý khách hàng')),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('Khách hàng ${index + 1}'),
              subtitle: const Text('Email: user@example.com\nSĐT: 0123456789'),
              isThreeLine: true,
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: index == 0 ? Colors.red : Colors.green,
                ),
                onPressed: () {},
                child: Text(
                  index == 0 ? 'Khóa' : 'Mở khóa', 
                  style: const TextStyle(color: Colors.white)
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}