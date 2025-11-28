import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AnimatedIconTextButton extends StatefulWidget {
  const AnimatedIconTextButton({
    super.key,
    required this.name,
    required this.onTap,
    required this.icon,
  });

  final String name;
  final Function onTap;
  final IconData icon;

  @override
  State<AnimatedIconTextButton> createState() => _AnimatedIconTextButtonState();
}

class _AnimatedIconTextButtonState extends State<AnimatedIconTextButton> {
  bool isAdded = false; // This will toggle between added and not added states

  void _handleTap() {
    setState(() {
      isAdded = !isAdded; // Toggle the isAdded state when the button is pressed
    });

    // Call the onTap callback
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap, // Handle the tap gesture
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(
                begin: 0.0,
                end: isAdded ? 1.0 : 0.0), // Control the rotation (0.0 to 1.0)
            duration:
                const Duration(milliseconds: 300), // Duration of the rotation
            builder: (context, rotation, child) {
              return Transform.rotate(
                angle: rotation *
                    2 *
                    3.1416, // 360 degrees rotation based on the tween progress
                child: Icon(
                  isAdded
                      ? Icons.check
                      : widget.icon, // Change icon on tap (check or add)
                  color: isAdded
                      ? Colors.green
                      : Colors.white, // Green when added, blue when not
                  size: 20.sp, // Set size with Sizer
                ),
              );
            },
          ),
          Text(
            widget.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp, // Set font size with Sizer
                ),
          ),
        ],
      ),
    );
  }
}
