import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../utils/font_helper.dart';
import '../../providers/language_provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'document_viewer_screen.dart';
import 'admin_mission_checklist_screen.dart';

class AdminProfessionnelDetailScreen extends StatefulWidget {
  final User professional;

  const AdminProfessionnelDetailScreen({
    Key? key,
    required this.professional,
  }) : super(key: key);

  @override
  _AdminProfessionnelDetailScreenState createState() =>
      _AdminProfessionnelDetailScreenState();
}

class _AdminProfessionnelDetailScreenState
    extends State<AdminProfessionnelDetailScreen> with WidgetsBindingObserver {
  final Color _primaryPurple = const Color(0xFF7C39D3);
  final AuthService _authService = AuthService();
  bool _isValidating = false;
  bool _isDeleting = false;
  late User _professional;
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _professional = widget.professional;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _lastLifecycleState != AppLifecycleState.resumed) {
      _refreshProfessionalData();
    }
    _lastLifecycleState = state;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refreshProfessionalData() async {
    // Recharger les données du professionnel depuis la base de données
    try {
      final professionals = await _authService.getProfessionals();
      final refreshedPro = professionals.firstWhere(
        (p) => p.id == widget.professional.id,
        orElse: () => widget.professional,
      );
      if (mounted) {
        setState(() => _professional = refreshedPro);
      }
    } catch (e) {
      print('Erreur lors du rafraîchissement: $e');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de lancer l\'appel')),
      );
    }
  }

  Future<void> _validateUser(String statut) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          statut == 'valide' ? 'Valider ce compte ?' : 'Refuser ce compte ?',
          style: getSourceSerifProStyle(
              fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          statut == 'valide'
              ? 'L\'utilisateur pourra accéder à l\'application après validation.'
              : 'L\'utilisateur sera informé du refus de son inscription.',
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
                  statut == 'valide' ? _primaryPurple : Colors.grey[200],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(
              statut == 'valide' ? 'Valider' : 'Refuser',
              style: getSourceSerifProStyle(
                  fontSize: 14.sp,
                  color: statut == 'valide' ? Colors.white : Colors.red,
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
          widget.professional.id, statut);

      if (!mounted) return;
      setState(() => _isValidating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? (statut == 'valide'
                    ? 'Compte validé avec succès ✓'
                    : 'Compte refusé')
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

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Supprimer ce compte ?',
          style: getSourceSerifProStyle(
              fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Cette action est irréversible. Le professionnel ne pourra plus se connecter à la plateforme.',
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
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Supprimer définitivement',
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

    setState(() => _isDeleting = true);

    try {
      final result = await _authService.deleteUser(widget.professional.id);

      if (!mounted) return;
      setState(() => _isDeleting = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Compte supprimé définitivement ✓',
              style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.white),
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Retour avec refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Erreur lors de la suppression')),
        );
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    final pro = widget.professional;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF7C39D3), // _primaryPurple
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          _buildHeader(pro),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statut de validation actuel
                  _buildStatusBanner(pro),
                  SizedBox(height: 16.h),

                  // Statistiques de missions
                  _buildStatsSection(pro),
                  SizedBox(height: 16.h),

                  // Informations personnelles
                  _buildSection(
                    title: 'Informations personnelles',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoRow('Nom complet', pro.fullName),
                      _buildInfoRow('Email', pro.email ?? ''),
                      _buildInfoRow('Téléphone', pro.telephone ?? '-'),
                      _buildInfoRow('Adresse',
                          [pro.adresse, pro.ville].where((e) => e != null && e.isNotEmpty).join(', ') + (pro.codePostal != null ? ' ${pro.codePostal}' : '')),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Informations professionnelles
                  _buildSection(
                    title: 'Profil professionnel',
                    icon: Icons.badge_outlined,
                    children: [
                      _buildInfoRow('Fonction', pro.displayFunction),
                      _buildInfoRow('Expérience',
                          pro.anneesExperience != null ? '${pro.anneesExperience} an(s)' : '-'),
                      _buildInfoRow('Date de naissance', _formatDisplayDate(pro.dateNaissance)),
                      if (pro.specialites != null && pro.specialites!.isNotEmpty)
                        _buildInfoRow(
                            'Spécialités', pro.specialites!.join(', ')),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Documents
                  _buildDocumentsSection(pro),
                ],
              ),
            ),
          ),
        ],
      ),

      // Barre d'actions admin : toujours visible
      bottomNavigationBar: _buildValidationBar(pro),
    ),
  );
}

  Widget _buildHeader(User pro) {
    return Container(
      decoration: BoxDecoration(
        color: _primaryPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 40.h,
              left: 12.w,
              right: 12.w,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
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
              // Avatar
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: pro.profileImage != null
                    ? ClipOval(
                        child: Image.network(pro.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 24.sp)))
                    : Icon(Icons.person_outline,
                        color: Colors.white, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pro.fullName,
                      style: getSourceSerifProStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      pro.displayFunction,
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
        ],
      ),
    );
  }

  Widget _buildStatusBanner(User pro) {
    final statut = pro.statutValidation ?? 'en_attente';
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (statut) {
      case 'valide':
        bgColor = _primaryPurple.withOpacity(0.08);
        textColor = _primaryPurple;
        icon = Icons.check_circle_outline;
        label = 'Compte validé';
        break;
      case 'refuse':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        icon = Icons.cancel_outlined;
        label = 'Compte refusé';
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

  Widget _buildStatsSection(User pro) {
    final stats = pro.stats ?? {};
    final total = stats['total_missions']?.toString() ?? '0';
    final completed = stats['completed_missions']?.toString() ?? '0';
    final pending = stats['pending_missions']?.toString() ?? '0';

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
                'Statistiques de missions',
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
              _buildStatItem(total, 'Total', Colors.blue),
              _buildStatItem(completed, 'Terminées', Colors.green),
              _buildStatItem(pending, 'En attente', Colors.orange),
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

  String _formatDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty || value == '-' || value == ' ') {
      return const SizedBox.shrink();
    }
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

  Widget _buildDocumentsSection(User pro) {
    final List<Map<String, String>> docs = [];
    
    if (pro.rawDocuments != null) {
      pro.rawDocuments!.forEach((key, url) {
        if (url.toString().isEmpty) return;
        if (key == 'photo_profil_path' || key == 'profileImage') return;
        
        String label = '';
        if (key.contains('diplome')) {
          label = 'Diplôme';
          final RegExp regex = RegExp(r'_(\d+)$');
          final match = regex.firstMatch(key);
          if (match != null) {
            int index = int.parse(match.group(1)!) + 1;
            label = 'Diplôme $index';
          }
        } else if (key.contains('medical')) {
          label = 'Certificat médical';
        } else if (key.contains('permis')) {
          label = 'Permis de conduire';
        } else if (key.contains('contrat')) {
          label = 'Contrat de prestation';
        } else if (key.contains('plan_locaux')) {
          label = 'Plan des locaux';
        } else if (key.contains('reglement_interieur')) {
          label = 'Règlement intérieur';
        } else {
          label = key.replaceAll('_path', '').replaceAll('_', ' ');
          label = label[0].toUpperCase() + label.substring(1);
        }

        docs.add({'label': label, 'url': url.toString()});
      });

      docs.sort((a, b) => a['label']!.compareTo(b['label']!));
    }
    
    if (docs.isEmpty) {
      if (pro.diplomePath != null && pro.diplomePath!.isNotEmpty)
        docs.add({'label': 'Diplôme', 'url': pro.diplomePath!});
      if (pro.certificatMedical != null && pro.certificatMedical!.isNotEmpty)
        docs.add({'label': 'Certificat médical', 'url': pro.certificatMedical!});
      if (pro.permiConduire != null && pro.permiConduire!.isNotEmpty)
        docs.add({'label': 'Permis de conduire', 'url': pro.permiConduire!});
      if (pro.contratPrestation != null && pro.contratPrestation!.isNotEmpty)
        docs.add({'label': 'Contrat prestation', 'url': pro.contratPrestation!});
      if (pro.planLocaux != null && pro.planLocaux!.isNotEmpty)
        docs.add({'label': 'Plan des locaux', 'url': pro.planLocaux!});
      if (pro.reglementInterieur != null && pro.reglementInterieur!.isNotEmpty)
        docs.add({'label': 'Règlement intérieur', 'url': pro.reglementInterieur!});
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
              Text('Documents',
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
                        primaryColor: _primaryPurple,
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

  Widget _buildValidationBar(User pro) {
    final statut = pro.statutValidation ?? 'en_attente';
    final isValide = statut == 'valide';
    final isRefuse = statut == 'refuse';

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
      child: (_isValidating || _isDeleting)
          ? Center(child: CircularProgressIndicator(color: _primaryPurple))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ligne 1 : Actions de validation (Refuser / Valider)
                Row(
                  children: [
                    if (isValide || !isRefuse)
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: OutlinedButton(
                            onPressed: () => _validateUser('refuse'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: _primaryPurple.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Refuser',
                              style: getSourceSerifProStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: _primaryPurple,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    if (!isValide && !isRefuse) SizedBox(width: 12.w),

                    if (!isValide)
                      Expanded(
                        flex: (!isRefuse) ? 1 : 2,
                        child: SizedBox(
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: () => _validateUser('valide'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryPurple,
                              foregroundColor: Colors.white,
                              shadowColor: _primaryPurple.withOpacity(0.4),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Valider',
                              style: getSourceSerifProStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 10.h),

                // Ligne 2 : Action de suppression (Toujours en bas, pleine largeur)
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: _deleteUser,
                    icon: Icon(Icons.delete_outline,
                        size: 18.sp, color: Colors.white),
                    label: Text(
                      'Supprimer',
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 2,
                      shadowColor: Colors.redAccent.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
