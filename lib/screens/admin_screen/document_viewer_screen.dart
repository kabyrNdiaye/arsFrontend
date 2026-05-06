import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../utils/font_helper.dart';
import '../../services/api_service.dart';

// Web uniquement
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

class DocumentViewerScreen extends StatefulWidget {
  final String title;
  final String url;
  final Color? primaryColor;

  const DocumentViewerScreen({
    Key? key,
    required this.title,
    required this.url,
    this.primaryColor,
  }) : super(key: key);

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  static const Color _primaryBlue = Color(0xFF0059AB);
  late final String _viewType;

  bool _isLoading = true;
  String? _errorMessage;
  String? _localPdfPath;
  Uint8List? _imageBytes;

  bool get _isPdf => widget.url.toLowerCase().contains('.pdf');
  bool get _isWord =>
      widget.url.toLowerCase().contains('.doc') ||
      widget.url.toLowerCase().contains('.docx');
  bool get _isImage {
    final u = widget.url.toLowerCase();
    return u.endsWith('.jpg') || u.endsWith('.jpeg') ||
        u.endsWith('.png') || u.endsWith('.webp') || u.endsWith('.avif');
  }

  Map<String, String> get _authHeaders {
    final token = ApiService().token;
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };
  }

  @override
  void initState() {
    super.initState();
    _viewType = 'doc-viewer-${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      _loadWeb();
    } else {
      _loadMobile();
    }
  }

  // ─── Web ────────────────────────────────────────────────────────────────
  Future<void> _loadWeb() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(widget.url), headers: _authHeaders);
      if (response.statusCode == 200) {
        final mimeType = _isPdf ? 'application/pdf' : 'image/jpeg';
        final blob = html.Blob([response.bodyBytes], mimeType);
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        // ignore: undefined_prefixed_name
        ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
          if (_isImage) {
            return html.ImageElement()
              ..src = blobUrl
              ..style.width = '100%'
              ..style.height = '100%'
              ..style.objectFit = 'contain'
              ..style.backgroundColor = 'white';
          } else {
            // Ajouter #toolbar=0 pour masquer la toolbar Chrome PDF
            final urlWithNoToolbar = '$blobUrl#toolbar=0&navpanes=0&scrollbar=0';
            return html.IFrameElement()
              ..src = urlWithNoToolbar
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%'
              ..style.backgroundColor = 'white';
          }
        });
        if (mounted) setState(() => _isLoading = false);
      } else {
        if (mounted) setState(() { _errorMessage = 'Erreur ${response.statusCode}\n${widget.url}'; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = '$e'; _isLoading = false; });
    }
  }

  // ─── Mobile ─────────────────────────────────────────────────────────────
  Future<void> _loadMobile() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final response = await http.get(Uri.parse(widget.url), headers: _authHeaders);
      if (response.statusCode != 200) {
        if (mounted) setState(() { _errorMessage = 'Erreur ${response.statusCode}\n${widget.url}'; _isLoading = false; });
        return;
      }

      if (_isPdf) {
        final dir = await getTemporaryDirectory();
        final rawName = widget.url.split('/').last.split('?').first;
        final fileName = rawName.isNotEmpty ? rawName : '${widget.title}.pdf';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) setState(() { _localPdfPath = file.path; _isLoading = false; });
      } else {
        if (mounted) setState(() { _imageBytes = response.bodyBytes; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = '$e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: getSourceSerifProStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: widget.primaryColor ?? _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // Aucune action = aucune icône
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Web
    if (kIsWeb) {
      if (_isLoading) return const Center(child: CircularProgressIndicator());
      if (_errorMessage != null) return _buildError();
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

    // Mobile — Word
    if (_isWord) return _buildWordView();

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
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: kIsWeb ? _loadWeb : _loadMobile,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor ?? _primaryBlue),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () async {
                await launchUrl(Uri.parse(widget.url),
                    mode: LaunchMode.externalApplication);
              },
              child: const Text('Ouvrir dans le navigateur'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, color: Colors.blue[300], size: 64.sp),
          SizedBox(height: 20.h),
          Text('Fichier Word', style: getSourceSerifProStyle(fontSize: 16.sp)),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: () async {
              await launchUrl(Uri.parse(widget.url),
                  mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.download),
            label: const Text('Ouvrir / Télécharger'),
            style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor ?? _primaryBlue),
          ),

        ],
      ),
    );
  }
}
