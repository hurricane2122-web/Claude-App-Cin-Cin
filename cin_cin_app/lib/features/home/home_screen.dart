import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/proximity_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/haptics_service.dart';
import 'widgets/radar_animation.dart';
import 'widgets/status_bubble.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _toastController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _toastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _initProximity());
  }

  void _initProximity() {
    final proximity = context.read<ProximityService>();
    final audio = context.read<AudioService>();
    final haptics = context.read<HapticsService>();

    proximity.onToast = () async {
      await audio.playCinCin();
      await haptics.playToastHaptic();
      _toastController.forward(from: 0);
    };

    proximity.startScanning();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _toastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Consumer<ProximityService>(
        builder: (context, proximity, _) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      const Color(0xFF1A1508).withOpacity(
                        proximity.state == ProximityState.toasting ? 0.8 : 0.3,
                      ),
                      const Color(0xFF0A0A0F),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildRadarSection(proximity)),
                    _buildStatusSection(proximity),
                    _buildControlButton(proximity),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              if (proximity.state == ProximityState.toasting)
                _buildToastOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CIN CIN',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              Text(
                'Virtual Toast',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFFFFFFFF).withOpacity(0.4),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.wine_bar_outlined,
              color: Color(0xFFD4AF37),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarSection(ProximityService proximity) {
    return Center(
      child: RadarAnimation(
        pulseController: _pulseController,
        toastController: _toastController,
        state: proximity.state,
        nearbyCount: proximity.nearbyCount,
        closestDistance: proximity.closestDistance,
      ),
    );
  }

  Widget _buildStatusSection(ProximityService proximity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: StatusBubble(
        state: proximity.state,
        nearbyCount: proximity.nearbyCount,
        closestDistance: proximity.closestDistance,
      ),
    );
  }

  Widget _buildControlButton(ProximityService proximity) {
    final isScanning = proximity.state != ProximityState.idle;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (isScanning) {
              proximity.stopScanning();
            } else {
              proximity.startScanning();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isScanning
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1.5,
              ),
              color: isScanning
                  ? const Color(0xFFD4AF37).withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Text(
              isScanning ? 'ATTIVO · TOCCA PER FERMARE' : 'INIZIA',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isScanning
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFFD4AF37).withOpacity(0.6),
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => proximity.simulateToast(),
          child: Text(
            'Test Cin Cin',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.2),
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToastOverlay() {
    return AnimatedBuilder(
      animation: _toastController,
      builder: (context, _) {
        return IgnorePointer(
          child: Container(
            color: const Color(0xFFD4AF37).withOpacity(
              0.15 * (1 - _toastController.value),
            ),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.2),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, _) => Transform.scale(
                  scale: scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🥂',
                        style: TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'CIN CIN!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD4AF37),
                          letterSpacing: 6,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
