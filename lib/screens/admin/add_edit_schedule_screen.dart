import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/schedule_model.dart';
import '../../services/hive_service.dart';
import '../../widgets/custom_textfield.dart';

class AddEditScheduleScreen extends StatefulWidget {
  final ScheduleModel? existingSchedule;

  const AddEditScheduleScreen({super.key, this.existingSchedule});

  @override
  State<AddEditScheduleScreen> createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends State<AddEditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _classNameController;
  late final TextEditingController _trainerController;
  late final TextEditingController _timeController;
  late final TextEditingController _quotaController;
  String _day = 'Senin';

  final List<String> _days = const [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  bool get _isEditing => widget.existingSchedule != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existingSchedule;
    _classNameController = TextEditingController(text: s?.className ?? '');
    _trainerController = TextEditingController(text: s?.trainer ?? '');
    _timeController = TextEditingController(text: s?.time ?? '');
    _quotaController = TextEditingController(text: s?.quota.toString() ?? '');
    _day = s?.day ?? 'Senin';
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _trainerController.dispose();
    _timeController.dispose();
    _quotaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final box = Hive.box<ScheduleModel>(HiveService.scheduleBox);

    if (_isEditing) {
      final s = widget.existingSchedule!;
      s.className = _classNameController.text.trim();
      s.trainer = _trainerController.text.trim();
      s.day = _day;
      s.time = _timeController.text.trim();
      s.quota = int.parse(_quotaController.text);
      await s.save();
    } else {
      final newSchedule = ScheduleModel(
        id: const Uuid().v4(),
        className: _classNameController.text.trim(),
        trainer: _trainerController.text.trim(),
        day: _day,
        time: _timeController.text.trim(),
        quota: int.parse(_quotaController.text),
      );
      await box.put(newSchedule.id, newSchedule);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Jadwal' : 'Tambah Jadwal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _classNameController,
                label: 'Nama Kelas',
                icon: Icons.fitness_center,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _trainerController,
                label: 'Nama Pelatih',
                icon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _day,
                decoration: const InputDecoration(
                    labelText: 'Hari',
                    prefixIcon: Icon(Icons.calendar_today_outlined)),
                items: _days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _day = v ?? 'Senin'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _timeController,
                label: 'Jam (mis. 07:00 - 08:00)',
                icon: Icons.schedule,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _quotaController,
                label: 'Kuota Peserta',
                icon: Icons.people_outline,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || int.tryParse(v) == null)
                    ? 'Masukkan angka'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: _save,
                  child: Text(_isEditing ? 'Update' : 'Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
