import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _AnimatedImage());
  }
}

class _AnimatedImage extends StatefulWidget {
  const _AnimatedImage({Key? key}) : super(key: key);

  @override
  State<_AnimatedImage> createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<_AnimatedImage> {
  bool _isHalf = false;

  void _onTap() {
    setState(() {
      _isHalf = !_isHalf;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top:
                _isHalf
                    ? -screenHeight * 0.5
                    : 0, // naik hingga hanya 1/4 gambar yang terlihat
            left: 0,
            right: 0,
            height: screenHeight,
            child: GestureDetector(
              onTap: _onTap,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/komitmen.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _isHalf ? screenHeight * 0.5 + 40 : 40,
            child: Center(
              child: ElevatedButton(
                onPressed: _onTap,
                child: Text(
                  _isHalf ? 'Tampilkan Penuh' : 'Tampilkan Seperempat',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
