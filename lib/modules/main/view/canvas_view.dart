import 'package:flutter/material.dart';
import 'package:pixartmaker/modules/main/view/widgets/pixel_widget.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({super.key, required this.size});

  final Size size;

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  late final TransformationController transformationController;

  final pixelWidth = 8;
  final pixelHeight = 8;
  final pixelSize = 48.0;

  double get width => pixelWidth * pixelSize;
  double get height => pixelHeight * pixelSize;
  int get itemCount => pixelWidth * pixelHeight;

  @override
  void initState() {
    super.initState();
    transformationController = TransformationController(
      Matrix4.identity()
        ..translate(
          widget.size.width / 2 - width / 2,
          widget.size.height / 2 - height / 2,
        ),
    );
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: InteractiveViewer.builder(
            transformationController: transformationController,
            minScale: .01,
            maxScale: 100,
            clipBehavior: Clip.none,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            builder: (context, quad) {
              return Container(
                clipBehavior: Clip.hardEdge,
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(
                    scrollbars: false,
                  ),
                  child: Stack(
                    children: [
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: itemCount,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: pixelWidth),
                        itemBuilder: (_, index) {
                          return PixelWidget(
                            key: Key(index
                                .toString()), // Add key so the state inside isn't gone when setState is called
                            pixelWidth: pixelWidth,
                            pixelHeight: pixelHeight,
                            index: index,
                            pixelSize: pixelSize,
                            canvasTransform: transformationController,
                          );
                        },
                      ),
                      IgnorePointer(
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: itemCount,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: pixelWidth),
                          itemBuilder: (_, index) {
                            return Container(
                              width: pixelSize,
                              height: pixelSize,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: .5,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
