import 'package:flutter/material.dart';
import 'package:study/main_game_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF121714),
      body: Column(
        children: [
          // ✅ الصورة تأخذ العرض الكامل وتلتصق بالأعلى
          Image.asset(
            'assets/images/HomeHead.png',
            width: double.infinity,
            height: screenHeight * 0.4,
            fit: BoxFit.cover,
          ),

          // ✅ باقي الصفحة يمكن أن تكون داخل ScrollView
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'العب و أدرس',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'عليك الإجابة على الأسئلة من أجل الحصول على الذخيرة و النجاة',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansArabic(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 180,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38E07A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MainGameScreen()),
                            );
                          },
                          child: Text(
                            'ابدأ الدراسة',
                            style: GoogleFonts.notoKufiArabic(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
