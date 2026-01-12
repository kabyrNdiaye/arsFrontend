import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/font_helper.dart';
import 'inscription_client_step5_screen.dart';

class InscriptionClientStep4Screen extends StatefulWidget {
  final Map<String, dynamic>? previousData;

  const InscriptionClientStep4Screen({Key? key, this.previousData}) : super(key: key);

  @override
  _InscriptionClientStep4ScreenState createState() => _InscriptionClientStep4ScreenState();
}

class _InscriptionClientStep4ScreenState extends State<InscriptionClientStep4Screen> {
  final Color _primaryGreen = const Color(0xFF4CA054);
  final Color _lightGreen = const Color(0xFFE8F5E9);
  final Color _accentBlue = const Color(0xFFE3F2FD);
  final Color _primaryBlue = const Color(0xFF1976D2);

  final TextEditingController _residentsController = TextEditingController(text: '100');

  final Set<String> _repasSelectionnes = {'Déjeuner'};
  final Set<String> _regimesSelectionnes = {'Textures modifiées', 'Sans sel'};

  final List<String> _repas = ['Petit-déjeuner', 'Déjeuner', 'Goûter', 'Dîner'];
  final List<String> _regimes = [
    'Textures modifiées',
    'Sans sel',
    'Diabétique',
    'Sans gluten',
    'Végétarien'
  ];

  @override
  void dispose() {
    _residentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 30.h),

                              // Icône établissement centrée
                              Center(
                                child: Container(
                                  width: 80.w,
                                  height: 80.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50], // Cercle gris très clair comme dans le mockup
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/icon_client.png',
                                      color: _primaryGreen,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 20.h),

                              // Titre
                              Center(
                                child: Text(
                                  'Informations complémentaires',
                                  style: getSourceSerifProStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              SizedBox(height: 4.h),

                              // Sous-titre
                              Center(
                                child: Text(
                                  'Détails sur vos besoins',
                                  style: getSourceSerifProStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),

                              SizedBox(height: 32.h),

                              // Nombre moyen de résidents
                              _buildSectionTitle('Nombre moyen de résidents par jour'),
                              SizedBox(height: 12.h),
                              _buildResidentsInput(),

                              SizedBox(height: 24.h),

                              // Type de repas proposées
                              _buildSectionTitle('Type de repas proposées'),
                              SizedBox(height: 12.h),
                              _buildRepasGrid(),

                              SizedBox(height: 24.h),

                              // Régimes spéciaux gérés
                              _buildSectionTitle('Régimes spéciaux gérés'),
                              SizedBox(height: 12.h),
                              _buildRegimesList(),

                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bouton Continuer
                    _buildContinueButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 100.h,
      color: _primaryGreen,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top > 0 ? 8.h : 32.h,
                left: 12.w,
                right: 12.w,
              ),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 20.h,
                    left: 16.w,
                    right: 16.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                              SizedBox(width: 4.w),
                              Text(
                                'Retour',
                                style: getSourceSerifProStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Étape 4/5',
                          style: getSourceSerifProStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 6.h,
                    left: 16.w,
                    right: 16.w,
                    child: Container(
                      height: 4.h,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2.h),
                            ),
                          ),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: getSourceSerifProStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildResidentsInput() {
    return TextFormField(
      controller: _residentsController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '100',
        hintStyle: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryGreen, width: 2),
        ),
      ),
      style: getSourceSerifProStyle(fontSize: 15.sp, color: Colors.black87),
    );
  }

  Widget _buildRepasGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: _repas.length,
      itemBuilder: (context, index) {
        final label = _repas[index];
        final isSelected = _repasSelectionnes.contains(label);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _repasSelectionnes.remove(label);
              } else {
                _repasSelectionnes.add(label);
              }
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? _accentBlue : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? _primaryBlue : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: getInterStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? _primaryBlue : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegimesList() {
    return Column(
      children: _regimes.map((label) {
        final isSelected = _regimesSelectionnes.contains(label);
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _regimesSelectionnes.remove(label);
                } else {
                  _regimesSelectionnes.add(label);
                }
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: isSelected ? _accentBlue : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? _primaryBlue : Colors.grey[300]!,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: getInterStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? _primaryBlue : Colors.black87,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: _primaryBlue, size: 20.sp),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: ElevatedButton(
        onPressed: () {
          final data = {
            ...(widget.previousData ?? {}),
            'nombreResidents': _residentsController.text,
            'repas': _repasSelectionnes.toList(),
            'regimes': _regimesSelectionnes.toList(),
          };
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InscriptionClientStep5Screen(previousData: data),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 54.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continuer',
              style: getInterStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded, size: 24.sp),
          ],
        ),
      ),
    );
  }
}