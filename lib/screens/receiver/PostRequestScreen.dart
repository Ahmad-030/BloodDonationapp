import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/Custom_textfield.dart';

class PostRequestScreen extends StatefulWidget {
  @override
  _PostRequestScreenState createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _hospitalController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  String _selectedBloodType = 'A+';
  String _selectedUrgency = 'normal';
  DateTime _requiredBy = DateTime.now().add(Duration(days: 1));
  bool _isLoading = false;

  Future<void> _postRequest() async {
    if (_hospitalController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userData = Provider.of<UserProvider>(context, listen: false).userData;

    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.requestsCollection)
          .add({
        'requesterId': userData?['uid'],
        'requesterName': userData?['name'],
        'bloodType': _selectedBloodType,
        'hospital': _hospitalController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'urgency': _selectedUrgency,
        'requiredBy': Timestamp.fromDate(_requiredBy),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'responses': [],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Blood request posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post request'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post Blood Request')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedBloodType,
              decoration: InputDecoration(
                labelText: 'Blood Type Needed',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.bloodTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedBloodType = value!);
              },
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _hospitalController,
              hint: 'Hospital Name',
              label: 'Hospital Name',
              icon: Icons.local_hospital,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _addressController,
              hint: 'Hospital Address',
              label: 'Hospital Address',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _cityController,
              hint: 'City',
              label: 'City',
              icon: Icons.location_city,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUrgency,
              decoration: InputDecoration(
                labelText: 'Urgency Level',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                DropdownMenuItem(value: 'critical', child: Text('Critical')),
              ],
              onChanged: (value) {
                setState(() => _selectedUrgency = value!);
              },
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Required By'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_requiredBy)),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _requiredBy,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _requiredBy = date);
                }
              },
              tileColor: Color(0xFFFFCDD2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 32),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _postRequest,
              child: Text('Post Request', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}