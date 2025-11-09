// Create this file: lib/screens/debug/token_verification_screen.dart
// Use this to verify FCM tokens are being saved correctly

import 'package:blooddonation/theme/AppTheme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TokenVerificationScreen extends StatefulWidget {
  @override
  _TokenVerificationScreenState createState() => _TokenVerificationScreenState();
}

class _TokenVerificationScreenState extends State<TokenVerificationScreen> {
  String? _currentToken;
  String? _firestoreToken;
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    setState(() => _isLoading = true);

    try {
      // Get current FCM token
      final messaging = FirebaseMessaging.instance;
      _currentToken = await messaging.getToken();

      // Get user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      _userId = currentUser?.uid;

      // Get token from Firestore
      if (_userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();

        if (doc.exists) {
          _firestoreToken = doc.data()?['fcmToken'];
        }
      }
    } catch (e) {
      print('Error loading tokens: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveTokenToFirestore() async {
    if (_userId == null || _currentToken == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .set({
        'fcmToken': _currentToken,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Token saved to Firestore!'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadTokens();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Token Verification'),
        backgroundColor: AppTheme.primaryRed,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadTokens,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // User ID Card
            _buildCard(
              title: '👤 User ID',
              content: _userId ?? 'Not logged in',
              icon: Icons.person,
              color: Colors.blue,
              onCopy: _userId != null ? () => _copyToClipboard(_userId!) : null,
            ),
            SizedBox(height: 16),

            // Current FCM Token
            _buildCard(
              title: '📱 Current FCM Token',
              content: _currentToken ?? 'No token available',
              icon: Icons.token,
              color: Colors.green,
              onCopy: _currentToken != null ? () => _copyToClipboard(_currentToken!) : null,
            ),
            SizedBox(height: 16),

            // Firestore Token
            _buildCard(
              title: '🔥 Firestore Token',
              content: _firestoreToken ?? 'Not saved in Firestore',
              icon: Icons.cloud,
              color: _firestoreToken != null ? Colors.green : Colors.red,
              onCopy: _firestoreToken != null ? () => _copyToClipboard(_firestoreToken!) : null,
            ),
            SizedBox(height: 24),

            // Status Check
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentToken == _firestoreToken
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _currentToken == _firestoreToken
                      ? Colors.green
                      : Colors.orange,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _currentToken == _firestoreToken
                        ? Icons.check_circle
                        : Icons.warning,
                    color: _currentToken == _firestoreToken
                        ? Colors.green
                        : Colors.orange,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    _currentToken == _firestoreToken
                        ? '✅ Tokens Match!'
                        : '⚠️ Tokens Don\'t Match',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _currentToken == _firestoreToken
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  if (_currentToken != _firestoreToken) ...[
                    SizedBox(height: 8),
                    Text(
                      'The token in Firestore is outdated',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24),

            // Save Button
            if (_currentToken != _firestoreToken)
              ElevatedButton.icon(
                onPressed: _saveTokenToFirestore,
                icon: Icon(Icons.save),
                label: Text('Save Current Token to Firestore'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),

            SizedBox(height: 16),

            // Refresh Button
            OutlinedButton.icon(
              onPressed: _loadTokens,
              icon: Icon(Icons.refresh),
              label: Text('Refresh Tokens'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    VoidCallback? onCopy,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onCopy != null)
                  IconButton(
                    onPressed: onCopy,
                    icon: Icon(Icons.copy, size: 18),
                    color: color,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}