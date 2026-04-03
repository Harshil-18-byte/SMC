import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmartTextField extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;

  const SmartTextField({
    super.key,
    required this.label,
    this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  State<SmartTextField> createState() => _SmartTextFieldState();
}

class _SmartTextFieldState extends State<SmartTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _labelAnimation;
  late Animation<Color?> _colorAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isObscured = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _labelAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey[500],
      end: const Color(0xFF6366F1), // Primary brand color
    ).animate(_controller);

    _focusNode.addListener(_handleFocusChange);

    // Initial check if controller has text
    if (widget.controller?.text.isNotEmpty ?? false) {
      _controller.value = 1.0;
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus || (widget.controller?.text.isNotEmpty ?? false)) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    // Validate on blur
    if (!_focusNode.hasFocus && widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(widget.controller?.text);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _errorText != null
                      ? Colors.redAccent
                      : _colorAnimation.value?.withValues(alpha: 0.5) ??
                          Colors.grey.withValues(alpha: 0.2),
                  width: _focusNode.hasFocus ? 2 : 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Floating Label
                  Positioned(
                    left: 48,
                    top: 18 * (1 - _labelAnimation.value),
                    child: Transform.scale(
                      scale: 1 - (_labelAnimation.value * 0.2),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: _errorText != null
                              ? Colors.redAccent
                              : _colorAnimation.value,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Text Field
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8, // Make room for label
                      bottom: 4,
                    ),
                    child: Row(
                      children: [
                        if (widget.icon != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 16, top: 12),
                            child: Icon(
                              widget.icon,
                              color: _colorAnimation.value,
                              size: 24,
                            ),
                          ),
                        Expanded(
                          child: TextFormField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            obscureText: widget.isPassword && _isObscured,
                            keyboardType: widget.keyboardType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(top: 24, bottom: 8),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              if (widget.onChanged != null) {
                                widget.onChanged!(value);
                              }
                              if (_errorText != null) {
                                setState(() {
                                  _errorText = widget.validator?.call(value);
                                });
                              }
                            },
                          ),
                        ),
                        if (widget.isPassword)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                              HapticFeedback.selectionClick();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Icon(
                                _isObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Error Message Animation
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _errorText != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            _errorText!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}


