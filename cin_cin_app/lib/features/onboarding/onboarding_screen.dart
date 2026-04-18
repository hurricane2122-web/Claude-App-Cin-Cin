import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      emoji: '🥂',
      title: 'Cin Cin Virtuale',
      subtitle: 'Avvicina il telefono a un amico\ne celebrate insieme!',
    ),
    _OnboardPage(
      emoji: '📡',
      title: 'Tecnologia BLE',
      subtitle: 'Usa il Bluetooth per rilevare\ni dispositivi nelle vicinanze',
    ),
    _OnboardPage(
      emoji: '🔒',
      title: 'Privacy Prima di Tutto',
      subtitle: 'Nessun server, nessun dato salvato.\nTutto locale sul tuo telefono.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _page == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _page == i
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFD4AF37).withOpacity(0.2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _buildPage(_pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: GestureDetector(
                onTap: _page == _pages.length - 1 ? _finishOnboarding : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: _page == _pages.length - 1
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFD4AF37).withOpacity(0.15),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                  ),
                  child: Text(
                    _page == _pages.length - 1 ? 'INIZIA A BRINDAR!' : 'SCORRI →',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _page == _pages.length - 1
                          ? const Color(0xFF0A0A0F)
                          : const Color(0xFFD4AF37),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardPage page) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(page.emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD4AF37),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.5),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
}

class _OnboardPage {
  final String emoji, title, subtitle;
  _OnboardPage({required this.emoji, required this.title, required this.subtitle});
}
