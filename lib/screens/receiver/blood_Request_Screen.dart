// ============================================================================
// FILE: lib/screens/receiver/blood_requests_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/AppTheme_data.dart';
import '../../utils/constants.dart';
import '../chat/ChatSCreen.dart';

class BloodRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blood Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.requestsCollection)
            .where('status', isEqualTo: 'active')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No active blood requests',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final request = doc.data() as Map<String, dynamic>;

              Color urgencyColor = request['urgency'] == 'critical'
                  ? Colors.red
                  : request['urgency'] == 'urgent'
                  ? Colors.orange
                  : Colors.green;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              request['bloodType'] ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: urgencyColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (request['urgency'] ?? 'normal').toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Hospital: ${request['hospital'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('City: ${request['city'] ?? 'N/A'}'),
                      Text('Address: ${request['address'] ?? 'N/A'}'),
                      if (request['requiredBy'] != null)
                        Text(
                          'Required by: ${DateFormat('MMM dd, yyyy').format((request['requiredBy'] as Timestamp).toDate())}',
                          style: TextStyle(color: Colors.red),
                        ),
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                otherUserId: request['requesterId'],
                                otherUserName: request['requesterName'],
                                otherUserBloodType: request['bloodType'],
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.chat),
                        label: Text('Contact'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
