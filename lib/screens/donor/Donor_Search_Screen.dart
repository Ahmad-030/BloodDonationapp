// ============================================================================
// FILE: lib/screens/donor/donor_search_screen.dart
// Search donors by blood type and city
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../theme/AppTheme_data.dart';
import '../../utils/constants.dart';
import '../../providers/user_provider.dart';
import '../chat/ChatSCreen.dart';

class DonorSearchScreen extends StatefulWidget {
  @override
  _DonorSearchScreenState createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  String _selectedBloodType = 'All';
  final _cityController = TextEditingController();
  List<Map<String, dynamic>> _donors = [];
  bool _isSearching = false;

  Future<void> _searchDonors() async {
    setState(() => _isSearching = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .where('userType', isEqualTo: 'donor');

      if (_selectedBloodType != 'All') {
        query = query.where('bloodType', isEqualTo: _selectedBloodType);
      }

      if (_cityController.text.isNotEmpty) {
        query = query.where('city', isEqualTo: _cityController.text.trim());
      }

      QuerySnapshot snapshot = await query.get();

      setState(() {
        _donors = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching donors: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Find Donors')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: AppTheme.lightRed,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  decoration: InputDecoration(
                    labelText: 'Blood Type',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: AppConstants.bloodTypesWithAll.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedBloodType = value!);
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City (Optional)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _searchDonors,
                  icon: Icon(Icons.search),
                  label: Text('Search Donors'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator())
                : _donors.isEmpty
                ? Center(
              child: Text(
                'No donors found.\nTry different filters.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _donors.length,
              itemBuilder: (context, index) {
                final donor = _donors[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryRed,
                      child: Text(
                        donor['bloodType'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      donor['name'] ?? 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${donor['city'] ?? ''}\n${donor['phone'] ?? ''}',
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              otherUserId: donor['uid'],
                              otherUserName: donor['name'],
                              otherUserBloodType: donor['bloodType'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text('Chat'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}