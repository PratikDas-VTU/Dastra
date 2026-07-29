import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AdaptiveFileSelector extends StatelessWidget {
  const AdaptiveFileSelector({
    super.key,
    required this.child,
    required this.onFilesSelected,
    required this.onDragEntered,
    required this.onDragExited,
  });

  final Widget child;
  final void Function(List<String>) onFilesSelected;
  final void Function() onDragEntered;
  final void Function() onDragExited;

  @override
  Widget build(BuildContext context) {
    // Determine if the platform supports drag and drop
    bool isDesktopEnv = false;
    try {
      if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        isDesktopEnv = true;
      }
    } catch (_) {
      isDesktopEnv = false;
    }

    if (isDesktopEnv) {
      return DropTarget(
        onDragDone: (details) {
          onFilesSelected(details.files.map((e) => e.path).toList());
        },
        onDragEntered: (_) => onDragEntered(),
        onDragExited: (_) => onDragExited(),
        child: child,
      );
    }

    // On mobile/tablet environments without drag-and-drop, simply return the child.
    // The child should contain its own touch-friendly upload buttons.
    return child;
  }
}
