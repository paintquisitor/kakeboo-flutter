import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Uses the same Heroicons 24/outline paths as the Android Compose app.
class HeroIcon extends StatelessWidget {
  const HeroIcon(this.name, {super.key, this.size = 24, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/icons/heroicons/ic_hero_$name.svg',
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(
      color ??
          IconTheme.of(context).color ??
          Theme.of(context).colorScheme.onSurface,
      BlendMode.srcIn,
    ),
  );
}
