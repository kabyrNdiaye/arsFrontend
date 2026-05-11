import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'document_viewer_screen.dart';

class AdminStructureDetailScreen extends StatefulWidget {
  final User structure;

  const AdminStructureDetailScreen({
    Key? key,
    required this.structure,
  }) : super(key: key);

  @override
  _AdminStructureDetailScreenState createState() =>
      _AdminStructureDetailScreenState();
}

class _AdminStructureDetailScreenState
    extends State<AdminStructureDetailScreen> {
  final Color _primaryPurple = const Color(0xFF7C39D3);
  final AuthService _authService = AuthService();
  bool _isValidating = false;

  Future<void> _validateUser(String statut) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          statut == 'valide' ? 'Valider cet établissement ?' : 'Refuser cet établissement ?',
          style: getSourceSerifProStyle(
              fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          statut == 'valide'
              ? 'L\'établissement pourra accéder à l\'application après validation.'
              : 'Le responsable sera informé du refus de l\'inscription.',
          style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
                style: getSourceSerifProStyle(
                    fontSize: 14.sp, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  statut == 'valide' ? const Color(0xFF4CAF50) : Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              statut == 'valide' ? 'Valider' : 'Refuser',
              style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isValidating = true);

    try {
      final result = await _authService.validateUser(
          widget.structure.id, statut);

      if (!mounted) return;
      setState(() => _isValidating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? (statut == 'valide'
                    ? 'Établissement validé avec succès ✓'
                    : 'Établissement refusé')
                : (result['message'] ?? 'Erreur'),
            style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.white),
          ),
          backgroundColor:
              result['success'] == true && statut == 'valide'
                  ? const Color(0xFF4CAF50)
                  : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (result['success'] == true) {
        Navigator.pop(context, true); // Retour avec refresh
      }
    } catch (e) {
      setState(() => _isValidating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    final struct = widget.structure;
    final isPending = struct.statutValidation == 'en_attente';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          _buildHeader(struct),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statut de validation actuel
                  _buildStatusBanner(struct),
                  SizedBox(height: 16.h),

                  // Statistiques
                  _buildStatsSection(struct),
                  SizedBox(height: 16.h),

                  // Informations de l'établissement
                  _buildSection(
                    title: 'Détails de l\'établissement',
                    icon: Icons.business,
                    children: [
                      _buildInfoRow('Nom', struct.nomEtablissement ?? '-'),
                      _buildInfoRow('Type', struct.typeEtablissement ?? '-'),
                      _buildInfoRow('Capacité', struct.capacite != null ? '${struct.capacite} résidents' : '-'),
                      _buildInfoRow('Adresse', structureAddress(struct)),
                      _buildInfoRow('Téléphone', struct.telephoneEtablissement ?? '-'),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Informations du contact
                  _buildSection(
                    title: 'Responsable / Contact',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoRow('Nom complet', struct.fullName),
                      _buildInfoRow('Fonction', struct.fonction ?? '-'),
                      _buildInfoRow('Email', struct.email),
                      _buildInfoRow('Téléphone', struct.phone),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Documents
                  _buildDocumentsSection(struct),
                ],
              ),
            ),
          ),
        ],
      ),

      // Boutons de validation flottants (uniquement si en attente)
      bottomNavigationBar: isPending
          ? _buildValidationBar()
          : null,
    );
  }

  String structureAddress(User s) {
    if (s.adresse == null && s.ville == null) return '-';
    return [s.adresse, s.codePostal, s.ville]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');
  }

  Widget _buildHeader(User struct) {
    return Container(
      color: _primaryPurple,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 16.h,
                left: 12.w,
                right: 12.w,
              ),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
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
                          struct.nomEtablissement ?? 'Établissement',
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Fiche établissement',
                          style: getSourceSerifProStyle(
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
    );
  }

  Widget _buildStatusBanner(User struct) {
    final statut = struct.statutValidation ?? 'en_attente';
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (statut) {
      case 'valide':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle_outline;
        label = 'Établissement validé';
        break;
      case 'refuse':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        icon = Icons.cancel_outlined;
        label = 'Inscription refusée';
        break;
      default:
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFFFA000);
        icon = Icons.access_time_rounded;
        label = 'En attente de validation';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20.sp),
          SizedBox(width: 10.w),
          Text(
            label,
            style: getSourceSerifProStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(User struct) {
    final stats = struct.stats ?? {};
    final total = stats['total_missions']?.toString() ?? '0';
    final active = stats['active_missions']?.toString() ?? '0';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: _primaryPurple, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'Activité de l\'établissement',
                style: getSourceSerifProStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(total, 'Total missions', Colors.blue),
              _buildStatItem(active, 'En cours / A venir', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: getSourceSerifProStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: getSourceSerifProStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primaryPurple, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: getSourceSerifProStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey[100]),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              label,
              style: getSourceSerifProStyle(
                fontSize: 13.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: getSourceSerifProStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(User struct) {
    final docs = <Map<String, String>>[];

    if (struct.rawDocuments != null) {
      struct.rawDocuments!.forEach((key, url) {
        if (url.toString().isEmpty) return;
        if (key == 'photo_profil_path' || key == 'profileImage') return;

        String label = '';
        final String lowKey = key.toLowerCase();

        // Si c'est déjà un "beau nom"
        if (key.isNotEmpty && key[0] == key[0].toUpperCase() && !key.contains('_path')) {
          label = key;
        } else if (lowKey.contains('contrat')) {
          label = 'Contrat de prestation';
        } else if (lowKey.contains('plan_locaux')) {
          label = 'Plan des locaux';
        } else if (lowKey.contains('reglement_interieur')) {
          label = 'Règlement intérieur';
        } else {
          label = key.replaceAll('_path', '').replaceAll('_', ' ');
          if (label.isNotEmpty) {
            label = label[0].toUpperCase() + label.substring(1);
          }
        }

        docs.add({'label': label, 'url': url.toString()});
      });
      docs.sort((a, b) => a['label']!.compareTo(b['label']!));
    }

    if (docs.isEmpty) {
      if (struct.contratPrestation != null && struct.contratPrestation!.isNotEmpty)
        docs.add({'label': 'Contrat prestation', 'url': struct.contratPrestation!});
      if (struct.planLocaux != null && struct.planLocaux!.isNotEmpty)
        docs.add({'label': 'Plan des locaux', 'url': struct.planLocaux!});
      if (struct.reglementInterieur != null && struct.reglementInterieur!.isNotEmpty)
        docs.add({'label': 'Règlement intérieur', 'url': struct.reglementInterieur!});
    }

    if (docs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(children: [
              Icon(Icons.description_outlined,
                  color: _primaryPurple, size: 18.sp),
              SizedBox(width: 8.w),
              Text('Documents fournis',
                  style: getSourceSerifProStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ]),
            SizedBox(height: 16.h),
            Text('Aucun document fourni',
                style: getSourceSerifProStyle(
                    fontSize: 13.sp, color: Colors.grey[400])),
          ],
        ),
      );
    }

    return _buildSection(
      title: 'Documents (${docs.length})',
      icon: Icons.description_outlined,
      children: docs
          .map((doc) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocumentViewerScreen(
                        title: doc['label']!,
                        url: doc['url']!,
                      ),
                    ),
                  );
                },
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file_outlined,
                            color: _primaryPurple, size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            doc['label']!,
                            style: getSourceSerifProStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: _primaryPurple,
                            ),
                          ),
                        ),
                        Icon(Icons.open_in_new,
                            color: _primaryPurple, size: 16.sp),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildValidationBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: _isValidating
          ? Center(child: CircularProgressIndicator(color: _primaryPurple))
          : Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54.h,
                    child: OutlinedButton(
                      onPressed: () => _validateUser('refuse'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _primaryPurple.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Refuser',
                        style: getSourceSerifProStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: _primaryPurple,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: () => _validateUser('valide'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: _primaryPurple.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Valider l\'accès',
                        style: getSourceSerifProStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
