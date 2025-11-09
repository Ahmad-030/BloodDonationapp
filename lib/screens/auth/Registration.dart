import 'package:blooddonation/screens/auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/AppTheme_data.dart';
import '../../utils/constants.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
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
  bool _obscurePassword = true;

  // Update your _register method in _RegistrationScreenState

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.register(
        _emailController.text,
        _passwordController.text,
      );

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

      // 🔥 CRITICAL: Save FCM token immediately after registration
      await _saveFCMToken(userCredential.user!.uid);

      _showSuccess('Registration successful!');
      Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

// 🔥 NEW METHOD: Save FCM token after successful registration
  Future<void> _saveFCMToken(String userId) async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();

      if (token != null) {
        print('🔑 Registration - Saving FCM Token for user: $userId');
        print('📱 Token: $token');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('✅ Registration - FCM Token saved successfully');
      } else {
        print('⚠️ Registration - No FCM token available');
      }
    } catch (e) {
      print('❌ Registration - Error saving FCM token: $e');
      // Don't show error to user - this is a background operation
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
        title: Text('Create Account'),
        elevation: 0,
        backgroundColor: AppTheme.primaryRed,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8),

              // Full Name
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Name is required';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'your.email@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!value!.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Password
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter strong password',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.primaryRed,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Password is required';
                  if (value!.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+92-300-0000000',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Phone is required';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // City
              _buildTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Your city name',
                icon: Icons.location_city_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'City is required';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Age
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                hint: 'Your age',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Age is required';
                  final age = int.tryParse(value!);
                  if (age == null || age < 18)
                    return 'Must be at least 18 years old';
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Blood Type Selection
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  decoration: InputDecoration(
                    labelText: 'Blood Type',
                    prefixIcon: Icon(Icons.bloodtype, color: AppTheme.primaryRed),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  items: AppConstants.bloodTypes.map((String type) {
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
              SizedBox(height: 20),

              // User Type Selection
              Text(
                'Register as:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildUserTypeButton('Donor', 'donor'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildUserTypeButton('Receiver', 'receiver'),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryRed,
                  disabledBackgroundColor: Colors.grey[400],
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Login Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: AppTheme.textLight),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
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
        labelStyle: TextStyle(color: AppTheme.textDark),
        hintStyle: TextStyle(color: AppTheme.textHint),
      ),
    );
  }

  Widget _buildUserTypeButton(String label, String value) {
    final isSelected = _selectedUserType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedUserType = value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed : Colors.white,
          border: Border.all(
            color:
            isSelected ? AppTheme.primaryRed : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
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