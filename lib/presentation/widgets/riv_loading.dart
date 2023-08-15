import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoadingOverlay extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  const LoadingOverlay({Key? key, required this.child, required this.isLoading})
      : super(key: key);

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();

  static _LoadingOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<_LoadingOverlayState>()!;
  }
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: const Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          ),
        if (widget.isLoading)
          const Center(
            child: SizedBox(
              height: 100,
              child: RiveAnimation.asset(
                'assets/loading.riv',
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}
