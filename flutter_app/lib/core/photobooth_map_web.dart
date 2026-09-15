import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class PhotoboothMap extends StatefulWidget {
  const PhotoboothMap({super.key});
  @override
  State<PhotoboothMap> createState() => _PhotoboothMapState();
}

class _PhotoboothMapState extends State<PhotoboothMap> {
  static var _count = 0;
  late final String _viewType = 'glass-frame-map-${_count++}';
  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final frame = web.HTMLIFrameElement()
        ..src =
            'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3614.770598337909!2d121.54528847610625!3d25.041858037973647!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3442ab0026b9fb19%3A0xdc487e62488145b3!2z576O5ZyW5aKD55WMIHwgR2xhc3MmRnJhbWUg5aSi5oOz5a-m6amX5a6k!5e0!3m2!1sen!2stw!4v1789459831692!5m2!1sen!2stw'
        ..style.border = '0'
        ..allowFullscreen = true
        ..loading = 'lazy'
        ..referrerPolicy = 'strict-origin-when-cross-origin';
      return frame;
    });
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
