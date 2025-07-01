import 'package:flutter/material.dart';

class CustomCountUp extends StatefulWidget {
  final int target;
  final Duration duration;
  final TextStyle? style;

  const CustomCountUp({
    Key? key,
    this.target = 100,
    this.duration = const Duration(seconds: 2),
    this.style,
  }) : super(key: key);

  @override
  State<CustomCountUp> createState() => _CustomCountUpState();
}

class _CustomCountUpState extends State<CustomCountUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = IntTween(begin: 0, end: widget.target).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_animation.value}',
      style:
          widget.style ??
          const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }
}
