import 'package:blooddonation/screens/chat/ChatScreenList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../theme/AppTheme_data.dart';
import '../auth/login.dart';
import '../donor/Donor_Donation_History.dart';
import '../donor/donor_search_screen.dart';
import '../receiver/PostRequestScreen.dart';
import '../receiver/blood_Request_Screen.dart';
import '../receiver/myRequestScreen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final _authService = AuthService();
  final _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).userData;
    final isDonor = userData?['userType'] == 'donor';
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primaryRed,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome,',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        userData?['name'] ?? 'User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bloodtype, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              userData?['bloodType'] ?? 'N/A',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notifications coming soon!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 8),
            ],
          ),

          // Content
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status Card
                _buildStatusCard(userData, isDonor),
                SizedBox(height: 24),

                // Quick Actions Title
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 16),

                // Action Cards
                if (isDonor)
                  Column(
                    children: [
                      _buildActionCard(
                        context,
                        title: 'Find Blood Requests',
                        subtitle: 'Help someone in need',
                        icon: Icons.search_rounded,
                        color: Color(0xFF6C63FF),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BloodRequestsScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildActionCard(
                        context,
                        title: 'Donation History',
                        subtitle: 'View your donations',
                        icon: Icons.history_rounded,
                        color: Color(0xFF00BFA5),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DonationHistoryScreen(),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildActionCard(
                        context,
                        title: 'Find Donors',
                        subtitle: 'Connect with donors',
                        icon: Icons.group_rounded,
                        color: Color(0xFFFF6B6B),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DonorSearchScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildActionCard(
                        context,
                        title: 'Post Blood Request',
                        subtitle: 'Create a new request',
                        icon: Icons.add_circle_rounded,
                        color: Color(0xFFFFB627),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostRequestScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildActionCard(
                        context,
                        title: 'My Requests',
                        subtitle: 'Manage your requests',
                        icon: Icons.list_alt_rounded,
                        color: Color(0xFF8E44AD),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyRequestsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 24),

                // Info Section
                _buildInfoSection(userData),
                SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, userData, isDonor),
      // FLOATING CHAT BUTTON WITH BADGE
      floatingActionButton: currentUserId != null
          ? StreamBuilder<QuerySnapshot>(
        stream: _chatService.getUserChats(currentUserId),
        builder: (context, snapshot) {
          // Calculate total unread messages
          int totalUnread = 0;
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              // This is a simplified approach - you might want to optimize this
            }
          }

          return Stack(
            children: [
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatsListScreen(),
                    ),
                  );
                },
                backgroundColor: AppTheme.primaryRed,
                elevation: 6,
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              // Unread badge
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        snapshot.data!.docs.length > 9
                            ? '9+'
                            : snapshot.data!.docs.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      )
          : null,
    );
  }

  Widget _buildStatusCard(Map<String, dynamic>? userData, bool isDonor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFD32F2F).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDonor ? Icons.volunteer_activism : Icons.help_outline,
              color: Colors.white,
              size: 36,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDonor ? 'You are a Donor' : 'You are a Receiver',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isDonor
                      ? 'Help save lives by donating'
                      : 'Request blood when needed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppTheme.cardShadow],
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textHint,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic>? userData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.cardShadow],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow('Email', userData?['email'] ?? 'N/A'),
          _buildInfoRow('Phone', userData?['phone'] ?? 'N/A'),
          _buildInfoRow('City', userData?['city'] ?? 'N/A'),
          _buildInfoRow('Age', userData?['age']?.toString() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(
      BuildContext context,
      Map<String, dynamic>? userData,
      bool isDonor,
      ) {
    return Drawer(
      child: Container(
        color: AppTheme.lightBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            Container(
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      userData?['name']?[0]?.toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 36,
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userData?['name'] ?? 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    userData?['bloodType'] ?? 'N/A',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),

            // Profile Tile
            ListTile(
              leading: Icon(Icons.person_outline, color: AppTheme.primaryRed),
              title: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                );
              },
            ),

            // Messages Tile
            ListTile(
              leading: Icon(Icons.chat_bubble_outline, color: AppTheme.primaryRed),
              title: Text(
                'Messages',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatsListScreen()),
                );
              },
            ),

            // About Tile
            ListTile(
              leading: Icon(Icons.info_outline, color: AppTheme.textLight),
              title: Text(
                'About',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // Divider with proper spacing
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                indent: 16,
                endIndent: 16,
                thickness: 1,
                color: Colors.grey[300],
              ),
            ),

            // Logout Tile
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _authService.signOut();
                          Provider.of<UserProvider>(context, listen: false)
                              .clearUser();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                                (route) => false,
                          );
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}