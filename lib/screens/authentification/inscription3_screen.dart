import 'package:flutter/material.dart';
import '../../utils/font_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../professionnel_screen/home_screen.dart';

class Inscription3Screen extends StatefulWidget {
  @override
  _Inscription3ScreenState createState() => _Inscription3ScreenState();
}

class _Inscription3ScreenState extends State<Inscription3Screen> {
  List<Experience> _experiences = [
    Experience(
      title: 'Cuisinier à iTea',
      startDate: DateTime(2020, 6),
      endDate: DateTime(2023, 6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Header avec "Retour", flèche retour et logo ARS
            Container(
              width: double.infinity,
              height: 100.h,
              color: Colors.white,
              child: Stack(
                children: [
                  // Row avec flèche retour et texte "Retour" - aligné avec le centre du logo
                  Positioned(
                    left: 0,
                    top: 35.h + (64.h / 2) - 20.h, // Centre du logo moins la moitié de la hauteur du bouton
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          // Flèche retour
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          // Texte "Retour"
                          Text(
                            langProvider.translate('back'),
                            style: getSourceSerifProStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000),
                              height: 1.0,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Logo positionné selon les paramètres
                  Positioned(
                    left: 278.w,
                    top: 35.h,
                    child: Image.asset(
                      'assets/images/logo2.png',
                      width: 85.w,
                      height: 64.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 32.h, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre principal
                    Text(
                      langProvider.translate('journey_title'),
                      style: getSourceSerifProStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000000),
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Sous-titre
                    Text(
                      langProvider.translate('journey_subtitle'),
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6C7278),
                        height: 1.0,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Liste des expériences
                    ..._experiences.asMap().entries.map((entry) {
                      int index = entry.key;
                      Experience experience = entry.value;
                      return _buildExperienceCard(
                        index: index,
                        experience: experience,
                        onRemove: () {
                          setState(() {
                            _experiences.removeAt(index);
                          });
                        },
                        onUpdate: (updatedExperience) {
                          setState(() {
                            _experiences[index] = updatedExperience;
                          });
                        },
                        langProvider: langProvider,
                      );
                    }).toList(),
                    
                    SizedBox(height: 20.h),
                    
                    // Bouton Ajouter une expérience
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _experiences.add(Experience(
                            title: '',
                            startDate: DateTime.now(),
                            endDate: DateTime.now(),
                          ));
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 20.sp, color: Colors.grey[700]),
                          SizedBox(width: 8.w),
                          Text(
                            langProvider.translate('add_experience'),
                            style: getSourceSerifProStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Bouton S'INSCRIRE - juste après le formulaire
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16.h),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigation vers la page d'accueil après inscription
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0059AB),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          langProvider.translate('register_submit'),
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
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
    );
  }

  Widget _buildExperienceCard({
    required int index,
    required Experience experience,
    required VoidCallback onRemove,
    required Function(Experience) onUpdate,
    required LanguageProvider langProvider,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec titre et bouton X
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${langProvider.translate('professional_experience')} ${index + 1}',
                style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF000000),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20.sp, color: Colors.red),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Champ titre de l'expérience
          TextField(
            controller: TextEditingController(text: experience.title),
            decoration: InputDecoration(
              hintText: langProvider.translate('experience_hint'),
              hintStyle: getSourceSerifProStyle(
                fontSize: 16.sp,
                color: Colors.grey[400],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF6C7278)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF6C7278)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0059AB), width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            style: getSourceSerifProStyle(
              fontSize: 16.sp,
              color: Color(0xFF000000),
            ),
            onChanged: (value) {
              onUpdate(Experience(
                title: value,
                startDate: experience.startDate,
                endDate: experience.endDate,
              ));
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Champs de date côte à côte
          Row(
            children: [
              // Date Début
              Expanded(
                child: _buildDateField(
                  label: langProvider.translate('start_date'),
                  date: experience.startDate,
                  langProvider: langProvider,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: experience.startDate,
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      initialDatePickerMode: DatePickerMode.year,
                      helpText: langProvider.translate('select_year_month'),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: const Color(0xFF0059AB),
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      onUpdate(Experience(
                        title: experience.title,
                        startDate: DateTime(picked.year, picked.month),
                        endDate: experience.endDate,
                      ));
                    }
                  },
                ),
              ),
              
              SizedBox(width: 12.w),
              
              // Date Fin
              Expanded(
                child: _buildDateField(
                  label: langProvider.translate('end_date'),
                  date: experience.endDate,
                  langProvider: langProvider,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: experience.endDate,
                      firstDate: experience.startDate,
                      lastDate: DateTime.now(),
                      initialDatePickerMode: DatePickerMode.year,
                      helpText: langProvider.translate('select_year_month'),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: const Color(0xFF0059AB),
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      onUpdate(Experience(
                        title: experience.title,
                        startDate: experience.startDate,
                        endDate: DateTime(picked.year, picked.month),
                      ));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required LanguageProvider langProvider,
  }) {
    final monthNames = [
      langProvider.translate('january'),
      langProvider.translate('february'),
      langProvider.translate('march'),
      langProvider.translate('april'),
      langProvider.translate('may'),
      langProvider.translate('june'),
      langProvider.translate('july'),
      langProvider.translate('august'),
      langProvider.translate('september'),
      langProvider.translate('october'),
      langProvider.translate('november'),
      langProvider.translate('december'),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getSourceSerifProStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6C7278),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF6C7278)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${monthNames[date.month - 1]} ${date.year}',
                  style: getSourceSerifProStyle(
                    fontSize: 16.sp,
                    color: Color(0xFF000000),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20.sp,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Experience {
  String title;
  DateTime startDate;
  DateTime endDate;

  Experience({
    required this.title,
    required this.startDate,
    required this.endDate,
  });
}

