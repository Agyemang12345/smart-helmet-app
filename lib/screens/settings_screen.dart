import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/supervisor_profile.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'privacy_security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<SupervisorProfile?> _profileFuture;
  late TextEditingController _displayNameController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  bool _isEditing = false;

  // Alert thresholds
  double _gasThreshold = 100.0;
  double _alcoholThreshold = 0.05;
  double _tempThreshold = 30.0;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _phoneController = TextEditingController();
    _departmentController = TextEditingController();
    _profileFuture = _fetchProfile();
    _loadAlertThresholds();
  }

  Future<SupervisorProfile?> _fetchProfile() async {
    try {
      final user = FirebaseService.instance.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Try to get profile from database
      final profile = await FirebaseService.instance.getUserProfile();

      // If profile exists, return it
      if (profile != null) {
        return profile;
      }

      // Otherwise, create a profile from Firebase Auth user
      final newProfile = SupervisorProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Supervisor',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLogin: user.metadata.lastSignInTime,
      );

      return newProfile;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> _loadAlertThresholds() async {
    // Load from shared preferences or Firebase
    // For now, using default values
  }

  Future<void> _saveAlertThresholds() async {
    // Save to shared preferences or Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert thresholds saved')),
    );
  }

  Future<void> _updateProfile() async {
    try {
      await FirebaseService.instance.updateUserProfile(
        displayName: _displayNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        department: _departmentController.text.trim(),
      );
      setState(() {
        _profileFuture = _fetchProfile();
        _isEditing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseService.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Future<void> _changePassword() async {
    showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(
        onConfirm: (oldPassword, newPassword) async {
          try {
            await FirebaseService.instance.changePassword(
              oldPassword,
              newPassword,
            );
            if (!mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password changed successfully')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password change failed: $e')),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF142D4C),
        title: const Text('Settings & Profile'),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<SupervisorProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF56CCF2)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Please log in first',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6DE4),
                    ),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(
                      () => _profileFuture = _fetchProfile(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6DE4),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = snapshot.data!;
          if (_isEditing) {
            _displayNameController.text = profile.displayName ?? '';
            _phoneController.text = profile.phoneNumber ?? '';
            _departmentController.text = profile.department ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF142D4C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.07)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E6DE4),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.displayName ?? 'Supervisor',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.email,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (profile.department != null)
                        Text(
                          'Department: ${profile.department}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Details Section
                const Text(
                  'Profile Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProfileField(
                    'Full Name', profile.displayName ?? 'Not set'),
                _buildProfileField('Email', profile.email),
                _buildProfileField(
                  'Phone Number',
                  profile.phoneNumber ?? 'Not set',
                ),
                _buildProfileField(
                    'Department', profile.department ?? 'Not set'),
                const SizedBox(height: 12),
                Text(
                  'Member since ${_formatDate(profile.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Profile Button
                if (!_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6DE4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      _buildEditField(
                        'Full Name',
                        _displayNameController,
                        Icons.person,
                      ),
                      const SizedBox(height: 12),
                      _buildEditField(
                        'Phone Number',
                        _phoneController,
                        Icons.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildEditField(
                        'Department',
                        _departmentController,
                        Icons.business,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  setState(() => _isEditing = false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E6DE4),
                              ),
                              child: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // Alert Thresholds Section
                const Text(
                  'Alert Thresholds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildThresholdSlider(
                  title: 'Gas Level Alert',
                  subtitle: 'Trigger alert when gas exceeds this level',
                  value: _gasThreshold,
                  min: 50,
                  max: 500,
                  unit: 'PPM',
                  onChanged: (value) => setState(() => _gasThreshold = value),
                ),
                _buildThresholdSlider(
                  title: 'Alcohol Level Alert',
                  subtitle: 'Trigger alert when alcohol exceeds this level',
                  value: _alcoholThreshold,
                  min: 0.01,
                  max: 0.5,
                  unit: '%BAC',
                  divisions: 49,
                  onChanged: (value) =>
                      setState(() => _alcoholThreshold = value),
                ),
                _buildThresholdSlider(
                  title: 'Temperature Alert',
                  subtitle: 'Trigger alert when temperature exceeds this level',
                  value: _tempThreshold,
                  min: 20,
                  max: 50,
                  unit: '°C',
                  onChanged: (value) => setState(() => _tempThreshold = value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAlertThresholds,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6DE4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save Alert Settings'),
                  ),
                ),
                const SizedBox(height: 24),

                // Account Management Section
                const Text(
                  'Account Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingOption(
                  icon: Icons.lock,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: _changePassword,
                ),
                _buildSettingOption(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage alert notifications',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingOption(
                  icon: Icons.privacy_tip,
                  title: 'Privacy & Security',
                  subtitle: 'View privacy settings',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacySecurityScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF1E6DE4)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildThresholdSlider({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required String unit,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${value.toStringAsFixed(value < 1 ? 2 : 0)} $unit',
                style: const TextStyle(
                  color: Color(0xFF1E6DE4),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions ?? (max - min).toInt(),
                  activeColor: const Color(0xFF1E6DE4),
                  inactiveColor: Colors.grey[600],
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E6DE4)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final Function(String, String) onConfirm;

  const _ChangePasswordDialog({required this.onConfirm});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF142D4C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user,
              color: Color(0xFF1E6DE4),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_newPasswordController.text !=
                          _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passwords do not match'),
                          ),
                        );
                        return;
                      }
                      widget.onConfirm(
                        _oldPasswordController.text,
                        _newPasswordController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6DE4),
                    ),
                    child: const Text('Change'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
