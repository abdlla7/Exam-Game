import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study/components/player.dart';
import 'package:flame_audio/flame_audio.dart';

class QuestionArea extends StatefulWidget {
  final Player? player;

  const QuestionArea({super.key, this.player});

  @override
  State<QuestionArea> createState() => _QuestionAreaState();
}

class _QuestionAreaState extends State<QuestionArea> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'ما هو أكبر كوكب في المجموعة الشمسية؟',
      'choices': ['الأرض', 'المريخ', 'زحل', 'المشتري'],
      'correct': 3,
    },
    {
      'question': 'من هو مكتشف قانون الجاذبية؟',
      'choices': ['نيوتن', 'أينشتاين', 'بويل', 'غاليلو'],
      'correct': 0,
    },
    {
      'question': 'ما عاصمة مصر؟',
      'choices': ['القاهرة', 'الجيزة', 'المنصورة', 'الإسكندرية'],
      'correct': 0,
    },
    {
      'question': 'كم عدد كواكب المجموعة الشمسية؟',
      'choices': ['7', '8', '9', '10'],
      'correct': 1,
    },
    {
      'question': 'ما العنصر الذي يرمز له بـ O؟',
      'choices': ['أكسجين', 'ذهب', 'نحاس', 'هيدروجين'],
      'correct': 0,
    },
    {
      'question': 'من هو مؤسس علم الجبر؟',
      'choices': ['ابن سينا', 'الخوارزمي', 'الرازي', 'ابن رشد'],
      'correct': 1,
    },
    {
      'question': 'ما اسم أول سورة في القرآن؟',
      'choices': ['البقرة', 'الناس', 'الفاتحة', 'الإخلاص'],
      'correct': 2,
    },
    {
      'question': 'كم عدد أركان الإسلام؟',
      'choices': ['4', '5', '6', '3'],
      'correct': 1,
    },
    {
      'question': 'ما هو الحيوان الثديي؟',
      'choices': ['التمساح', 'السلحفاة', 'الأسد', 'البطريق'],
      'correct': 2,
    },
    {
      'question': 'في أي سنة بدأت الحرب العالمية الثانية؟',
      'choices': ['1939', '1945', '1920', '1914'],
      'correct': 0,
    },
  ];

  int current = 0;
  int? selectedIndex;
  bool answered = false;

  void handleAnswer(int index) {
    final correctIndex = questions[current]['correct'];

    if (index == correctIndex) {
      widget.player?.ammo += 5;

      // ✅ تحديث شريط الذخيرة
      if (widget.player != null) {
        widget.player!.gameRef.ammoNotifier.value = widget.player!.ammo;
      }

      FlameAudio.play('correct.mp3', volume: 1.0);
    } else {
      FlameAudio.play('wrong.mp3', volume: 1.0);
    }

    setState(() {
      selectedIndex = index;
      answered = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (current < questions.length - 1) {
        setState(() {
          current++;
          selectedIndex = null;
          answered = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ تجنب الوصول لسؤال غير موجود
    if (current >= questions.length) {
      return Center(
        child: Text(
          'انتهت الأسئلة!',
          style: GoogleFonts.tajawal(color: Colors.white, fontSize: 20),
        ),
      );
    }

    final q = questions[current];

    return Container(
      color: const Color(0xFF121714),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            q['question'],
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(q['choices'].length, (index) {
            Color bgColor = const Color(0xFF29382E);
            if (answered) {
              if (index == q['correct']) {
                bgColor = const Color(0xFF38E07A);
              } else if (index == selectedIndex) {
                bgColor = Colors.red;
              }
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: answered ? null : () => handleAnswer(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  q['choices'][index],
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
