import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/font_helper.dart';
import '../../models/mission_model.dart';

class MissionQrScreen extends StatelessWidget {
  final MissionModel mission;

  const MissionQrScreen({Key? key, required this.mission}) : super(key: key);

  static const Color _primaryBlue = Color(0xFF0059AB);

  /// Génère le payload JSON signé pour le QR Code
  String _buildQrPayload() {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 4));

    final payload = {
      'mission_id': mission.id,
      'professionnel_id': mission.professionnelId,
      'structure_id': mission.structureId,
      'action': 'complete_mission',
      'issued_at': now.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };

    return jsonEncode(payload);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));
    final qrData = _buildQrPayload();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            color: _primaryBlue,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top > 0 ? 8.h : 24.h,
                      left: 12.w,
                      right: 12.w,
                    ),
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 18.sp),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QR Code de fin de mission',
                                style: getInterStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                mission.structureName ?? 'Mission',
                                style: getInterStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  SizedBox(height: 16.h),

                  // Instruction
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _primaryBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: _primaryBlue, size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Présentez ce QR Code à la structure pour valider la fin de votre mission et déclencher le paiement.',
                            style: getInterStyle(
                              fontSize: 13.sp,
                              color: _primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // QR Code
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 240.w,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0059AB),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0059AB),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Infos mission
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                            Icons.business_outlined,
                            'Établissement',
                            mission.structureName ?? '-'),
                        SizedBox(height: 8.h),
                        _buildInfoRow(
                            Icons.location_on_outlined,
                            'Adresse',
                            mission.structureAddress ?? '-'),
                        SizedBox(height: 8.h),
                        _buildInfoRow(
                            Icons.attach_money,
                            'Rémunération',
                            mission.remuneration != null
                                ? '${mission.remuneration} €'
                                : 'Non définie'),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Validité
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time,
                          color: Colors.grey[500], size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'QR Code valide pendant 4 heures',
                        style: getInterStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _primaryBlue, size: 16.sp),
        SizedBox(width: 8.w),
        Text(
          '$label : ',
          style: getInterStyle(
            fontSize: 13.sp,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: getInterStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
