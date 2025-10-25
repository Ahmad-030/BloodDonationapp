// ============================================================================
// FILE: lib/screens/home/home_screen.dart
// Home dashboard - different for donors and receivers
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/menu_card.dart';
import '../auth/login.dart';
import '../donor/Donor_Donation_History.dart';
import '../donor/donor_search_screen.dart';
import '../receiver/PostRequestScreen.dart';
import '../receiver/blood_Request_Screen.dart';
import '../receiver/myRequestScreen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).userData;
    final isDonor = userData?['userType'] == 'donor';

    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Donation'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, userData),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, ${userData?['name'] ?? 'User'}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              isDonor ? 'Donor Dashboard' : 'Receiver Dashboard',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32),
            if (isDonor) ..._buildDonorMenu(context) else ..._buildReceiverMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, Map<String, dynamic>? userData) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    userData?['name']?[0]?.toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 32,
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  userData?['name'] ?? 'User',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  userData?['bloodType'] ?? '',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _authService.signOut();
              Provider.of<UserProvider>(context, listen: false).clearUser();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDonorMenu(BuildContext context) {
    return [
      MenuCard(
        title: 'Search Blood Requests',
        icon: Icons.search,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BloodRequestsScreen()),
        ),
      ),
      SizedBox(height: 16),
      MenuCard(
        title: 'My Donation History',
        icon: Icons.history,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DonationHistoryScreen()),
        ),
      ),
    ];
  }

  List<Widget> _buildReceiverMenu(BuildContext context) {
    return [
      MenuCard(
        title: 'Find Donors',
        icon: Icons.people,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DonorSearchScreen()),
        ),
      ),
      SizedBox(height: 16),
      MenuCard(
        title: 'Post Blood Request',
        icon: Icons.add_circle,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostRequestScreen()),
        ),
      ),
      SizedBox(height: 16),
      MenuCard(
        title: 'My Requests',
        icon: Icons.list_alt,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MyRequestsScreen()),
        ),
      ),
    ];
  }
}