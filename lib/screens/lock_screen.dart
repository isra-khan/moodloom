import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/app_lock_service.dart';
import '../theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _enteredPin = '';
  bool _error = false;

  void _onDigit(String digit) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += digit;
      _error = false;
    });
    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _error = false;
    });
  }

  Future<void> _verifyPin() async {
    final valid = await AppLockService.verifyPin(_enteredPin);
    if (valid) {
      widget.onUnlocked();
    } else {
      setState(() {
        _enteredPin = '';
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.tealGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌿', style: TextStyle(fontSize: 56))
                    .animate()
                    .fadeIn()
                    .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
                const SizedBox(height: 16),
                const Text(
                  'MoodLoom',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 8),
                Text(
                  _error ? 'Incorrect PIN. Try again.' : 'Enter your PIN',
                  style: TextStyle(
                    fontSize: 15,
                    color: _error ? Colors.redAccent.shade100 : Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                // PIN dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _enteredPin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: filled ? 20 : 16,
                      height: filled ? 20 : 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? Colors.white : Colors.white24,
                        border: Border.all(color: Colors.white54, width: 2),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 48),
                // Keypad
                ...List.generate(3, (row) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (col) {
                        final digit = '${row * 3 + col + 1}';
                        return _PinKey(digit: digit, onTap: () => _onDigit(digit));
                      }),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 80),
                      _PinKey(digit: '0', onTap: () => _onDigit('0')),
                      GestureDetector(
                        onTap: _onDelete,
                        child: const SizedBox(
                          width: 80,
                          height: 64,
                          child: Center(
                            child: Icon(Icons.backspace_outlined, color: Colors.white70, size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  final String digit;
  final VoidCallback onTap;
  const _PinKey({required this.digit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
