import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class PixelWidget extends StatefulWidget {
  const PixelWidget({
    super.key,
    required this.pixelSize,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.index,
    required this.canvasTransform,
  });

  final TransformationController canvasTransform;
  final int pixelWidth;
  final int pixelHeight;
  final double pixelSize;
  final int index;

  @override
  State<PixelWidget> createState() => _PixelWidgetState();
}

class _PixelWidgetState extends State<PixelWidget> {
  Color color = Colors.transparent;
  Shape shape = Shape.square;
  int rotation = 0; // 0-3

  bool isHovered = false;
  bool isSelectingColor = false;

  late final OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayEntry = OverlayEntry(
        builder: (_) {
          return ValueListenableBuilder(
              valueListenable: widget.canvasTransform,
              builder: (context, transform, _) {
                return TapRegion(
                  onTapOutside: (_) {
                    setState(() => _overlayEntry.remove());
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      children: [
                        Transform.translate(
                          offset: MatrixUtils.transformPoint(
                            transform,
                            Offset(
                              widget.pixelSize *
                                      (widget.index % widget.pixelWidth) +
                                  widget.pixelSize,
                              widget.pixelSize *
                                  (widget.index ~/ widget.pixelWidth),
                            ),
                          ),
                          child: SizedBox(
                            width: 480,
                            height: 800,
                            child: SingleChildScrollView(
                              child: Card(
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                                      .copyWith(topLeft: Radius.zero),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CloseButton(
                                      onPressed: () {
                                        _overlayEntry.remove();
                                      },
                                    ),
                                    ColorPicker(
                                      color: color,
                                      showColorCode: true,
                                      pickersEnabled: const {
                                        ColorPickerType.both: true,
                                        ColorPickerType.primary: true,
                                        ColorPickerType.accent: true,
                                        ColorPickerType.wheel: true,
                                      },
                                      onColorChanged: (c) =>
                                          setState(() => color = c),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
      );

      _overlayEntry.addListener(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              isSelectingColor = _overlayEntry.mounted;
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: on mobile, use onTap to show/hide the controls
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: SizedBox.square(
        dimension: widget.pixelSize,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: color,
                  border: isSelectingColor
                      ? Border.all(
                          color: Colors.white,
                          width: 2,
                        )
                      : null,
                  borderRadius: shape == Shape.circle
                      ? BorderRadius.circular(widget.pixelSize)
                      : getBorderRadius(),
                ),
              ),
            ),
            if (!isHovered && color == Colors.transparent)
              Center(
                child: Container(
                  width: widget.pixelSize - 8,
                  height: widget.pixelSize - 8,
                  decoration: const BoxDecoration(
                      color: Colors.white30, shape: BoxShape.circle),
                ),
              )
            else if (isHovered && color == Colors.transparent)
              Center(
                child: IconButton(
                  mouseCursor: SystemMouseCursors.basic,
                  onPressed: () => setState(
                    () {
                      color = Colors.black;
                    },
                  ),
                  icon: const Icon(Icons.add),
                ),
              )
            else if (isHovered && color != Colors.transparent)
              Positioned.fill(
                top: 2,
                left: 2,
                right: 2,
                bottom: 2,
                child: GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  children: [
                    (
                      icon: const Icon(Icons.clear_outlined),
                      onPressed: () => setState(() {
                            color = Colors.transparent;
                            shape = Shape.square;
                            rotation = 0;
                          })
                    ),
                    (
                      icon: const Icon(Icons.rotate_right),
                      onPressed: () => setState(() {
                            rotation = (rotation + 1) % 4;
                          })
                    ),
                    (
                      icon: const Icon(Icons.water_drop_outlined),
                      onPressed: () {
                        if (isSelectingColor) {
                          _overlayEntry.remove();
                        } else {
                          Overlay.of(context).insert(
                            _overlayEntry,
                          );
                        }
                      },
                    ),
                    (
                      icon: switch (shape) {
                        Shape.square => buildRadiusIcon(),
                        Shape.borderRadius => buildDIcon(),
                        Shape.dShape => buildCircleIcon(),
                        Shape.circle => buildSquareIcon(),
                      },
                      onPressed: () => setState(() {
                            shape = switch (shape) {
                              Shape.square => Shape.borderRadius,
                              Shape.borderRadius => Shape.dShape,
                              Shape.dShape => Shape.circle,
                              Shape.circle => Shape.square,
                            };
                          })
                    ),
                  ]
                      .map((e) => IconButton(
                            mouseCursor: SystemMouseCursors.basic,
                            style: ButtonStyle(
                              padding: const MaterialStatePropertyAll(
                                  EdgeInsets.zero),
                              iconColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return color.computeLuminance() > .5
                                      ? Colors.black
                                      : Colors.white;
                                }
                                return color.computeLuminance() > .5
                                    ? Colors.black54
                                    : Colors.white70;
                              }),
                              overlayColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Colors.white.withOpacity(.25);
                                }
                                return Colors.transparent;
                              }),
                            ),
                            iconSize: widget.pixelSize / 4,
                            icon: e.icon,
                            onPressed: e.onPressed,
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSquareIcon() {
    return Builder(
        builder: (context) => Container(
              width: widget.pixelSize / 4,
              height: widget.pixelSize / 4,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: IconTheme.of(context).color!,
                  width: 1,
                ),
              ),
            ));
  }

  Widget buildDIcon() {
    return Builder(
        builder: (context) => Container(
              width: widget.pixelSize / 4,
              height: widget.pixelSize / 4,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: IconTheme.of(context).color!,
                  width: 1,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(widget.pixelSize),
                  topLeft: Radius.circular(widget.pixelSize),
                ),
              ),
            ));
  }

  Widget buildRadiusIcon() {
    return Builder(
        builder: (context) => Container(
              width: widget.pixelSize / 4,
              height: widget.pixelSize / 4,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: IconTheme.of(context).color!,
                  width: 1,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(widget.pixelSize),
                ),
              ),
            ));
  }

  Widget buildCircleIcon() {
    return Builder(
        builder: (context) => Container(
              width: widget.pixelSize / 4,
              height: widget.pixelSize / 4,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: IconTheme.of(context).color!,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(widget.pixelSize),
              ),
            ));
  }

  BorderRadius? getBorderRadius() {
    if (shape != Shape.dShape && shape != Shape.borderRadius) {
      return null;
    }
    late final BorderRadius borderRadius;
    final radius = widget.pixelSize;
    final dShapeRadius = shape == Shape.dShape ? widget.pixelSize : 0.0;
    switch (rotation) {
      case 0:
        borderRadius = BorderRadius.only(
          topLeft: Radius.circular(dShapeRadius),
          topRight: Radius.circular(radius),
        );
      case 1:
        borderRadius = BorderRadius.only(
          topRight: Radius.circular(dShapeRadius),
          bottomRight: Radius.circular(radius),
        );
      case 2:
        borderRadius = BorderRadius.only(
          bottomRight: Radius.circular(dShapeRadius),
          bottomLeft: Radius.circular(radius),
        );
      case 3:
        borderRadius = BorderRadius.only(
          bottomLeft: Radius.circular(dShapeRadius),
          topLeft: Radius.circular(radius),
        );
    }
    return borderRadius;
  }
}

enum Shape {
  circle,
  square,
  dShape,
  borderRadius,
}
