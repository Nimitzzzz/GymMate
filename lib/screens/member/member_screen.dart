import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/member_model.dart';
import '../../services/hive_service.dart';
import '../../utils/app_theme.dart';
import 'add_edit_member_screen.dart';

class MemberScreen extends StatelessWidget {
  const MemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<MemberModel>(HiveService.memberBox);

    return Scaffold(
      appBar: AppBar(title: const Text('Data Member')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditMemberScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<MemberModel> b, _) {
          final members = b.values.toList()
            ..sort((a, c) => a.name.compareTo(c.name));

          if (members.isEmpty) {
            return Center(
              child: Text('Belum ada data member.',
                  style: TextStyle(color: Colors.grey.shade600)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final m = members[index];
              return Dismissible(
                key: Key(m.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => m.delete(),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          m.isActive ? AppColors.success.withOpacity(0.15) : AppColors.danger.withOpacity(0.15),
                      child: Icon(Icons.person,
                          color: m.isActive ? AppColors.success : AppColors.danger),
                    ),
                    title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${m.membershipType} • ${m.phone}\n'
                      'Berlaku s/d ${m.expiryDate.day}/${m.expiryDate.month}/${m.expiryDate.year} '
                      '(${m.isActive ? "Aktif" : "Kadaluarsa"})',
                    ),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditMemberScreen(existingMember: m),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
