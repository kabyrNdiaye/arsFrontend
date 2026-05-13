import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart' hide Container;
import '../../utils/font_helper.dart';
import '../../services/mission_service.dart';

class MissionQrScannerScreen extends StatefulWidget {
  const MissionQrScannerScreen({Key? key}) : super(key: key);

  @override
  State<MissionQrScannerScreen> createState() => _MissionQrScannerScreenState();
}

class _MissionQrScannerScreenState extends State<MissionQrScannerScreen> {
  static const Color _primaryGreen = Color(0xFF4CA054);
  final MobileScannerController _controller = MobileScannerController();
  final MissionService _missionService = MissionService();

  bool _isProcessing = false;
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onQrDetected(String rawValue) async {
    if (_scanned || _isProcessing) return;
    setState(() {
      _scanned = true;
      _isProcessing = true;
    });
    _controller.stop();

    try {
      // Parser le JSON du QR Code
      final Map<String, dynamic> payload = jsonDecode(rawValue);

      // Vérifier que c'est bien un QR de fin de mission
      if (payload['action'] != 'complete_mission') {
        _showError('QR Code invalide — ce n\'est pas un QR de fin de mission.');
        return;
      }

      // Vérifier l'expiration
      final expiresAt = DateTime.parse(payload['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        _showError('QR Code expiré. Demandez au professionnel d\'en générer un nouveau.');
        return;
      }

      final int missionId = payload['mission_id'];

      // Appel API pour valider la fin de mission
      await _missionService.completeMissionByQr(missionId, payload);

      if (mounted) {
        _showSuccess(missionId);
      }
    } catch (e) {
      _showError('QR Code invalide ou erreur réseau : $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccess(int missionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle,
                  color: _primaryGreen, size: 40.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Mission validée !',
              style: getInterStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'La mission a été marquée comme terminée.\nLa facture et le paiement sont en cours de traitement.',
              textAlign: TextAlign.center,
              style: getInterStyle(
                fontSize: 13.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true); // Retour avec refresh
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Parfait',
                style: getInterStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    setState(() {
      _scanned = false;
      _isProcessing = false;
    });
    _controller.start();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header vert
          Container(
            color: _primaryGreen,
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
                      color: Colors.white.withOpacity(0.2),
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
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 18.sp),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Scanner le QR Code',
                          style: getInterStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Zone scanner
          Expanded(
            child: Stack(
              children: [
                // Scanner caméra
                MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    final barcode = capture.barcodes.firstOrNull;
                    if (barcode?.rawValue != null) {
                      _onQrDetected(barcode!.rawValue!);
                    }
                  },
                ),

                // Cadre + instruction centrés
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cadre de scan
                      Container(
                        width: 240.w,
                        height: 240.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: _primaryGreen, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.qr_code_scanner,
                            size: 80.sp,
                            color: _primaryGreen.withOpacity(0.3),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Instruction
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 32.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: _primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isProcessing
                              ? 'Validation en cours...'
                              : 'Placez le QR Code du professionnel dans le cadre',
                          textAlign: TextAlign.center,
                          style: getInterStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Loading overlay
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
