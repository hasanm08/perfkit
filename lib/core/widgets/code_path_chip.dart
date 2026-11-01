import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/colors.dart';

class CodePathChip extends StatelessWidget {
  const CodePathChip({super.key, required this.path, this.label});

  final String path;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: path));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied: $path'),
              duration: const Duration(seconds: 2),
              backgroundColor: PerfKitColors.surfaceElevated,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: PerfKitColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: PerfKitColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.code, size: 14, color: PerfKitColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label == null ? path : '$label: $path',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: PerfKitColors.primaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.copy,
              size: 12,
              color: PerfKitColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
