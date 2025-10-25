// ============================================================================
// FILE: lib/screens/auth/registration_screen.dart
// User registration screen
// ============================================================================

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/AppTheme_data.dart';
import '../../widgets/Custom_textfield.dart';
import '../../utils/constants.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _ageController = TextEditingController();
  final _authService = AuthService();

  String _selectedBloodType = 'A+';
  String _selectedUserType = 'donor';
  bool _isLoading = false;

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _ageController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create auth account
      final userCredential = await _authService.register(
        _emailController.text,
        _passwordController.text,
      );

      // Create user document in Firestore
      await _authService.createUserDocument(
        uid: userCredential.user!.uid,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        bloodType: _selectedBloodType,
        city: _cityController.text,
        userType: _selectedUserType,
        age: int.parse(_ageController.text),
      );

      _showSuccess('Registration successful!');
      Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _nameController,
              hint: 'Full Name',
              label: 'Full Name',
              icon: Icons.person,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              hint: 'Email',
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              hint: 'Password',
              label: 'Password',
              icon: Icons.lock,
              isPassword: true,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              hint: 'Phone Number',
              label: 'Phone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _cityController,
              hint: 'City',
              label: 'City',
              icon: Icons.location_city,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _ageController,
              hint: 'Age',
              label: 'Age',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            // Blood Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedBloodType,
              decoration: InputDecoration(
                labelText: 'Blood Type',
                prefixIcon: Icon(Icons.bloodtype, color: AppTheme.primaryRed),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: AppConstants.bloodTypes.map((String type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedBloodType = value!);
              },
            ),
            SizedBox(height: 16),
            // User Type Selection
            Text(
              'Register as:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Donor'),
                    value: 'donor',
                    groupValue: _selectedUserType,
                    activeColor: AppTheme.primaryRed,
                    onChanged: (value) {
                      setState(() => _selectedUserType = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Receiver'),
                    value: 'receiver',
                    groupValue: _selectedUserType,
                    activeColor: AppTheme.primaryRed,
                    onChanged: (value) {
                      setState(() => _selectedUserType = value!);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _register,
              child: Text('Register', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}