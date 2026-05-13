import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class WebViewHelper {
  static void registerView(String viewType, String url) {
    // Ajouter #toolbar=0&navpanes=0 pour supprimer la toolbar PDF du navigateur
    String cleanUrl = url;
    if (url.toLowerCase().contains('.pdf') || url.toLowerCase().contains('pdf')) {
      final separator = url.contains('?') ? '&' : '#';
      cleanUrl = '$url${separator}toolbar=0&navpanes=0&scrollbar=0';
    }

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return html.IFrameElement()
        ..src = cleanUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }
}
