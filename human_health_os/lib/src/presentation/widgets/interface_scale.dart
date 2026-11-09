import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Scales the entire Navigator, including dialogs and controls. Reflow uses
/// logical layout units; very narrow windows can pan horizontally rather
/// than silently shrinking the person's chosen scale.
class InterfaceScale extends StatelessWidget {
  const InterfaceScale({super.key, required this.percent, required this.child});

  final int percent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final factor = percent / 100;
    final mq = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          math.max(320, constraints.maxWidth / factor),
          constraints.maxHeight / factor,
        );
        return Scrollable(
          key: const ValueKey('interface-horizontal-scroll'),
          axisDirection: AxisDirection.right,
          // Route-level semantics remain intact; omit only the extra outer
          // scrolling boundary. Keyboard focus can still reveal controls
          // through this viewport, and touch/trackpad users can pan it.
          excludeFromSemantics: true,
          viewportBuilder: (context, offset) => Viewport(
            axisDirection: AxisDirection.right,
            offset: offset,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  width: size.width * factor,
                  height: constraints.maxHeight,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox.fromSize(
                      size: size,
                      child: MediaQuery(
                        data: mq.copyWith(
                          size: size,
                          devicePixelRatio: mq.devicePixelRatio * factor,
                          padding: mq.padding / factor,
                          viewPadding: mq.viewPadding / factor,
                          viewInsets: mq.viewInsets / factor,
                          systemGestureInsets: mq.systemGestureInsets / factor,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
