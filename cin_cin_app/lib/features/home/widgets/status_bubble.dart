import 'package:flutter/material.dart';
import '../../../core/services/proximity_service.dart';

class StatusBubble extends StatelessWidget {
  final ProximityState state;
  final int nearbyCount;
  final double closestDistance;

  const StatusBubble({
    super.key,
    required this.state,
    required this.nearbyCount,
    required this.closestDistance,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(state),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _getBgColor(),
          border: Border.all(color: _getBorderColor(), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getDotColor(),
                boxShadow: [
                  BoxShadow(color: _getDotColor().withOpacity(0.6), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 12,
                color: _getTextColor(),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (state) {
      case ProximityState.idle:
        return 'IN ATTESA · PREMI INIZIA';
      case ProximityState.scanning:
        return nearbyCount > 0
            ? '$nearbyCount DISPOSITIVO${nearbyCount > 1 ? "I" : ""} VICINO'
            : 'SCANSIONE IN CORSO...';
      case ProximityState.near:
        return 'AVVICINATI DI PIU!';
      case ProximityState.toasting:
        return '🥂  CIN CIN!';
    }
  }

  Color _getDotColor() {
    switch (state) {
      case ProximityState.idle:
        return Colors.white.withOpacity(0.3);
      case ProximityState.scanning:
        return nearbyCount > 0 ? const Color(0xFFFFBF00) : const Color(0xFF4CAF50);
      case ProximityState.near:
        return const Color(0xFFFFBF00);
      case ProximityState.toasting:
        return const Color(0xFFD4AF37);
    }
  }

  Color _getTextColor() {
    if (state == ProximityState.toasting) return const Color(0xFFD4AF37);
    if (nearbyCount > 0) return const Color(0xFFFFBF00);
    return Colors.white.withOpacity(0.6);
  }

  Color _getBgColor() => Colors.white.withOpacity(0.04);
  Color _getBorderColor() => Colors.white.withOpacity(0.08);
}
