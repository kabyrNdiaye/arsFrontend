import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../utils/font_helper.dart';
import '../../services/api_service.dart';

import 'web_view_stub.dart' if (dart.library.html) 'web_view_web.dart';
import 'package:url_launcher/url_launcher.dart';

class FilePreviewScreen extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final String fileType;
  final String? authToken;

  const FilePreviewScreen({
    Key? key,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    this.authToken,
  }) : super(key: key);

  @override
  State<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  static const Color _primaryBlue = Color(0xFF0059AB);
  late final String _viewType;

  bool _isLoading = true;
  String? _errorMessage;
  String? _localPdfPath;   // chemin local du PDF téléchargé
  Uint8List? _imageBytes;  // bytes de l'image

  bool _isPdfResource = false;
  bool _isImageResource = false;
  bool _isWordResource = false;

  bool get _isPdf =>
      widget.fileType.toLowerCase() == 'pdf' ||
      widget.fileUrl.toLowerCase().contains('.pdf') ||
      _isPdfResource;

  bool get _isImage {
    final u = widget.fileUrl.toLowerCase();
    return u.endsWith('.jpg') || u.endsWith('.jpeg') ||
        u.endsWith('.png') || u.endsWith('.webp') || u.endsWith('.avif') ||
        u.contains('.jpg?') || u.contains('.png?') ||
        _isImageResource;
  }

  bool get _isWord =>
      widget.fileType.toLowerCase().contains('word') ||
      widget.fileUrl.toLowerCase().contains('.doc') ||
      _isWordResource;

  String? get _token => widget.authToken ?? ApiService().token;

  Map<String, String> get _authHeaders => {
        if (_token != null) 'Authorization': 'Bearer $_token',
        'Accept': '*/*',
      };

  @override
  void initState() {
    super.initState();
    _viewType = 'file-preview-${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      _loadWeb();
    } else {
      _loadMobile();
    }
  }

  // ─── Web (désactivé pour APK mobile) ──────────────────────────────────────
  Future<void> _loadWeb() async {
    try {
      WebViewHelper.registerView(_viewType, widget.fileUrl);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() { _errorMessage = 'Erreur Web: $e'; _isLoading = false; });
    }
  }

  // ─── Mobile ─────────────────────────────────────────────────────────────
  Future<void> _loadMobile() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final response = await http.get(Uri.parse(widget.fileUrl), headers: _authHeaders);
      if (response.statusCode != 200) {
        if (mounted) setState(() { _errorMessage = 'Erreur ${response.statusCode}\n${widget.fileUrl}'; _isLoading = false; });
        return;
      }

      // Détection du type par les headers si possible
      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      _isPdfResource = contentType.contains('pdf');
      _isImageResource = contentType.contains('image');
      _isWordResource = contentType.contains('msword') || contentType.contains('officedocument');

      if (_isPdf) {
        // Sauvegarder en fichier temporaire pour flutter_pdfview
        final dir = await getTemporaryDirectory();
        final rawName = widget.fileUrl.split('/').last.split('?').first;
        final fileName = rawName.contains('.') ? rawName : '${widget.fileName}.pdf';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) setState(() { _localPdfPath = file.path; _isLoading = false; });
      } else if (_isImage) {
        if (mounted) setState(() { _imageBytes = response.bodyBytes; _isLoading = false; });
      } else {
        // Autre ou inconnu -> on tente en image si on a des bytes
        if (mounted) setState(() { _imageBytes = response.bodyBytes; _isImageResource = true; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = '$e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.h),
        child: Container(
          color: _primaryBlue,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(top: 40.h, bottom: 8.h, left: 4.w, right: 4.w),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.white),
                    tooltip: 'Ouvrir dans un nouvel onglet',
                    onPressed: () async {
                      await launchUrl(Uri.parse(widget.fileUrl), mode: LaunchMode.externalApplication);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Web
    if (kIsWeb) {
      if (_isLoading) return const Center(child: CircularProgressIndicator());
      if (_errorMessage != null) return _buildError();

      // Sur Web, l'iframe (HtmlElementView) est capricieuse. 
      // Si c'est une image, on préfère NetworkImage.
      if (_isImage) {
        return PhotoView(
          imageProvider: NetworkImage(widget.fileUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      }

      return SizedBox.expand(child: HtmlElementView(viewType: _viewType));
    }

    // Mobile — chargement
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text('Chargement...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (_errorMessage != null) return _buildError();

    // Mobile — PDF sans toolbar (flutter_pdfview)
    if (_isPdf && _localPdfPath != null) {
      return PDFView(
        filePath: _localPdfPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: false,
        fitPolicy: FitPolicy.BOTH,
        onError: (error) {
          if (mounted) setState(() => _errorMessage = error.toString());
        },
      );
    }

    // Mobile — Image
    if (_imageBytes != null) {
      return PhotoView(
        imageProvider: MemoryImage(_imageBytes!),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16.h),
            Text(
              _errorMessage ?? 'Erreur inconnue',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 13.sp),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: kIsWeb ? _loadWeb : _loadMobile,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}
