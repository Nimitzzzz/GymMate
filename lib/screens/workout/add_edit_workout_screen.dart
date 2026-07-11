import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/workout_model.dart';
import '../../services/auth_service.dart';
import '../../services/hive_service.dart';
import '../../widgets/custom_textfield.dart';

class AddEditWorkoutScreen extends StatefulWidget {
  final WorkoutModel? existingWorkout;
  const AddEditWorkoutScreen({super.key, this.existingWorkout});

  @override
  State<AddEditWorkoutScreen> createState() => _AddEditWorkoutScreenState();
}

class _AddEditWorkoutScreenState extends State<AddEditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;

  bool get _isEditing => widget.existingWorkout != null;

  @override
  void initState() {
    super.initState();
    final w = widget.existingWorkout;
    _nameController = TextEditingController(text: w?.exerciseName ?? '');
    _setsController = TextEditingController(text: w?.sets.toString() ?? '');
    _repsController = TextEditingController(text: w?.reps.toString() ?? '');
    _weightController = TextEditingController(text: w?.weight.toString() ?? '');
    _notesController = TextEditingController(text: w?.notes ?? '');
    _selectedDate = w?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userEmail = context.read<AuthService>().currentUser?.email ?? '';
    final box = Hive.box<WorkoutModel>(HiveService.workoutBox);

    if (_isEditing) {
      final w = widget.existingWorkout!;
      w.exerciseName = _nameController.text.trim();
      w.sets = int.parse(_setsController.text);
      w.reps = int.parse(_repsController.text);
      w.weight = double.parse(_weightController.text);
      w.date = _selectedDate;
      w.notes = _notesController.text.trim();
      await w.save();
    } else {
      final newWorkout = WorkoutModel(
        id: const Uuid().v4(),
        userEmail: userEmail,
        exerciseName: _nameController.text.trim(),
        sets: int.parse(_setsController.text),
        reps: int.parse(_repsController.text),
        weight: double.parse(_weightController.text),
        date: _selectedDate,
        notes: _notesController.text.trim(),
      );
      await box.put(newWorkout.id, newWorkout);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await widget.existingWorkout?.delete();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Latihan' : 'Tambah Latihan'),
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
                label: 'Nama Latihan (mis. Bench Press)',
                icon: Icons.fitness_center,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _setsController,
                      label: 'Set',
                      icon: Icons.repeat,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || int.tryParse(v) == null) ? 'Angka' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _repsController,
                      label: 'Reps',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || int.tryParse(v) == null) ? 'Angka' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _weightController,
                label: 'Berat (kg)',
                icon: Icons.monitor_weight_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    (v == null || double.tryParse(v) == null) ? 'Angka valid' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                    'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _notesController,
                label: 'Catatan (opsional)',
                icon: Icons.note_outlined,
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
