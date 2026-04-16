import 'package:flutter/material.dart';

class AnimatedSplash extends StatefulWidget {
  const AnimatedSplash({super.key});

  static const Color backgroundColor = Color(0xFF849BFF);

  @override
  State<AnimatedSplash> createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _entryScale;
  late final Animation<double> _entryOpacity;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entryScale = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    );
    _entryOpacity = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnimatedSplash.backgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_entryController, _pulseController]),
          builder: (context, child) {
            final entry = _entryScale.value;
            final pulse = _pulseScale.value;
            return Opacity(
              opacity: _entryOpacity.value,
              child: Transform.scale(
                scale: entry * pulse,
                child: child,
              ),
            );
          },
          child: Image.asset(
            'assets/logo/splash.png',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
