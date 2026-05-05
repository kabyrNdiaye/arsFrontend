import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../../utils/download_pdf.dart';
import '../../utils/file_helper.dart';
import '../../models/mission_model.dart';
import '../../utils/font_helper.dart';
import 'mission_chat_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class MissionDetailsScreen extends StatelessWidget {
  final MissionModel mission;
  final Color _primaryGreen = const Color(0xFF4CA054);
  final Color _accentGreen = const Color(0xFF2D6A4F);
  final Color _bgLight = const Color(0xFFF0F4F8);

  const MissionDetailsScreen({Key? key, required this.mission})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final bool isAssigned = mission.professionnelNom != null &&
        mission.professionnelNom!.trim().isNotEmpty &&
        mission.professionnelNom != 'Non assigné' &&
        mission.professionnelNom != 'Thomas Martin';

    final String s = (mission.status ?? '').toLowerCase().trim();
    final String statusLabel;
    final Color statusColor;

    if (s == 'terminé' || s == 'terminée' || s == 'finished') {
      statusLabel = lang.translate('finished');
      statusColor = Colors.grey[600]!;
    } else if (s == 'réfusé' || s == 'refusé' || s == 'refused' || s == 'annulé' || s == 'annulée') {
      statusLabel = lang.translate('refused');
      statusColor = const Color(0xFFD32F2F);
    } else if (s == 'en cours' || s == 'in_progress') {
      statusLabel = lang.translate('in_progress');
      statusColor = const Color(0xFF2E7D32);
    } else if (s == 'confirmé' || s == 'confirmée' || s == 'confirmed') {
      statusLabel = lang.translate('confirmed');
      statusColor = const Color(0xFF1565C0);
    } else {
      statusLabel = lang.translate('planned');
      statusColor = const Color(0xFF0059AB);
    }

    // simplified layout using cards for readability
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bgLight,
        body: Column(
          children: [
            _buildHeader(context, lang),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // statut simple
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        border:
                            Border(left: BorderSide(color: statusColor, width: 4)),
                      ),
                      child: Text(
                        statusLabel.toUpperCase(),
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20.h),

            // additional information section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.translate('informations'),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: _primaryGreen)),
                  SizedBox(height: 12.h),
                  if (mission.structureName != null)
                    _buildInfoRow(lang.translate('structure_default'), mission.structureName!),
                  if (mission.structureAddress != null)
                    _buildInfoRow(lang.translate('address_hint') ?? 'Adresse', mission.structureAddress!),
                  _buildInfoRow(
                      lang.translate('real_status'), _translateStatus(mission.status, lang)),
                  if (mission.typesRepas.isNotEmpty)
                    _buildInfoRow(lang.translate('meal_types'),
                        mission.typesRepas.map((meal) => _translateMealType(meal, lang)).join(', ')),
                  if (mission.horaireMission != null)
                    _buildInfoRow(lang.translate('start_time'),
                        DateFormat('HH:mm').format(mission.horaireMission!)),
                  if (mission.heureFin != null)
                    _buildInfoRow(lang.translate('end_time'), mission.heureFin!),
                  _buildInfoRow(lang.translate('created_at'),
                      DateFormat('dd/MM/yyyy').format(mission.createdAt)),
                  _buildInfoRow(lang.translate('created_by_admin'),
                      mission.estCreeParAdmin ? lang.translate('yes') : lang.translate('no')),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // professionnel/assignation
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAssigned ? lang.translate('qualified_expert') : lang.translate('assignment'),
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _primaryGreen),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isAssigned
                        ? mission.professionnelNom!
                        : lang.translate('selecting'),
                    style: getSourceSerifProStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _buildProfessionalProfile(isAssigned, lang),
            SizedBox(height: 24.h),
            // statistiques sans icônes
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.translate('key_figures'),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: _primaryGreen)),
                  SizedBox(height: 12.h),
                  _buildStatsGrid(lang, useIcons: false),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // repas
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.translate('meal_planning'),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: _primaryGreen)),
                  SizedBox(height: 12.h),
                  _buildMealCards(lang, simple: true),
                ],
              ),
            ),
            if (mission.regimesSpeciaux.isNotEmpty) ...[
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accentGreen.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang.translate('diet_preferences'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: _primaryGreen)),
                    SizedBox(height: 12.h),
                    _buildDietChips(lang),
                  ],
                ),
              ),
            ],
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.translate('mission_notes'),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: _primaryGreen)),
                  SizedBox(height: 12.h),
                  _buildNotesLayout(lang),
                ],
              ),
            ),
            SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    ],
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  floatingActionButton: _buildPremiumActionBar(context, lang),
),
);
}

  Widget _buildGlassSectionTitle(String emoji, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 10.w),
          Text(
            title,
            style: getSourceSerifProStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
              child:
                  Divider(color: Colors.black.withOpacity(0.05), thickness: 2)),
        ],
      ),
    );
  }

  Widget _buildProfessionalProfile(bool isAssigned, LanguageProvider lang) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_primaryGreen, _accentGreen]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 35.sp),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAssigned ? lang.translate('qualified_expert') : lang.translate('assignment'),
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _primaryGreen),
                ),
                SizedBox(height: 4.h),
                Text(
                  isAssigned
                      ? mission.professionnelNom!
                      : lang.translate('selecting'),
                  style: getSourceSerifProStyle(
                      fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (isAssigned)
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED), shape: BoxShape.circle),
              child: Icon(Icons.verified, color: Colors.orange, size: 24.sp),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(LanguageProvider lang, {bool useIcons = true}) {
    // display in two rows of key/value, optionally with icons
    Widget rowItem(String label, String val, IconData icon) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (useIcons) Icon(icon, color: _primaryGreen, size: 20.sp),
            if (useIcons) SizedBox(height: 6.h),
            Text(val,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            Text(label,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            rowItem(lang.translate('residents'), "${mission.nbResidentsJour}",
                Icons.groups_rounded),
            _buildStatDivider(),
            rowItem(lang.translate('chefs'), "${mission.nbChefs}", Icons.person_search_rounded),
          ],
        ),
        if (mission.regimesSpecifiques.haches > 0 ||
            mission.regimesSpecifiques.mixes > 0 ||
            mission.regimesSpecifiques.moulines > 0) ...[
          SizedBox(height: 16.h),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallStat("${mission.regimesSpecifiques.haches}", lang.translate('chopped')),
              _buildSmallStat("${mission.regimesSpecifiques.mixes}", lang.translate('mixed')),
              _buildSmallStat(
                  "${mission.regimesSpecifiques.moulines}", lang.translate('ground')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSmallStat(String val, String label) {
    return Column(
      children: [
        Text(val,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: _primaryGreen)),
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildStatDivider() =>
      Container(height: 30.h, width: 1.w, color: Colors.grey[300]);

  Widget _buildStatDetail(IconData icon, String val, String lab) {
    return Column(
      children: [
        Icon(icon, color: _primaryGreen, size: 22.sp),
        SizedBox(height: 8.h),
        Text(val,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
        Text(lab, style: TextStyle(fontSize: 10.sp, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildMealCards(LanguageProvider lang, {bool simple = false}) {
    if (simple) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: mission.repas.map((repas) {
          final components = [
            if (repas.getDisplayName('entree').isNotEmpty)
              "${lang.translate('starter_label')}: ${repas.getDisplayName('entree')}",
            if (repas.getDisplayName('plat').isNotEmpty)
              "${lang.translate('dish_label')}: ${repas.getDisplayName('plat')}",
            if (repas.getDisplayName('accompagnement').isNotEmpty)
              "${lang.translate('side_label')}: ${repas.getDisplayName('accompagnement')}",
            if (repas.getDisplayName('side').isNotEmpty &&
                !repas.getDisplayName('accompagnement').isNotEmpty)
              "${lang.translate('side_label')}: ${repas.getDisplayName('side')}",
            if (repas.getDisplayName('dessert').isNotEmpty)
              "${lang.translate('dessert_label')}: ${repas.getDisplayName('dessert')}",
            if (repas.getDisplayName('simple').isNotEmpty)
              "${lang.translate('composition')}: ${repas.getDisplayName('simple')}",
          ]
              .toSet()
              .toList(); // toSet() to avoid duplicates if side/accompagnement are same

          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _translateMealType(repas.typeRepas, lang).toUpperCase(),
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen),
                ),
                SizedBox(height: 4.h),
                if (components.isEmpty)
                  Text(lang.translate('not_defined'),
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic))
                else
                  ...components
                      .map((c) => Padding(
                            padding: EdgeInsets.only(left: 8.w, bottom: 2.h),
                            child: Text(c,
                                style: TextStyle(
                                    fontSize: 13.sp, color: Colors.black87)),
                          ))
                      .toList(),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: mission.repas.map((repas) {
        return Container(
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Text(
                      _translateMealType(repas.typeRepas, lang).toUpperCase(),
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: _accentGreen),
                    ),
                    const Spacer(),
                    Text(
                      lang.translate('full_menu'),
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: _primaryGreen.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    if (repas.getDisplayName('entree').isNotEmpty)
                      _buildMealComponent(
                          "", lang.translate('starter_label'), repas.getDisplayName('entree')),
                    if (repas.getDisplayName('plat').isNotEmpty)
                      _buildMealComponent(
                          "", lang.translate('dish_label'), repas.getDisplayName('plat')),
                    if (repas.getDisplayName('accompagnement').isNotEmpty)
                      _buildMealComponent(
                          "", lang.translate('side_label'), repas.getDisplayName('accompagnement')),
                    if (repas.getDisplayName('dessert').isNotEmpty)
                      _buildMealComponent(
                          "", lang.translate('dessert_label'), repas.getDisplayName('dessert')),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMealComponent(String iconLabel, String type, String name) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        children: [
          Container(
            width: 45.w,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            decoration: BoxDecoration(
              color: _bgLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                iconLabel,
                style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[400])),
                Text(name,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietChips(LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: mission.regimesSpeciaux.map((diet) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _primaryGreen.withOpacity(0.1),
                _primaryGreen.withOpacity(0.2)
              ]),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _primaryGreen.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _translateDiet(diet, lang),
                  style: TextStyle(
                      color: _accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _translateMealType(String raw, LanguageProvider lang) {
    final value = raw.trim().toLowerCase();
    switch (value) {
      case 'lunch':
      case 'dejeuner':
      case 'déjeuner':
        return lang.translate('lunch');
      case 'dinner':
      case 'dîner':
        return lang.translate('dinner');
      case 'breakfast':
      case 'petit-déjeuner':
      case 'petit dejeuner':
        return lang.translate('breakfast');
      case 'snack':
      case 'goûter':
      case 'gouter':
        return lang.translate('snack');
      case 'brunch':
        return lang.translate('brunch');
      case 'supper':
      case 'souper':
        return lang.translate('supper');
      default:
        return _capitalize(raw.replaceAll('_', ' ').replaceAll('-', ' '));
    }
  }

  String _translateDiet(String raw, LanguageProvider lang) {
    final value = raw.trim().toLowerCase();
    switch (value) {
      case 'diabetic':
      case 'diabetique':
      case 'diabete':
      case 'diabétique':
        return lang.translate('diabetic');
      case 'no_salt':
      case 'no salt':
      case 'sans_sel':
      case 'sans sel':
        return lang.translate('no_salt');
      case 'textures':
        return lang.translate('modified_textures');
      case 'gluten_free':
      case 'gluten free':
      case 'sans_gluten':
      case 'sans gluten':
        return lang.translate('gluten_free');
      case 'vegan':
      case 'végane':
        return lang.translate('vegetarian_diet');
      case 'vegetarian':
      case 'végétarien':
      case 'vegetarien':
        return lang.translate('vegetarian_diet');
      case 'low_carb':
      case 'faible_en_glucides':
      case 'faible en glucides':
        return lang.translate('low_carb');
      case 'low_fat':
      case 'faible_en_graisses':
      case 'faible en graisses':
        return lang.translate('low_fat');
      default:
        return _capitalize(raw.replaceAll('_', ' ').replaceAll('-', ' '));
    }
  }

  String _translateStatus(String raw, LanguageProvider lang) {
    final value = raw.trim().toLowerCase();
    switch (value) {
      case 'pending':
      case 'en attente':
        return lang.translate('pending');
      case 'in_progress':
      case 'in progress':
      case 'en cours':
      case 'en cours de sélection...':
        return lang.translate('in_progress');
      case 'completed':
      case 'finished':
      case 'terminé':
      case 'termine':
        return lang.translate('completed');
      case 'confirmed':
      case 'confirmé':
        return lang.translate('confirmed');
      case 'refused':
      case 'refusé':
        return lang.translate('refused');
      case 'assigned':
      case 'assignée':
      case 'assigné':
        return lang.translate('assigned') ?? 'Assignée';
      default:
        return _capitalize(raw.replaceAll('_', ' ').replaceAll('-', ' '));
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((part) =>
            part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Widget _buildNotesLayout(LanguageProvider lang) {
    return Column(
      children: [
        if (mission.commentaires?.isNotEmpty ?? false)
          _buildElegantNote(lang.translate('structure_request'), mission.commentaires!,
              const Color(0xFFFEF3C7), Colors.amber[900]!),
        if (mission.adminComments?.isNotEmpty ?? false) SizedBox(height: 20.h),
        if (mission.adminComments?.isNotEmpty ?? false)
          _buildElegantNote(lang.translate('admin_instructions'), mission.adminComments!,
              const Color(0xFFF3E8FF), Colors.purple[700]!),
      ],
    );
  }

  Widget _buildElegantNote(String title, String text, Color bg, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: bg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 4,
                  height: 15.h,
                  decoration: BoxDecoration(
                      color: accent, borderRadius: BorderRadius.circular(10))),
              SizedBox(width: 10.w),
              Text(title.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      color: accent)),
            ],
          ),
          SizedBox(height: 15.h),
          Text(text,
              style: TextStyle(
                  fontSize: 15.sp, color: Colors.black87, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildPremiumActionBar(BuildContext context, LanguageProvider lang) {
    return Container(
      height: 60.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 15)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionItem(context, null, lang.translate('chat'), true, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MissionChatScreen(mission: mission)));
          }, lang),
          Container(height: 30.h, width: 1.w, color: Colors.grey[300]),
          _buildActionItem(context, null, lang.translate('report'), false, () {
            _showReportDialog(context, lang);
          }, lang),
          Container(height: 30.h, width: 1.w, color: Colors.grey[300]),
          _buildActionItem(context, null, lang.translate('share'), false, () {
            _shareMission(context, lang);
          }, lang),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, LanguageProvider lang) {
    _saveMissionPdf(context, lang);
  }

  Future<Uint8List> _generateMissionPdf(LanguageProvider lang) async {
    final pw.Document pdfDoc = pw.Document();
    final List<pw.Widget> content = [];

    content.add(pw.Header(level: 0, text: 'Rapport de mission'));
    content
        .add(pw.Paragraph(text: 'Mission: ${mission.structureName ?? 'N/A'}'));
    if (mission.structureAddress != null) {
      content.add(pw.Paragraph(text: 'Adresse: ${mission.structureAddress}'));
    }
    if (mission.horaireMission != null) {
      content.add(pw.Paragraph(
          text:
              'Heure de début: ${DateFormat('HH:mm').format(mission.horaireMission!)}'));
    }
    if (mission.dateFin != null) {
      content.add(pw.Paragraph(
          text:
              'Date / fin: ${DateFormat('dd/MM/yyyy').format(mission.dateFin!)}'));
    }
    content
        .add(pw.Paragraph(text: 'Statut: ${_translateStatus(mission.status, lang)}'));
    content.add(pw.Paragraph(text: 'Résidents: ${mission.nbResidentsJour}'));
    if (mission.typesRepas.isNotEmpty) {
      content.add(pw.Paragraph(
          text:
              'Types de repas: ${mission.typesRepas.map((m) => _translateMealType(m, lang)).join(', ')}'));
    }
    if (mission.regimesSpeciaux.isNotEmpty) {
      content.add(pw.Paragraph(
          text:
              'Régimes spéciaux: ${mission.regimesSpeciaux.map((d) => _translateDiet(d, lang)).join(', ')}'));
    }

    if (mission.repas.isNotEmpty) {
      content.add(pw.Header(level: 1, text: 'Menu'));
      for (final repasItem in mission.repas) {
        final String entree = repasItem.getDisplayName('entree');
        final String plat = repasItem.getDisplayName('plat');
        final String accompagnement =
            repasItem.getDisplayName('accompagnement');
        final String dessert = repasItem.getDisplayName('dessert');
        final String simple = repasItem.getDisplayName('simple');

        content.add(
            pw.Paragraph(text: '${_translateMealType(repasItem.typeRepas, lang)}'));
        if (entree.isNotEmpty) content.add(pw.Bullet(text: 'Entrée: $entree'));
        if (plat.isNotEmpty) content.add(pw.Bullet(text: 'Plat: $plat'));
        if (accompagnement.isNotEmpty)
          content.add(pw.Bullet(text: 'Accompagnement: $accompagnement'));
        if (dessert.isNotEmpty)
          content.add(pw.Bullet(text: 'Dessert: $dessert'));
        if (simple.isNotEmpty) content.add(pw.Bullet(text: 'Simple: $simple'));
      }
    }

    if (mission.commentaires?.isNotEmpty ?? false) {
      content.add(pw.Header(level: 1, text: 'Commentaires Structure'));
      content.add(pw.Paragraph(text: mission.commentaires!));
    }
    if (mission.adminComments?.isNotEmpty ?? false) {
      content.add(pw.Header(level: 1, text: 'Consignes Admin'));
      content.add(pw.Paragraph(text: mission.adminComments!));
    }
    if (mission.codeEntree?.isNotEmpty ?? false) {
      content.add(pw.Paragraph(text: 'Code d\'entrée: ${mission.codeEntree}'));
    }
    if (mission.codeCuisine?.isNotEmpty ?? false) {
      content.add(pw.Paragraph(text: 'Code cuisine: ${mission.codeCuisine}'));
    }

    pdfDoc.addPage(pw.MultiPage(
      pageFormat: pdf.PdfPageFormat.a4,
      build: (pw.Context context) => content,
    ));

    return pdfDoc.save();
  }

  Future<void> _saveMissionPdf(BuildContext context, LanguageProvider lang) async {
    try {
      final bytes = await _generateMissionPdf(lang);
      final String fileName =
          'mission_${mission.id}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        await downloadPdfWeb(bytes, fileName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF téléchargé : $fileName')),
        );
        return;
      }

      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final String filePath = '${directory?.path}/$fileName';
      final file = createFile(filePath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF enregistré: $filePath')),
      );

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Impossible d\'ouvrir le PDF automatiquement.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création du PDF : $e')),
      );
    }
  }

  void _shareMission(BuildContext context, LanguageProvider lang) {
    final StringBuffer shareText = StringBuffer();
    shareText.writeln('Mission: ${mission.structureName ?? 'N/A'}');
    if (mission.structureAddress != null) {
      shareText.writeln('Adresse: ${mission.structureAddress}');
    }
    if (mission.horaireMission != null) {
      shareText.writeln(
          'Heure de début: ${DateFormat('HH:mm').format(mission.horaireMission!)}');
    }
    if (mission.dateFin != null) {
      shareText.writeln(
          'Date / fin: ${DateFormat('dd/MM/yyyy').format(mission.dateFin!)}');
    }
    shareText.writeln('Statut: ${_translateStatus(mission.status, lang)}');
    shareText.writeln('Résidents: ${mission.nbResidentsJour}');
    if (mission.typesRepas.isNotEmpty) {
      shareText.writeln(
          'Types de repas: ${mission.typesRepas.map((m) => _translateMealType(m, lang)).join(', ')}');
    }
    if (mission.regimesSpeciaux.isNotEmpty) {
      shareText.writeln(
          'Régimes spéciaux: ${mission.regimesSpeciaux.map((d) => _translateDiet(d, lang)).join(', ')}');
    }
    if (mission.repas.isNotEmpty) {
      shareText.writeln('\nMenu:');
      for (final repasItem in mission.repas) {
        final String entree = repasItem.getDisplayName('entree');
        final String plat = repasItem.getDisplayName('plat');
        final String accompagnement =
            repasItem.getDisplayName('accompagnement');
        final String dessert = repasItem.getDisplayName('dessert');
        final String simple = repasItem.getDisplayName('simple');

        shareText.writeln('- ${_translateMealType(repasItem.typeRepas, lang)}');
        if (entree.isNotEmpty) shareText.writeln('  Entrée: $entree');
        if (plat.isNotEmpty) shareText.writeln('  Plat: $plat');
        if (accompagnement.isNotEmpty)
          shareText.writeln('  Accompagnement: $accompagnement');
        if (dessert.isNotEmpty) shareText.writeln('  Dessert: $dessert');
        if (simple.isNotEmpty) shareText.writeln('  Simple: $simple');
      }
    }
    if (mission.commentaires?.isNotEmpty ?? false) {
      shareText.writeln('\nCommentaires structure: ${mission.commentaires}');
    }
    if (mission.adminComments?.isNotEmpty ?? false) {
      shareText.writeln('\nConsignes admin: ${mission.adminComments}');
    }
    if (mission.codeEntree?.isNotEmpty ?? false) {
      shareText.writeln('\nCode d\'entrée: ${mission.codeEntree}');
    }
    if (mission.codeCuisine?.isNotEmpty ?? false) {
      shareText.writeln('Code cuisine: ${mission.codeCuisine}');
    }
    shareText.writeln(
        '\nTéléchargez ARS App pour voir tous les détails et suivre la mission.');

    Share.share(
      shareText.toString(),
      subject: 'Détails de mission ARS',
    );
  }

  Widget _buildActionItem(BuildContext context, IconData? icon, String lab,
      bool primary, VoidCallback tap, LanguageProvider lang) {
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Text(lab,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: primary ? _accentGreen : Colors.grey[500])),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Column(
          children: [
            // Trait horizontal décoratif en haut
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top > 0
                    ? MediaQuery.of(context).padding.top + 8.h
                    : 32.h,
                left: 12.w,
                right: 12.w,
              ),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    mission.structureName ?? 'Détails de la mission',
                    style: getSourceSerifProStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}
