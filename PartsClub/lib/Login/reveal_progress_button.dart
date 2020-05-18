
import 'package:flutter/material.dart';
import 'loginAnimation.dart';

class RevealProgressButton extends StatefulWidget {
  final String userID;
  final String pwd;

  RevealProgressButton({Key key,@required this.userID, this.pwd});

  @override
  State<StatefulWidget> createState() => _RevealProgressButtonState();
}

class _RevealProgressButtonState extends State<RevealProgressButton>
    with TickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;
  double _fraction = 0.0;

  @override
  Widget build(BuildContext context) {

    return CustomPaint(

      child: ProgressButton(callback: reveal,userID: widget.userID, pwd: widget.pwd,),
    );
  }

  @override
  void deactivate() {
    reset();
    super.deactivate();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  void reveal() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      })
      ..addStatusListener((AnimationStatus state) {

      });
    _controller.forward();
  }

  void reset() {
    _fraction = 0.0;
  }

}