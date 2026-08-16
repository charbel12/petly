import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class ListingImageSource {
  static const assetPrefix = 'asset:';

  static bool isAsset(String? url) =>
      url != null && url.startsWith(assetPrefix);

  static String? assetPath(String? url) {
    if (!isAsset(url)) return null;
    return 'assets/${url!.substring(assetPrefix.length)}';
  }

  static bool isNetwork(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }
}

class ListingImage extends StatelessWidget {
  const ListingImage({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.pets_rounded,
  });

  final String? imageUrl;
  final String? heroTag;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    Widget image = _buildImage(context);
    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }
    return image;
  }

  Widget _buildImage(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final asset = ListingImageSource.assetPath(imageUrl);
    Widget child;
    if (asset != null) {
      child = Image.asset(
        asset,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            ListingImagePlaceholder(
          height: height,
          width: width,
          icon: placeholderIcon,
        ),
      );
    } else if (ListingImageSource.isNetwork(imageUrl)) {
      child = Image.network(
        imageUrl!,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            ListingImagePlaceholder(
          height: height,
          width: width,
          icon: placeholderIcon,
        ),
      );
    } else {
      child = ListingImagePlaceholder(
        height: height,
        width: width,
        icon: placeholderIcon,
      );
    }

    if (radius == BorderRadius.zero) return child;
    return ClipRRect(borderRadius: radius, child: child);
  }
}

class ListingImagePlaceholder extends StatelessWidget {
  const ListingImagePlaceholder({
    super.key,
    this.height,
    this.width,
    this.icon = Icons.pets_rounded,
  });

  final double? height;
  final double? width;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.brandAccent.withValues(alpha: 0.35),
            tokens.brandPrimary.withValues(alpha: 0.18),
          ],
        ),
      ),
      child: Icon(
        icon,
        size: 40,
        color: tokens.brandPrimary.withValues(alpha: 0.7),
      ),
    );
  }
}
