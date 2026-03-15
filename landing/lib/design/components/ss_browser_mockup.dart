import 'package:flutter/material.dart';
import '../tokens.dart';

class SSBrowserMockup extends StatelessWidget {
  const SSBrowserMockup({
    super.key,
    required this.child,
    this.url = 'app.servicesentinel.io',
  });

  final Widget child;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: SSRadius.bLg,
        border: Border.all(color: SSColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: SSColors.accent.withOpacity(0.06),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: SSRadius.bLg,
        child: Column(
          children: [
            // Chrome bar
            Container(
              height: 40,
              color: const Color(0xFF0D1F33),
              padding:
                  const EdgeInsets.symmetric(horizontal: SSSpacing.md),
              child: Row(children: [
                _dot(SSColors.danger),
                const SizedBox(width: 6),
                _dot(SSColors.warning),
                const SizedBox(width: 6),
                _dot(SSColors.success),
                const SizedBox(width: SSSpacing.md),
                Expanded(
                  child: Container(
                    height: 22,
                    decoration: BoxDecoration(
                      color: SSColors.surface,
                      borderRadius: SSRadius.bSm,
                    ),
                    alignment: Alignment.center,
                    child: Text(url,
                        style:
                            SSTextStyles.caption.copyWith(fontSize: 11)),
                  ),
                ),
              ]),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
