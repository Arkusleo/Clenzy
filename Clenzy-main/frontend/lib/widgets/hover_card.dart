import 'package:flutter/material.dart';

class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final double scaleFactor;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.decoration,
    this.scaleFactor = 1.02,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: widget.margin,
          padding: widget.padding,
          transform: Matrix4.diagonal3Values(
            _isHovered ? widget.scaleFactor : 1.0,
            _isHovered ? widget.scaleFactor : 1.0,
            1.0,
          ),
          transformAlignment: Alignment.center,
          decoration: widget.decoration?.copyWith(
            boxShadow: _isHovered && widget.decoration?.boxShadow != null
                ? widget.decoration!.boxShadow!
                      .map(
                        (s) => BoxShadow(
                          color: s.color.withAlpha(
                            (s.color.a * 255 * 1.5).clamp(0, 255).toInt(),
                          ),
                          blurRadius: s.blurRadius * 1.5,
                          offset: Offset(s.offset.dx, s.offset.dy * 1.5),
                        ),
                      )
                      .toList()
                : widget.decoration?.boxShadow,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
