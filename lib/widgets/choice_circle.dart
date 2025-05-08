import 'package:flutter/material.dart';

class ChoiceCircle extends StatelessWidget {
  final String choice;
  final Animation<double> animation;

  const ChoiceCircle({
    super.key,
    required this.choice,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (animation.value * 0.5),
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.2),
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                choice,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
} 