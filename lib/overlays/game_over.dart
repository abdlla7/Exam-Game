import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study/main_game_screen.dart';

class GameOverScreen extends StatelessWidget {
  final bool didWin;

  const GameOverScreen({super.key, required this.didWin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121714),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                didWin
                    ? 'assets/images/win.png'
                    : 'assets/images/lose.png',
                width: 300,
                height: 300,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error,
                  size: 100,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                didWin ? '🎉 لقد فزت' : '💀 انتهت اللعبة',
                style: GoogleFonts.tajawal(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: didWin ? const Color(0xFF38E07A) : Colors.red,
                  minimumSize: const Size(126, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainGameScreen()),
                  );
                },
                child: Text(
                  'إعادة اللعب',
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
