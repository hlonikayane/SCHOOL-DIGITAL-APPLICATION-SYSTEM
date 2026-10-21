import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class ParentPortalHeader extends StatelessWidget {
  const ParentPortalHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'Parent Portal';
    final short = email.contains('@') ? email.split('@').first : email;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/images/lenyora-learners.jpg', width: 34, height: 34, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.school, color: AppTheme.blue, size: 30))),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Flexible(child: Text(short, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.navy))),
            const Text(' · Parent Portal', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))) ]),
          const Text('● Real-Time Sync (<2s)', style: TextStyle(fontSize: 9, color: Color(0xFF159A73), fontWeight: FontWeight.w700)),
        ])),
        _headIcon(Icons.auto_awesome, AppTheme.blue, bg: const Color(0xFFEEF4FF)),
        _headIcon(Icons.shield_outlined, const Color(0xFFB7791F)),
        _headIcon(Icons.volume_up_outlined, const Color(0xFF159A73)),
        Stack(clipBehavior: Clip.none, children: [const Icon(Icons.notifications_none, size: 21, color: AppTheme.navy), Positioned(right: -1, top: -1, child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)))]),
        const SizedBox(width: 10),
        const CircleAvatar(radius: 14, backgroundColor: Color(0xFFE5EDFF), child: Icon(Icons.person, size: 18, color: AppTheme.blue)),
      ]),
    );
  }
  Widget _headIcon(IconData icon, Color color, {Color? bg}) => Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: bg ?? Colors.transparent, borderRadius: BorderRadius.circular(9)), child: Icon(icon, size: 17, color: color));
}
