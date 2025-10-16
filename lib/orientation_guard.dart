import 'package:flutter/material.dart';

import 'utils/app_colors.dart';

class OrientationGuard extends StatefulWidget {
  final Widget child;
  const OrientationGuard({Key? key, required this.child}) : super(key: key);

  @override
  State<OrientationGuard> createState() => _OrientationGuardState();
}

class _OrientationGuardState extends State<OrientationGuard>
    with WidgetsBindingObserver {
  Orientation? _lastOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastOrientation = MediaQuery.of(context).orientation;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final orientation = MediaQuery.of(context).orientation;
    if (_lastOrientation != null && orientation != _lastOrientation) {
      // User mencoba rotate
      print("Orientation changed: $_lastOrientation -> $orientation");
      if (!mounted) return;
      setState(() {
        showCustomSnackbar(context, "Rotasi layar dinonaktifkan");
      });
    }
    _lastOrientation = orientation;
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void showCustomSnackbar(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger == null) return;
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: message.length <= 30 ? 14 : 12,
          ),
        ),
        duration: const Duration(seconds: 8),
        backgroundColor: isSuccess ? AppColors.accent : AppColors.black1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppColors.brown1,
          onPressed: () {
            scaffoldMessenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
