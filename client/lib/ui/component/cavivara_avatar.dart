import 'package:flutter/material.dart';

class CavivaraAvatar extends StatelessWidget {
  const CavivaraAvatar({
    super.key,
    this.size = 40,
    this.onTap,
    this.assetPath = _defaultAssetPath,
    this.backgroundColor,
    this.cavivaraId,
    this.semanticsLabel,
  });

  final double size;
  final VoidCallback? onTap;
  final String assetPath;
  final Color? backgroundColor;
  final String? cavivaraId;
  final String? semanticsLabel;

  static const String _defaultAssetPath = 'assets/image/cavivara.png';

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final heroTag = cavivaraId != null
        ? 'cavivara_avatar_$cavivaraId'
        : 'cavivara_avatar_default';
    final label = semanticsLabel ?? 'カヴィヴァラさんのアイコン';

    Widget buildImage() {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: backgroundColor,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    Widget buildContent() {
      if (onTap == null) {
        return Semantics(
          label: label,
          image: true,
          child: buildImage(),
        );
      }

      return Semantics(
        label: label,
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
                decoration: BoxDecoration(
                  color: backgroundColor,
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

    return Hero(
      tag: heroTag,
      child: buildContent(),
    );
  }
}
