import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ApplicationStepHeader extends StatelessWidget {
  final int step;
  const ApplicationStepHeader({super.key, required this.step});

  static const labels = [
    '1. Student', '2. Parent', '3. Academics', '4. Docs', '5. Sign',
  ];

  @override
  Widget build(BuildContext context) {
    final current = step.clamp(1, 5);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(labels.length, (index) {
              final selected = index + 1 == current;
              return Expanded(
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
                    color: selected ? AppTheme.blue : const Color(0xFF64748B),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: current / 5,
              minHeight: 5,
              backgroundColor: const Color(0xFFEDF1F7),
              color: AppTheme.blue,
            ),
          ),
        ],
      ),
    );
  }
}
