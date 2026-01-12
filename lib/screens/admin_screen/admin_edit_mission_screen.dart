import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';

class AdminEditMissionScreen extends StatefulWidget {
  final Map<String, dynamic> mission;
  final Function(Map<String, dynamic>)? onMissionUpdated;

  const AdminEditMissionScreen({
    Key? key,
    required this.mission,
    this.onMissionUpdated,
  }) : super(key: key);

  @override
  _AdminEditMissionScreenState createState() => _AdminEditMissionScreenState();
}

class _AdminEditMissionScreenState extends State<AdminEditMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryPurple = const Color(0xFF7C39D3);
  
  // Contrôleurs
  late TextEditingController _establishmentController;
  late TextEditingController _addressController;
  late TextEditingController _professionalController;
  late TextEditingController _scheduleController;
  late TextEditingController _dateController;
  
  late String _selectedStatus;
  final List<String> _statusOptions = ['En cours', 'Confirmée', 'Réfusé'];

  @override
  void initState() {
    super.initState();
    _establishmentController = TextEditingController(text: widget.mission['establishment'] ?? '');
    _addressController = TextEditingController(text: widget.mission['address'] ?? '');
    _professionalController = TextEditingController(text: widget.mission['professional'] ?? '');
    _scheduleController = TextEditingController(text: widget.mission['schedule'] ?? '');
    _dateController = TextEditingController(text: widget.mission['date'] ?? '');
    _selectedStatus = widget.mission['status'] ?? 'En cours';
  }

  @override
  void dispose() {
    _establishmentController.dispose();
    _addressController.dispose();
    _professionalController.dispose();
    _scheduleController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _establishmentController,
                      label: 'Établissement',
                      hint: 'Ex: EHPAD Les Jardins',
                      icon: Icons.business_outlined,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Adresse',
                      hint: 'Ex: 12 Rue de la Santé, Paris',
                      icon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _professionalController,
                      label: 'Professionnel',
                      hint: 'Ex: Jean Dupont',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _scheduleController,
                      label: 'Horaire',
                      hint: 'Ex: 7h30 - 16h00',
                      icon: Icons.access_time,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _dateController,
                      label: 'Date',
                      hint: 'Ex: 17 Nov 2025',
                      icon: Icons.calendar_today_outlined,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            _dateController.text = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Statut',
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.info_outline, color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                        items: _statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              status,
                              style: getSourceSerifProStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleUpdateMission,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sauvegarder les modifications',
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getSourceSerifProStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextFormField(
              controller: controller,
              enabled: onTap == null,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(icon, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              style: getSourceSerifProStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est requis';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: _primaryPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Trait horizontal en haut
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top + 8.h : 32.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Modifier la mission',
                    textAlign: TextAlign.center,
                    style: getSourceSerifProStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 48.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return months[month - 1];
  }

  void _handleUpdateMission() {
    if (_formKey.currentState!.validate()) {
      final updatedMission = {
        ...widget.mission,
        'establishment': _establishmentController.text,
        'address': _addressController.text,
        'professional': _professionalController.text,
        'schedule': _scheduleController.text,
        'date': _dateController.text,
        'status': _selectedStatus,
      };

      if (widget.onMissionUpdated != null) {
        widget.onMissionUpdated!(updatedMission);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mission modifiée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
