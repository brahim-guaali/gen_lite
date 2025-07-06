import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:genlite/core/constants/app_constants.dart';
import 'package:genlite/shared/widgets/ui_components.dart';
import 'package:genlite/shared/utils/logger.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  Map<Permission, PermissionStatus> _permissionStatuses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh permissions when app becomes active (user returns from settings)
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final permissions = [
        Permission.microphone,
        Permission.storage,
        Permission.camera,
      ];

      final statuses = <Permission, PermissionStatus>{};
      for (final permission in permissions) {
        try {
          statuses[permission] = await permission.status;
        } catch (e) {
          Logger.warning(LogTags.permissions,
              'Could not check status for permission: ${permission.toString()} - $e');
          statuses[permission] = PermissionStatus.denied;
        }
      }

      if (mounted) {
        setState(() {
          _permissionStatuses = statuses;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error(LogTags.permissions, 'Error checking permissions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      if (mounted) {
        setState(() {
          _permissionStatuses[permission] = status;
        });
      }

      if (status.isGranted) {
        _showSnackBar('Permission granted successfully', isError: false);
      } else if (status.isDenied) {
        _showSnackBar('Permission denied', isError: true);
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog(permission);
      }
    } catch (e) {
      Logger.error(LogTags.permissions, 'Error requesting permission: $e');
      _showSnackBar('Error requesting permission', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? AppConstants.errorColor : AppConstants.primaryColor,
        ),
      );
    }
  }

  void _showSettingsDialog(Permission permission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.settings,
                color: AppConstants.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text('${_getPermissionTitle(permission)} Permission'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This permission has been permanently denied. '
                'To use this feature, you need to enable it in your device settings.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How to enable:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '1. Tap "Open Settings"\n'
                        '2. Find "GenLite" in the list\n'
                        '3. Enable the permission\n'
                        '4. Return to the app',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getPermissionTitle(Permission permission) {
    switch (permission) {
      case Permission.microphone:
        return 'Microphone';
      case Permission.storage:
        return 'File Access';
      case Permission.camera:
        return 'Camera';
      default:
        return 'Unknown Permission';
    }
  }

  String _getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.microphone:
        return 'Required for voice input and speech recognition';
      case Permission.storage:
        return 'Required for accessing and processing files';
      case Permission.camera:
        return 'Required for image input and analysis';
      default:
        return 'Unknown permission purpose';
    }
  }

  IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.microphone:
        return Icons.mic;
      case Permission.storage:
        return Icons.folder;
      case Permission.camera:
        return Icons.camera_alt;
      default:
        return Icons.security;
    }
  }

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
        return Colors.red;
      case PermissionStatus.limited:
        return Colors.yellow;
      case PermissionStatus.provisional:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.provisional:
        return 'Provisional';
      default:
        return 'Unknown';
    }
  }

  Widget _buildPermissionTile(Permission permission) {
    final status = _permissionStatuses[permission] ?? PermissionStatus.denied;
    final isGranted = status.isGranted;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          _getPermissionIcon(permission),
          color: AppConstants.primaryColor,
          size: 28,
        ),
        title: Text(
          _getPermissionTitle(permission),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getPermissionDescription(permission),
              style: TextStyle(
                color: AppConstants.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(status),
                  width: 1,
                ),
              ),
              child: Text(
                _getStatusText(status),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: isGranted
            ? const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              )
            : status.isPermanentlyDenied
                ? ElevatedButton(
                    onPressed: () => _showSettingsDialog(permission),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Settings'),
                  )
                : ElevatedButton(
                    onPressed: () => _requestPermission(permission),
                    child: const Text('Grant'),
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPermissions,
            tooltip: 'Refresh permissions',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'App Permissions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage permissions for GenLite features',
                    style: TextStyle(
                      color: AppConstants.secondaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Permissions list
                  ..._permissionStatuses.keys.map(_buildPermissionTile),

                  const SizedBox(height: 24),

                  // Info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppConstants.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'About Permissions',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'GenLite processes all data locally on your device. '
                            'These permissions are only used to access device features '
                            'and no data is sent to external servers.',
                            style: TextStyle(
                              color: AppConstants.secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
