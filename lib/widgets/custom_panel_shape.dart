import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CustomPanelShape extends StatefulWidget {
  final double width;
  final double height;
  final Color? color;
  final ImageProvider? imageProvider;

  const CustomPanelShape({Key? key, required this.width, required this.height, this.color, this.imageProvider})
    : super(key: key);

  @override
  State<CustomPanelShape> createState() => _CustomPanelShapeState();
}

class _CustomPanelShapeState extends State<CustomPanelShape> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.imageProvider != null) {
      final completer = Completer<ui.Image>();
      final stream = widget.imageProvider!.resolve(const ImageConfiguration());
      final listener = ImageStreamListener((ImageInfo info, _) {
        completer.complete(info.image);
      });
      stream.addListener(listener);
      final image = await completer.future;
      setState(() {
        _image = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: _PanelShapePainter(color: widget.color, image: _image),
    );
  }
}

class _PanelShapePainter extends CustomPainter {
  final Color? color;
  final ui.Image? image;

  _PanelShapePainter({this.color, this.image});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final radius = 40.0;

    // Path dengan cekungan di bawah kanan
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    path.lineTo(size.width, size.height - radius - 30);
    path.quadraticBezierTo(size.width, size.height - 30, size.width - radius, size.height - 30);

    // Pindah cekungan ke kiri bawah
    // Jadi dari kanan bawah pindah ke kiri bawah
    path.lineTo(size.width * 0.55, size.height - 30);

    // cekungan kiri bawah
    path.quadraticBezierTo(
      size.width * 0.50,
      size.height - 30, // titik kontrol kiri atas cekungan
      size.width * 0.48,
      size.height - 10, // titik akhir cekungan (ke atas)
    );
    path.quadraticBezierTo(
      size.width * 0.46,
      size.height, // titik kontrol cekungan bawah
      size.width * 0.38,
      size.height, // titik akhir cekungan di bawah
    );

    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    if (image != null) {
      canvas.clipPath(path);
      final paint = Paint();
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    } else {
      final paint = Paint()..color = color ?? Colors.brown;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
