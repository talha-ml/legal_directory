import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../database/db_helper.dart';
import '../models/client_model.dart';
import '../services/notification_service.dart'; // 🌟 Notification Service Import 🌟

class AddEditScreen extends StatefulWidget {
  final ClientModel? client;

  const AddEditScreen({super.key, this.client});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _dateController;

  String _imagePath = '';
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _ageController = TextEditingController(text: widget.client?.age?.toString() ?? '');
    _dateController = TextEditingController(text: widget.client?.hearingDate == 'No Date Set' ? '' : widget.client?.hearingDate ?? '');
    _imagePath = widget.client?.image ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0B132B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _scanDocumentWithAI() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _isScanning = true);

      try {
        final inputImage = InputImage.fromFilePath(pickedFile.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

        String extractedText = recognizedText.text;
        textRecognizer.close();

        setState(() => _isScanning = false);

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.document_scanner, color: Color(0xFF0B132B)),
                  const SizedBox(width: 10),
                  Text('Scanned Text', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: SelectableText(
                  extractedText.isEmpty ? "No text found in the image." : extractedText,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          );
        }
      } catch (e) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to scan document: $e')),
        );
      }
    }
  }

  // 🌟 UPDATE: Save function ab Notification bhi lagayega 🌟
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_imagePath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a case document/photo', style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final dateText = _dateController.text.trim().isEmpty ? 'No Date Set' : _dateController.text.trim();

      final client = ClientModel(
        id: widget.client?.id,
        image: _imagePath,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        hearingDate: dateText,
      );

      int insertedId = 0;

      // Database mein save ya update karna
      if (widget.client == null) {
        insertedId = await DatabaseHelper.instance.insert(client);
      } else {
        await DatabaseHelper.instance.update(client);
        insertedId = client.id!;
      }

      // 🌟 Alarm / Notification Schedule Karna 🌟
      if (dateText != 'No Date Set') {
        await NotificationService.scheduleHearingReminder(
          id: insertedId,
          clientName: client.name,
          dateString: dateText,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  InputDecoration _customInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF0B132B)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF0B132B), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.client != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Case Record' : 'Add New Case',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Hero(
                        tag: isEditing ? 'profile_${widget.client!.id}' : 'new_profile',
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.white,
                          backgroundImage: _imagePath.isNotEmpty ? FileImage(File(_imagePath)) : null,
                          child: _imagePath.isEmpty
                              ? const Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFF0B132B))
                              : null,
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC107),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: const Icon(Icons.edit, size: 20, color: Color(0xFF0B132B)),
                      ).animate().scale(delay: 300.ms),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Tap to select Case Photo',
                  style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 30),

              OutlinedButton.icon(
                onPressed: _isScanning ? null : _scanDocumentWithAI,
                icon: _isScanning
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.document_scanner_rounded, color: Color(0xFF0B132B)),
                label: Text(
                  _isScanning ? 'AI is scanning...' : 'Scan Legal Document (AI OCR)',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF0B132B)),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF0B132B), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 30),

              TextFormField(
                controller: _nameController,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                textCapitalization: TextCapitalization.words,
                decoration: _customInputDecoration('Client / Case Name', Icons.person_outline),
                validator: (value) => value!.trim().isEmpty ? 'Please enter a name' : null,
              ).animate().fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                textCapitalization: TextCapitalization.words,
                decoration: _customInputDecoration('Case Category (e.g., Civil, Criminal)', Icons.category_outlined),
                validator: (value) => value!.trim().isEmpty ? 'Please enter a category' : null,
              ).animate().fade(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 20),

              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                decoration: _customInputDecoration('Hearing Number', Icons.numbers_rounded),
                validator: (value) {
                  if (value!.trim().isEmpty) return 'Please enter hearing number';
                  if (int.tryParse(value.trim()) == null) return 'Please enter a valid number';
                  return null;
                },
              ).animate().fade(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 20),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF0B132B)),
                decoration: _customInputDecoration('Next Hearing Date', Icons.calendar_month_rounded).copyWith(
                  suffixIcon: const Icon(Icons.arrow_drop_down_circle, color: Color(0xFFFFC107)),
                ),
                validator: (value) => value!.trim().isEmpty ? 'Please select a date' : null,
              ).animate().fade(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B132B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 5,
                  shadowColor: const Color(0xFF0B132B).withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  isEditing ? 'Update Record' : 'Save Record',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ).animate().fade(delay: 500.ms, duration: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}