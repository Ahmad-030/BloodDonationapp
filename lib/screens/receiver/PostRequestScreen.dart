import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../theme/AppTheme_data.dart';

class PostRequestScreen extends StatefulWidget {
  @override
  _PostRequestScreenState createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  String _selectedBloodType = 'A+';
  String _selectedUrgency = 'normal';
  DateTime _requiredBy = DateTime.now().add(Duration(days: 1));
  bool _isLoading = false;

  Future<void> _postRequest() async {
    if (!_formKey.currentState!.validate()) {
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

      _showSuccess('Blood request posted successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showError('Failed to post request: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: Text('Post Blood Request'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Blood Now',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fill in the details to post your blood request',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Blood Type Selection
              Text(
                'Blood Type Needed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                  boxShadow: [AppTheme.cardShadow],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.bloodtype, color: AppTheme.primaryRed),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  items: AppConstants.bloodTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedBloodType = value!);
                  },
                ),
              ),
              SizedBox(height: 24),

              // Hospital Name
              Text(
                'Hospital Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 12),
              _buildTextField(
                controller: _hospitalController,
                hint: 'Enter hospital name',
                icon: Icons.local_hospital_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Hospital name is required';
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Address
              Text(
                'Hospital Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 12),
              _buildTextField(
                controller: _addressController,
                hint: 'Enter complete address',
                icon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Address is required';
                  return null;
                },
              ),
              SizedBox(height: 24),

              // City
              Text(
                'City',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 12),
              _buildTextField(
                controller: _cityController,
                hint: 'Enter city name',
                icon: Icons.location_city_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'City is required';
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Urgency Level
              Text(
                'Urgency Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildUrgencyButton('Normal', 'normal'),
                  SizedBox(width: 10),
                  _buildUrgencyButton('Urgent', 'urgent'),
                  SizedBox(width: 10),
                  _buildUrgencyButton('Critical', 'critical'),
                ],
              ),
              SizedBox(height: 24),

              // Required Date
              Text(
                'Required By',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                  boxShadow: [AppTheme.cardShadow],
                ),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: AppTheme.primaryRed),
                  title: Text(
                    DateFormat('MMM dd, yyyy').format(_requiredBy),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: AppTheme.textLight),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _requiredBy,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppTheme.primaryRed,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() => _requiredBy = date);
                    }
                  },
                ),
              ),
              SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _postRequest,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryRed,
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'Post Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines == 1 ? 1 : maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryRed),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        hintStyle: TextStyle(color: AppTheme.textHint),
      ),
    );
  }

  Widget _buildUrgencyButton(String label, String value) {
    final isSelected = _selectedUrgency == value;
    Color getColor() {
      if (value == 'critical') return Colors.red;
      if (value == 'urgent') return Colors.orange;
      return Colors.green;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedUrgency = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? getColor().withOpacity(0.2) : Colors.white,
            border: Border.all(
              color: isSelected ? getColor() : Colors.grey[300]!,
              width: isSelected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? getColor() : AppTheme.textLight,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 12,
            ),
          ),
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