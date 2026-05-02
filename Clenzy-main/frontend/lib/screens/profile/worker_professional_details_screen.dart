import 'package:flutter/material.dart';
import '../../models/partner_profile_data.dart';

class WorkerProfessionalDetailsScreen extends StatefulWidget {
  const WorkerProfessionalDetailsScreen({super.key});

  @override
  State<WorkerProfessionalDetailsScreen> createState() =>
      _WorkerProfessionalDetailsScreenState();
}

class _WorkerProfessionalDetailsScreenState
    extends State<WorkerProfessionalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _professionController = TextEditingController(
    text: 'Expert Professional',
  );
  final _experienceController = TextEditingController(text: '8');
  final _skillsController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = PartnerProfileData.instance;
    _bioController.text = data.bio;
    _skillsController.text = data.allServices.join(', ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final data = PartnerProfileData.instance;
      data.bio = _bioController.text.trim();
      data.customSkills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      data.selectedServices = []; // Clear predefined to prioritize custom

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Professional Details updated successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Professional Details',
          style: TextStyle(
            color: Color(0xFF1A1D26),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1D26)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                'Full Name',
                _nameController,
                Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Profession Title',
                _professionController,
                Icons.work_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Years of Experience',
                _experienceController,
                Icons.history,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Top Skills (comma separated)',
                _skillsController,
                Icons.star_border,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Short Bio',
                _bioController,
                Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3366FF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D26),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3366FF),
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 0,
            ),
          ),
          validator: (value) =>
              value!.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }
}
