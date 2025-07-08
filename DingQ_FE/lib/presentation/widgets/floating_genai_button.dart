import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Circular Generative AI button with animated text field on hover
class FloatingGenAIButton extends StatefulWidget {
  const FloatingGenAIButton({super.key});

  @override
  State<FloatingGenAIButton> createState() => _FloatingGenAIButtonState();
}

class _FloatingGenAIButtonState extends State<FloatingGenAIButton> {
  bool _hovering = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onHover(bool hover) {
    setState(() {
      _hovering = hover;
    });
    if (hover) {
      // Slight delay to allow animation before focusing
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted && _hovering) {
          _focusNode.requestFocus();
        }
      });
    } else {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: _hovering ? 240 : 0,
            margin: const EdgeInsets.only(right: 12),
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                if (_hovering)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
              border: Border.all(
                color: Colors.purple.shade200,
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _hovering ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Describe what to generate...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 15),
                    enabled: _hovering,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.purple.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: null, // No action yet
                borderRadius: BorderRadius.circular(28),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/dingbats/󰆻.svg',
                    width: 28,
                    height: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 