import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class WebViewHelper {
  static void registerView(String viewType, String url) {
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }
}
