import 'package:flutter/material.dart';

class ConnectionStatusWidget extends StatefulWidget {
  final bool isConnected;

  const ConnectionStatusWidget({super.key, required this.isConnected});

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (!widget.isConnected) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectionStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isConnected != oldWidget.isConnected) {
      if (widget.isConnected) {
        _animationController.stop();
        _animationController.reset();
      } else {
        _animationController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isConnected ? 1.0 : _pulseAnimation.value,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color:
                  widget.isConnected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isConnected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error)
                      .withValues(alpha: 0.3),
                  blurRadius: widget.isConnected ? 4 : 8,
                  spreadRadius: widget.isConnected ? 0 : 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
