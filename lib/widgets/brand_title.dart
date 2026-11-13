import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Small Foshol-AI logo used in app bars.
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}
