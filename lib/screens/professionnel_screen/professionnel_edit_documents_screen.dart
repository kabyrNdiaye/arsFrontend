import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/font_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/document_service.dart';

class ProfessionnelEditDocumentsScreen extends StatefulWidget {
  const ProfessionnelEditDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionnelEditDocumentsScreen> createState() =>
      _ProfessionnelEditDocumentsScreenState();
}

class _ProfessionnelEditDocumentsScreenState
    extends State<ProfessionnelEditDocumentsScreen> {
  static const Color _primaryBlue = Color(0xFF0059AB);

  final DocumentService _docService = DocumentService();

  bool _isLoadingDocs = true;
  List<DocumentItem> _documents = [];
  String? _loadError;

  // Fichiers sélectionnés pour remplacement : docId → PlatformFile
  final Map<int, PlatformFile> _pendingFiles = {};

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoadingDocs = true;
      _loadError = null;
    });
    try {
      final docs = await _docService.getMyDocuments();
      if (mounted) setState(() => _documents = docs);
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingDocs = false);
    }
  }

  Future<void> _pickFile(int docId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: kIsWeb,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _pendingFiles[docId] = result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de sélectionner le fichier.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() => _isLoadingDocs = true);

        await _docService.addDocument(
          nom: file.name, // Nom automatique selon le fichier
          filePath: kIsWeb ? null : file.path,
          fileBytes: kIsWeb ? file.bytes : null,
          fileName: file.name,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document ajouté avec succès ✓'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          _loadDocuments();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDocs = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDocument(int docId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Voulez-vous vraiment supprimer "$name" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULER')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoadingDocs = true);
    try {
      await _docService.deleteDocument(docId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document supprimé')),
        );
        _loadDocuments();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDocs = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveAll() async {
    if (_pendingFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un document à remplacer.'),
        ),
      );
      return;
    }

    setState(() => _isLoadingDocs = true);

    int success = 0;
    final List<String> errors = [];

    for (final entry in _pendingFiles.entries) {
      final int docId = entry.key;
      final PlatformFile file = entry.value;

      try {
        await _docService.updateDocument(
          id: docId,
          filePath: kIsWeb ? null : file.path,
          fileBytes: kIsWeb ? file.bytes : null,
          fileName: file.name,
        );
        success++;
      } catch (e) {
        errors.add(e.toString());
      }
    }

    if (!mounted) return;

    // Recharger la liste et le profil
    await _loadDocuments();
    await Provider.of<AuthProvider>(context, listen: false).loadProfile();

    setState(() => _pendingFiles.clear());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errors.isEmpty
            ? '$success document(s) mis à jour avec succès ✓'
            : 'Certains documents n\'ont pas pu être mis à jour. Vérifiez votre connexion et réessayez.'),
        backgroundColor: errors.isEmpty ? const Color(0xFF4CAF50) : Colors.orange,
      ),
    );

    if (errors.isEmpty) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: AppBar(
          backgroundColor: _primaryBlue,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 80.h,
          leading: Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Text(
              'Modifier mes documents',
              style: getSourceSerifProStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadDocuments,
                tooltip: 'Actualiser',
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(lang),
      bottomNavigationBar: _pendingFiles.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: ElevatedButton(
                  onPressed: _isLoadingDocs ? null : _saveAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoadingDocs
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Enregistrer ${_pendingFiles.length} modification(s)',
                          style: getSourceSerifProStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(LanguageProvider lang) {
    if (_isLoadingDocs && _documents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16.h),
            Text(_loadError!, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _loadDocuments,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
            ),
          ],
        ),
      );
    }

    if (_documents.isEmpty) {
      return Center(
        child: Text(
          'Aucun document trouvé',
          style: getSourceSerifProStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Info
        Container(
          padding: EdgeInsets.all(12.w),
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _primaryBlue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: _primaryBlue, size: 20),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Cliquez sur un document pour le remplacer.',
                  style: getSourceSerifProStyle(
                      fontSize: 12.sp, color: _primaryBlue),
                ),
              ),
            ],
          ),
        ),

        // Liste des documents
        ..._documents.map((doc) => _buildDocTile(doc)),

        SizedBox(height: 20.h),

        // Bouton Ajouter
        ElevatedButton.icon(
          onPressed: _isLoadingDocs ? null : _addDocument,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Ajouter un document'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _primaryBlue,
            side: const BorderSide(color: _primaryBlue),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildDocTile(DocumentItem doc) {
    final pending = _pendingFiles[doc.id];
    final hasPending = pending != null;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPending ? _primaryBlue : Colors.grey[200]!,
          width: hasPending ? 2 : 1,
        ),
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
          // Titre + icône
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  doc.isFixed ? Icons.verified_user_outlined : Icons.description_outlined,
                  color: _primaryBlue,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.displayName,
                      style: getSourceSerifProStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (doc.isFixed)
                      Text(
                        'Document obligatoire',
                        style: getSourceSerifProStyle(fontSize: 11.sp, color: Colors.orange[800]),
                      ),
                  ],
                ),
              ),
              if (!doc.isFixed)
                IconButton(
                  onPressed: () => _deleteDocument(doc.id, doc.displayName),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),

          // Nouveau fichier sélectionné
          if (hasPending) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.upload_file, color: _primaryBlue, size: 16),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      pending.name,
                      style: getSourceSerifProStyle(
                          fontSize: 12.sp, color: _primaryBlue),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _pendingFiles.remove(doc.id)),
                    child:
                        const Icon(Icons.close, color: Colors.red, size: 16),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 8.h),

          // Bouton remplacer
          GestureDetector(
            onTap: () => _pickFile(doc.id),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 9.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primaryBlue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, color: _primaryBlue, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    hasPending ? 'Changer le fichier' : 'Remplacer',
                    style: getSourceSerifProStyle(
                      fontSize: 13.sp,
                      color: _primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
