import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final bool interactive;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 15,
    this.opacity = 0.05,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.interactive = false,
    this.onTap,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  bool _isHovered = false;
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isTapped ? 0.98 : (_isHovered ? 1.02 : 1.0);
    final currentOpacity = widget.interactive && _isHovered
        ? widget.opacity + 0.05
        : widget.opacity;
    final borderColor = widget.interactive && _isHovered
        ? Colors.white.withOpacity(0.3)
        : Colors.white.withOpacity(0.1);

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      transform: Matrix4.identity()..scale(scale, scale),
      transformAlignment: Alignment.center,
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(currentOpacity),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              border: widget.border ??
                  Border.all(
                    color: borderColor,
                    width: 1.0,
                  ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.interactive || widget.onTap != null) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isTapped = true),
          onTapUp: (_) {
            setState(() => _isTapped = false);
            if (widget.onTap != null) widget.onTap!();
          },
          onTapCancel: () => setState(() => _isTapped = false),
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    return content;
  }
}
