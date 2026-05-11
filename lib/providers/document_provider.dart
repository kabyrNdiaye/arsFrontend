import 'package:flutter/material.dart';
import '../services/document_service.dart';

class DocumentProvider with ChangeNotifier {
  final DocumentService _documentService = DocumentService();
  
  List<DocumentItem> _apiDocuments = [];
  List<dynamic> _documents = []; // Pour compatibilité
  bool _isLoading = false;
  String? _error;

  List<DocumentItem> get apiDocuments => _apiDocuments;
  List<dynamic> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _apiDocuments = await _documentService.getMyDocuments();
      // On garde _documents synchro pour la compatibilité (si des widgets utilisent documents)
      _documents = _apiDocuments.map((d) => {
        'id': d.id,
        'nom': d.nom,
        'url': d.url,
        'statut': d.statut
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument(String? filePath, String type, {List<int>? fileBytes, String? fileName}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Pour l'upload simple (legacy), on utilise l'ancienne méthode du service mais on rafraîchit avec la nouvelle
      await _documentService.uploadDocument(
        filePath,
        type,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      await fetchDocuments();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
