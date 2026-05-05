import 'package:flutter/material.dart';
import '../services/document_service.dart';

class DocumentProvider with ChangeNotifier {
  final DocumentService _documentService = DocumentService();
  
  List<dynamic> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _documents = await _documentService.getDocuments();
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
