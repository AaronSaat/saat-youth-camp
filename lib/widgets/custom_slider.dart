import 'package:flutter/material.dart';

class CustomStepperSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;

  const CustomStepperSlider({
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
        inactiveTrackColor: Colors.grey,
        activeTrackColor: Colors.white,
        thumbShape: CustomSliderThumbImage(
          imagePath: 'assets/buttons/icon_slider.png',
        ),
        overlayColor: Colors.transparent,
        overlayShape: SliderComponentShape.noOverlay,
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF7B3F00), // Cokelat
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

class CustomSliderThumbImage extends SliderComponentShape {
  final String imagePath;

  CustomSliderThumbImage({required this.imagePath});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(40, 40);

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
      canvas.drawImage(info.image, center - const Offset(100, 100), paint);
    });

    stream.addListener(listener);
    // Remove the listener immediately to avoid memory leaks
    stream.removeListener(listener);
  }
}
