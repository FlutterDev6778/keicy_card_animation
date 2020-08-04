library keicy_card_animation;

import 'dart:async';

import 'package:flutter/material.dart';

class KeicyCardAnimation extends StatefulWidget {
  final Duration delay;
  final List<dynamic> childrenData;
  final double width;
  final double height;
  final bool isRepeated;

  KeicyCardAnimation({
    @required this.width,
    @required this.height,
    @required this.childrenData,
    this.isRepeated = true,
    this.delay = const Duration(milliseconds: 0),
  });

  @override
  _KeicyCardAnimationState createState() => _KeicyCardAnimationState();
}

class _KeicyCardAnimationState extends State<KeicyCardAnimation> with TickerProviderStateMixin {
  List<AnimationController> _controllerList = [];
  List<Timer> _timerList = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.childrenData.length; i++) {
      _controllerList.add(
        AnimationController(duration: widget.childrenData[i]["duration"], vsync: this),
      );
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < _controllerList.length; i++) {
      _controllerList[i].dispose();
      try {
        if (_timerList[i] != null) _timerList[i].cancel();
      } catch (e) {}
    }
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration totalDuration = Duration(seconds: 0);
    List<Widget> chilrenWidgetList = [];

    for (var i = 0; i < widget.childrenData.length; i++) {
      if (widget.isRepeated && i == widget.childrenData.length - 1) {
        Duration delay = widget.childrenData[i]["delay"];
        Duration duration = widget.childrenData[i]["duration"];
        totalDuration = Duration(milliseconds: (delay.inMilliseconds + duration.inMilliseconds));
      }
      chilrenWidgetList.add(
        StaggerAnimation(
          controller: _controllerList[i].view,
          childData: widget.childrenData[i],
          width: widget.width,
          height: widget.height,
        ),
      );
    }

    for (var i = 0; i < widget.childrenData.length; i++) {
      Future.delayed(widget.childrenData[i]["delay"], () {
        try {
          _controllerList[i].forward();
          _controllerList[i].addListener(() {
            if (_controllerList[i].isCompleted) _controllerList[i].reset();
          });
        } catch (e) {}
      });
    }
    if (widget.isRepeated) {
      _timerList.add(Timer.periodic(totalDuration, (timer) {
        for (var i = 0; i < widget.childrenData.length; i++) {
          Future.delayed(widget.childrenData[i]["delay"], () {
            try {
              _controllerList[i].forward();
            } catch (e) {}
          });
        }
      }));
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
          // border: Border.all(width: 1),
          ),
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: OverflowBox(
          maxWidth: widget.width,
          maxHeight: widget.height,
          child: Stack(
            children: chilrenWidgetList,
          ),
        ),
      ),
    );
  }
}

enum AnimationDirection { Up, Down, Left, Right, None }

class StaggerAnimation extends StatelessWidget {
  StaggerAnimation({Key key, this.controller, this.childData, this.width, this.height}) : super(key: key);

  final Animation<double> controller;
  final Map<String, dynamic> childData;
  final double width;
  final double height;
  Animation<double> appearOpacity;
  Animation<double> appearOffsetX;
  Animation<double> appearOffsetY;

  Animation<double> disappearOpacity;
  Animation<double> disappearOffsetX;
  Animation<double> disappearOffsetY;

  Widget _buildAnimation(BuildContext context, Widget child) {
    appearOpacity = Tween<double>(
      begin: (childData["appear"]["opacity"] != null && !childData["appear"]["opacity"]) ? 1.0 : 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.0,
          childData["appear"] != null ? childData["appear"]["duration"] ?? 0.2 : 0,
          curve: Curves.ease,
        ),
      ),
    );

    disappearOpacity = Tween<double>(
      begin: 1,
      end: (childData["disappear"]["opacity"] != null && !childData["disappear"]["opacity"]) ? 1.0 : 0.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          1 - (childData["disappear"] != null ? childData["disappear"]["duration"] ?? 0.2 : 0),
          1,
          curve: Curves.ease,
        ),
      ),
    );

    appearOffsetX = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Interval(0.0, 0.0, curve: Curves.ease)),
    );

    appearOffsetY = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Interval(0.0, 0.0, curve: Curves.ease)),
    );

    disappearOffsetX = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Interval(0.0, 0.0, curve: Curves.ease)),
    );

    disappearOffsetY = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Interval(0.0, 0.0, curve: Curves.ease)),
    );

    switch (childData["appear"]["type"]) {
      case AnimationDirection.Left:
        appearOffsetX = Tween<double>(begin: (childData["appear"]["value"] ?? width) * -1.0, end: 0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, childData["appear"] != null ? childData["appear"]["duration"] ?? 0.2 : 0.2, curve: Curves.ease),
          ),
        );
        break;
      case AnimationDirection.Right:
        appearOffsetX = Tween<double>(begin: (childData["appear"]["value"] ?? width) * 1.0, end: 0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, childData["appear"] != null ? childData["appear"]["duration"] ?? 0.2 : 0.2, curve: Curves.ease),
          ),
        );
        break;
      case AnimationDirection.Up:
        appearOffsetY = Tween<double>(begin: (childData["appear"]["value"] ?? height) * -1.0, end: 0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, childData["appear"] != null ? childData["appear"]["duration"] ?? 0.2 : 0.2, curve: Curves.ease),
          ),
        );
        break;
      case AnimationDirection.Down:
        appearOffsetY = Tween<double>(begin: (childData["appear"]["value"] ?? height) * 1.0, end: 0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, childData["appear"] != null ? childData["appear"]["duration"] ?? 0.2 : 0.2, curve: Curves.ease),
          ),
        );
        break;
      default:
    }

    switch (childData["disappear"]["type"]) {
      case AnimationDirection.Left:
        disappearOffsetX = Tween<double>(begin: 0, end: (childData["disappear"]["value"] ?? width) * -1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              1 - (childData["disappear"] != null ? childData["disappear"]["duration"] ?? 0.2 : 0.2),
              1,
              curve: childData["disappear"]["curve"] ?? Curves.ease,
            ),
          ),
        );
        break;
      case AnimationDirection.Right:
        disappearOffsetX = Tween<double>(begin: 0, end: (childData["disappear"]["value"] ?? width) * 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              1 - (childData["disappear"] != null ? childData["disappear"]["duration"] ?? 0.2 : 0.2),
              1,
              curve: childData["disappear"]["curve"] ?? Curves.ease,
            ),
          ),
        );
        break;
      case AnimationDirection.Up:
        disappearOffsetY = Tween<double>(begin: 0, end: (childData["disappear"]["value"] ?? height) * -1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              1 - (childData["disappear"] != null ? childData["disappear"]["duration"] ?? 0.2 : 0.2),
              1,
              curve: childData["disappear"]["curve"] ?? Curves.ease,
            ),
          ),
        );
        break;
      case AnimationDirection.Down:
        disappearOffsetY = Tween<double>(begin: 0, end: (childData["disappear"]["value"] ?? height) * 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              1 - (childData["disappear"] != null ? childData["disappear"]["duration"] ?? 0.2 : 0.2),
              1,
              curve: childData["disappear"]["curve"] ?? Curves.ease,
            ),
          ),
        );
        break;
      default:
    }

    return Center(
      child: Opacity(
        opacity: disappearOpacity.value,
        child: Transform.translate(
          offset: Offset(disappearOffsetX.value, disappearOffsetY.value),
          child: Opacity(
            opacity: appearOpacity.value,
            child: Transform.translate(
              offset: Offset(appearOffsetX.value, appearOffsetY.value),
              child: childData["widget"],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }
}
