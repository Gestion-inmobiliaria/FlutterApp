import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inmobiliaria_app/core/configs/assets/app_vectors.dart';

class LogoIntro extends StatelessWidget {
  const LogoIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(child: SvgPicture.asset(AppVectors.logo, width: 300)),
    );
  }
}
