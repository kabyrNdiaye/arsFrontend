import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/feedback_service.dart';
import '../../utils/font_helper.dart';

class AdminFeedbacksScreen extends StatefulWidget {
  const AdminFeedbacksScreen({Key? key}) : super(key: key);

  @override
  State<AdminFeedbacksScreen> createState() => _AdminFeedbacksScreenState();
}

class _AdminFeedbacksScreenState extends State<AdminFeedbacksScreen> {
  final Color _primaryPurple = const Color(0xFF7C39D3);
  final FeedbackService _feedbackService = FeedbackService();
  
  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  Future<void> _fetchFeedbacks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final feedbacks = await _feedbackService.getFeedbacks();
      setState(() {
        _feedbacks = feedbacks;
        _isLoading = false;
      });
      print("AdminFeedbacksScreen: Loaded ${feedbacks.length} feedbacks");
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors du chargement des retours";
        _isLoading = false;
      });
      print("AdminFeedbacksScreen Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: _primaryPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20.h,
                      left: 12.w,
                      right: 12.w,
                    ),
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Gestion des Retours',
                          textAlign: TextAlign.center,
                          style: getSourceSerifProStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _fetchFeedbacks,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white70, size: 20),
                        SizedBox(width: 8.w),
                        Text(
                          '${_feedbacks.length} retour${_feedbacks.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Contenu
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                  : _feedbacks.isEmpty
                    ? Center(child: Text("Aucun retour", style: TextStyle(color: Colors.grey[600])))
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _feedbacks.length,
                        itemBuilder: (context, index) {
                          final feedback = _feedbacks[index];
                          return _buildFeedbackCard(feedback);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    final rating = feedback['rating'] ?? 0;
    final comment = feedback['comment'] ?? '';
    final createdAt = feedback['created_at'] ?? 'N/A';
    final userName = feedback['user_name'] ?? feedback['user_id']?.toString() ?? 'Anonyme';
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Utilisateur et date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                createdAt.toString().split(' ')[0],
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Note
          Row(
            children: [
              ...List.generate(5, (i) {
                return Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: i < rating ? Colors.amber : Colors.grey[400],
                  size: 16.sp,
                );
              }),
              SizedBox(width: 8.w),
              Text(
                '$rating/5',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              comment,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black87,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
