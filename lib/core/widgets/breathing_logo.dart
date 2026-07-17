import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The FloodStore mark, rendered with a slow, subtle "breathing" scale and
/// a gentle vertical float — never a spin, never a bounce. The glow behind
/// it pulses in lockstep so the whole thing reads as one calm, living
/// object rather than a loading indicator.
class BreathingLogo extends StatefulWidget {
  const BreathingLogo({
    super.key,
    this.size = 120,
    this.assetPath = 'assets/logo/floodstore_logo.png',
    this.showGlow = true,
  });

  final double size;
  final String assetPath;
  final bool showGlow;

  @override
  State<BreathingLogo> createState() => _BreathingLogoState();
}

class _BreathingLogoState extends State<BreathingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween(begin: 0.97, end: 1.03).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  late final Animation<double> _float = Tween(begin: 0.0, end: -8.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  late final Animation<double> _glow = Tween(begin: 0.22, end: 0.42).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: Transform.scale(
            scale: _scale.value,
            child: SizedBox(
              width: widget.size * 1.9,
              height: widget.size * 1.9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.showGlow)
                    Container(
                      width: widget.size * 1.9,
                      height: widget.size * 1.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.glow(opacity: _glow.value),
                      ),
                    ),
                  Image.asset(
                    widget.assetPath,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.water_drop_rounded,
                      size: widget.size,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
