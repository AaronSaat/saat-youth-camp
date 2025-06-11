import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;

  const CustomSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 6,
    this.divisions = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        inactiveTrackColor: AppColors.grey2,
        activeTrackColor: AppColors.brown1,
        // thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        thumbColor: AppColors.brown1,
        overlayColor: AppColors.brown1,
        overlayShape: SliderComponentShape.noOverlay,
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white, // Cokelat
          borderRadius: BorderRadius.circular(30),
        ),
        height: 60,
        child: Center(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            label: value.toStringAsFixed(0),
          ),
        ),
      ),
    );
  }
}

class _NumberedTickMarkShape extends SliderTickMarkShape {
  final double min;
  final double max;
  final int divisions;

  _NumberedTickMarkShape({
    required this.min,
    required this.max,
    required this.divisions,
  });

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    bool? isEnabled,
  }) {
    return const Size(32, 32);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    bool? isEnabled,
    bool? isDiscrete,
    required TextDirection textDirection,
  }) {
    final Canvas canvas = context.canvas;

    // Draw grey circle
    final Paint circlePaint =
        Paint()
          ..color = Colors.grey[300]!
          ..style = PaintingStyle.fill;
    const double radius = 14;
    canvas.drawCircle(center, radius, circlePaint);

    // Calculate the value for this tick
    int index =
        ((center.dx - 16) / ((parentBox.size.width - 32) / divisions)).round();
    double value = min + (index * ((max - min) / divisions));
    String label = value.toStringAsFixed(0);

    // Draw white number above the circle
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: textDirection,
    )..layout();

    final Offset textOffset =
        center - Offset(textPainter.width / 2, radius + textPainter.height + 2);
    textPainter.paint(canvas, textOffset);
  }
}

class CustomSliderThumbImage extends SliderComponentShape {
  final String imagePath;

  CustomSliderThumbImage({required this.imagePath});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final paint = Paint();

    // Use a synchronous image draw if the image is already available in the cache
    final ImageStream stream = AssetImage(
      imagePath,
    ).resolve(const ImageConfiguration());
    final ImageStreamListener listener = ImageStreamListener((
      ImageInfo info,
      bool _,
    ) {
      canvas.drawImage(info.image, center - const Offset(400, 100), paint);
    });

    stream.addListener(listener);
    // Remove the listener immediately to avoid memory leaks
    stream.removeListener(listener);
  }
}
