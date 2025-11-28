import 'package:flutter/widgets.dart';

class ScrollHelper {
  /// Safely apply scroll offset with bounds checking
  static double safeScrollOffset(double offset) {
    if (offset.isNaN || offset.isInfinite) {
      return 0.0;
    }
    return offset.clamp(-double.maxFinite / 2, double.maxFinite / 2);
  }

  /// Safely scroll to position with validation
  static void safeScrollTo(ScrollController controller, double position) {
    if (controller.hasClients && position.isFinite && !position.isNaN) {
      final safePosition = position.clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      );

      try {
        controller.animateTo(
          safePosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (e) {
        debugPrint('Scroll animation failed: $e');
      }
    }
  }

  /// Create a scroll controller with error handling
  static ScrollController createSafeScrollController({
    double initialScrollOffset = 0.0,
    String? debugLabel,
  }) {
    return ScrollController(
      initialScrollOffset: safeScrollOffset(initialScrollOffset),
      debugLabel: debugLabel,
    );
  }
}

/// Extension for safe scrolling operations
extension SafeScrollController on ScrollController {
  void safeAnimateTo(double offset) {
    ScrollHelper.safeScrollTo(this, offset);
  }

  void safeJumpTo(double offset) {
    if (hasClients && offset.isFinite && !offset.isNaN) {
      final safePosition = offset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      jumpTo(safePosition);
    }
  }
}