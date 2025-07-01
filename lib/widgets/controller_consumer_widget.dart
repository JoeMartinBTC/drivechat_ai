// lib/widgets/controller_consumer_widget.dart
import 'package:flutter/material.dart';

/// A widget that rebuilds when controllers change state
class ControllerConsumer extends StatefulWidget {
  const ControllerConsumer({super.key, required this.builder});

  final Widget Function(BuildContext context) builder;

  @override
  State<ControllerConsumer> createState() => _ControllerConsumerState();
}

class _ControllerConsumerState extends State<ControllerConsumer> {
  late BuildContext? _controllerProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newProvider = context;
    if (_controllerProvider != newProvider) {
      _controllerProvider?.controllers.apiConfigController.removeListener(
        _onStateChanged,
      );
      _controllerProvider?.controllers.audioController.removeListener(
        _onStateChanged,
      );

      _controllerProvider = newProvider;
      _controllerProvider?.controllers.apiConfigController.addListener(
        _onStateChanged,
      );
      _controllerProvider?.controllers.audioController.addListener(
        _onStateChanged,
      );
    }
  }

  @override
  void dispose() {
    _controllerProvider?.controllers.apiConfigController.removeListener(
      _onStateChanged,
    );
    _controllerProvider?.controllers.audioController.removeListener(
      _onStateChanged,
    );
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

/// Extension to easily access controllers from context
extension BuildContextControllerExtension on BuildContext {
  BuildContext get controllers {
    final provider = this;
    return provider;
  }

  dynamic get apiConfigController => null;
  dynamic get audioController => null;
}
