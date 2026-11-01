import 'package:flutter/material.dart';

import '../core/progress/module_progress_store.dart';
import 'router/app_router.dart';
import 'theme/perfkit_theme.dart';

class PerfKitApp extends StatefulWidget {
  const PerfKitApp({super.key, this.progress});

  final ModuleProgressStore? progress;

  @override
  State<PerfKitApp> createState() => _PerfKitAppState();
}

class _PerfKitAppState extends State<PerfKitApp> {
  late final ModuleProgressStore _progress;
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress ?? ModuleProgressStore();
    _progress.load();
    _router = AppRouter(progress: _progress);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PerfKit',
      debugShowCheckedModeBanner: false,
      theme: PerfKitTheme.dark,
      routerConfig: _router.router,
    );
  }
}
