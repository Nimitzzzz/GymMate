import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/member_model.dart';
import '../../services/hive_service.dart';
import '../../widgets/custom_textfield.dart';

class AddEditMemberScreen extends StatefulWidget {
  final MemberModel? existingMember;
  const AddEditMemberScreen({super.key, this.existingMember});

  @override
  State<AddEditMemberScreen> createState() => _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends State<AddEditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String _membershipType = 'Basic';
  late DateTime _joinDate;
  late DateTime _expiryDate;

  bool get _isEditing => widget.existingMember != null;
  final List<String> _types = const ['Basic', 'Premium', 'VIP'];

  @override
  void initState() {
    super.initState();
    final m = widget.existingMember;
    _nameController = TextEditingController(text: m?.name ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _membershipType = m?.membershipType ?? 'Basic';
    _joinDate = m?.joinDate ?? DateTime.now();
    _expiryDate = m?.expiryDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isJoinDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isJoinDate ? _joinDate : _expiryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => isJoinDate ? _joinDate = picked : _expiryDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<MemberModel>(HiveService.memberBox);

    if (_isEditing) {
      final m = widget.existingMember!;
      m.name = _nameController.text.trim();
      m.phone = _phoneController.text.trim();
      m.membershipType = _membershipType;
      m.joinDate = _joinDate;
      m.expiryDate = _expiryDate;
      await m.save();
    } else {
      final newMember = MemberModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        membershipType: _membershipType,
        joinDate: _joinDate,
        expiryDate: _expiryDate,
      );
      await box.put(newMember.id, newMember);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await widget.existingMember?.delete();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Member' : 'Tambah Member'),
        actions: [
          if (_isEditing)
            IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nama Member',
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Nomor HP',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _membershipType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Membership',
                  prefixIcon: Icon(Icons.card_membership_outlined),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _membershipType = v ?? 'Basic'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Tanggal Gabung: ${_joinDate.day}/${_joinDate.month}/${_joinDate.year}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(isJoinDate: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Berlaku Sampai: ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(isJoinDate: false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Update' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
