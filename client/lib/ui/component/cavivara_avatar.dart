import 'package:flutter/material.dart';

class CavivaraAvatar extends StatelessWidget {
  const CavivaraAvatar({super.key, this.size = 40, this.onTap});

  final double size;
  final VoidCallback? onTap;

  static const String assetPath = 'assets/image/cavivara.png';

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    Widget buildImage() {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    if (onTap == null) {
      return Semantics(
        label: 'カヴィヴァラさんのアイコン',
        image: true,
        child: buildImage(),
      );
    }

    return Semantics(
      label: 'カヴィヴァラさんのアイコン',
      button: true,
      image: true,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(assetPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
