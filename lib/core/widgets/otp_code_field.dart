import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A 6-digit code entry row — one focused, auto-advancing box per digit.
/// Built on a single hidden [TextField] rather than six real focus nodes,
/// which avoids the usual OTP-widget headache of keeping backspace-across-
/// cells and paste-a-full-code both working correctly.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.onCompleted,
    this.length = 6,
    this.errorText,
  });

  final ValueChanged<String> onCompleted;
  final int length;
  final String? errorText;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    if (value.length == widget.length) {
      widget.onCompleted(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          // Real input, invisible — receives focus/keyboard/paste.
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              onChanged: _onChanged,
              autofillHints: const [AutofillHints.oneTimeCode],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(widget.length, (index) {
                  final digit = index < _controller.text.length
                      ? _controller.text[index]
                      : '';
                  final isCurrent = index == _controller.text.length &&
                      _focusNode.hasFocus;

                  return AnimatedContainer(
                    duration: AppMotion.fast,
                    curve: AppMotion.entrance,
                    width: 44,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: hasError
                            ? AppColors.error
                            : isCurrent
                                ? AppColors.focusRing
                                : AppColors.border,
                        width: isCurrent || hasError ? 1.6 : 1,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.18),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(digit, style: AppTextStyles.code(size: 20)),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
