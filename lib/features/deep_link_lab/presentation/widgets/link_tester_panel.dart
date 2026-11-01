import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';
import '../../data/auth_session.dart';
import '../../data/deep_link_handler.dart';
import '../../data/link_event_log.dart';
import '../../data/notification_nav_queue.dart';

enum DeepLinkFocus { coldWarm, auth, nested, invalid, notification }

class LinkTesterPanel extends StatefulWidget {
  const LinkTesterPanel({
    super.key,
    required this.controller,
    required this.useFixed,
    required this.focus,
    required this.auth,
    required this.handler,
    required this.log,
    required this.notifications,
  });

  final LabDemoController controller;
  final bool useFixed;
  final DeepLinkFocus focus;
  final AuthSession auth;
  final DeepLinkHandler handler;
  final LinkEventLog log;
  final NotificationNavQueue notifications;

  @override
  State<LinkTesterPanel> createState() => _LinkTesterPanelState();
}

class _LinkTesterPanelState extends State<LinkTesterPanel> {
  final _url = TextEditingController(text: '/deep-link/app/products/p42');
  bool _coldStart = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    widget.log.addListener(_publish);
    widget.auth.addListener(_publish);
  }

  void _onController() {
    if (widget.controller.isRunning) {
      _runScenario();
    }
  }

  void _publish() {
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Auth',
        value: widget.auth.status.name,
        source: MetricSource.simulated,
      ),
      MetricSnapshot(
        label: 'Mode',
        value: _coldStart ? 'cold' : 'warm',
        source: MetricSource.simulated,
      ),
      MetricSnapshot(
        label: 'Events',
        value: '${widget.log.events.length}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Pending notif',
        value: widget.notifications.pending ?? '—',
        source: MetricSource.counter,
      ),
    ]);
    setState(() {});
  }

  Future<void> _runScenario() async {
    final raw = _url.text.trim();
    switch (widget.focus) {
      case DeepLinkFocus.coldWarm:
        final uri = Uri.parse(raw.startsWith('/') ? 'perfkit://app$raw' : raw);
        if (widget.useFixed) {
          widget.handler.ingestFixed(uri, coldStart: _coldStart);
          final path = uri.path.isEmpty ? raw : uri.path;
          if (_coldStart) {
            final initial = widget.handler.consumeInitial();
            if (initial != null && context.mounted) {
              context.go(_pathFromUri(initial, fallback: path));
            }
          } else if (context.mounted) {
            context.go(_pathFromUri(uri, fallback: path));
          }
        } else {
          widget.handler.ingestBroken(uri, coldStart: _coldStart);
          if (!_coldStart && context.mounted) {
            context.go(_pathFromUri(uri, fallback: raw));
          }
        }
      case DeepLinkFocus.auth:
        final dest = raw.startsWith('/') ? raw : '/deep-link/app/orders/o1';
        if (widget.useFixed) {
          if (!widget.auth.isAuthenticated) {
            widget.auth.rememberIntended(dest);
            widget.log.add('FIXED: redirecting to login; saved $dest');
            if (context.mounted) context.go('/deep-link/login');
          } else {
            widget.log.add('FIXED: authenticated → $dest');
            if (context.mounted) context.go(dest);
          }
        } else {
          // ❌ Navigate to protected route before auth resolves.
          widget.log.add('BROKEN: pushing protected $dest without auth gate');
          if (context.mounted) context.go(dest);
        }
      case DeepLinkFocus.nested:
        final dest = raw.startsWith('/') ? raw : '/deep-link/app/products/p7';
        if (widget.useFixed) {
          widget.log.add('FIXED: nested go → $dest');
          if (context.mounted) context.go(dest);
        } else {
          // ❌ Flat push that ignores tab shell structure (simulated via query).
          widget.log.add('BROKEN: flat push ignoring nested shell → $dest');
          if (context.mounted) {
            context.push(
              '/deep-link/broken-flat?to=${Uri.encodeComponent(dest)}',
            );
          }
        }
      case DeepLinkFocus.invalid:
        final dest = raw.isEmpty
            ? '/deep-link/app/products/not-a-real-id!!!'
            : raw;
        if (widget.useFixed) {
          if (!_validProductPath(dest) && !_validOrderPath(dest)) {
            widget.log.add('FIXED: invalid route → error page');
            if (context.mounted) {
              context.go(
                '/deep-link/error?msg=${Uri.encodeComponent('Invalid or missing resource: $dest')}',
              );
            }
          } else if (context.mounted) {
            context.go(dest);
          }
        } else {
          // ❌ Navigate blindly — may show blank/crash-like error UI.
          widget.log.add('BROKEN: blind navigate to $dest');
          if (context.mounted) context.go(dest);
        }
      case DeepLinkFocus.notification:
        final dest = raw.startsWith('/') ? raw : '/deep-link/app/orders/o9';
        if (widget.useFixed) {
          widget.notifications.ingestFixed(dest, requiresAuth: true);
          final go = widget.notifications.flush();
          if (go != null && context.mounted) context.go(go);
        } else {
          final go = widget.notifications.ingestBroken(dest);
          if (go != null && context.mounted) context.go(go);
        }
    }
    _publish();
  }

  bool _validProductPath(String path) {
    final m = RegExp(r'^/deep-link/app/products/p\d+$').hasMatch(path);
    return m;
  }

  bool _validOrderPath(String path) {
    return RegExp(r'^/deep-link/app/orders/o\d+$').hasMatch(path);
  }

  String _pathFromUri(Uri uri, {required String fallback}) {
    if (uri.scheme == 'perfkit' || uri.path.startsWith('/deep-link')) {
      if (uri.path.startsWith('/deep-link')) return uri.path;
      return '/deep-link/app${uri.path}';
    }
    return fallback.startsWith('/') ? fallback : '/deep-link/app/products/p1';
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    widget.log.removeListener(_publish);
    widget.auth.removeListener(_publish);
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.useFixed ? PerfKitColors.fixed : PerfKitColors.broken;
    return Row(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Text(
                  widget.useFixed
                      ? 'FIXED implementation active'
                      : 'BROKEN implementation active',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _url,
                decoration: const InputDecoration(
                  labelText: 'Deep link / path',
                  hintText: '/deep-link/app/products/p42',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(_coldStart ? 'Cold start' : 'Warm start'),
                    selected: _coldStart,
                    onSelected: (v) => setState(() => _coldStart = v),
                  ),
                  ..._presets.map(
                    (p) => ActionChip(
                      label: Text(p.$1),
                      onPressed: () => setState(() => _url.text = p.$2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Auth simulation',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => widget.auth.signOut(),
                    child: const Text('Signed out'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      widget.auth.signIn();
                      final dest = widget.auth.takeIntended();
                      if (dest != null && context.mounted) context.go(dest);
                    },
                    child: const Text('Sign in'),
                  ),
                  OutlinedButton(
                    onPressed: () => widget.auth.expire(),
                    child: const Text('Expire token'),
                  ),
                ],
              ),
              if (widget.focus == DeepLinkFocus.notification) ...[
                const SizedBox(height: 12),
                const Text(
                  'Lifecycle simulation',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final p in AppLifecyclePhase.values)
                      OutlinedButton(
                        onPressed: () {
                          widget.notifications.setPhase(p);
                          final go = widget.notifications.flush();
                          if (go != null && context.mounted) context.go(go);
                        },
                        child: Text(p.name),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _runScenario,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Fire link'),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ListenableBuilder(
            listenable: widget.log,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  const Text(
                    'NAVIGATION EVENTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: PerfKitColors.secondaryText,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.log.events.reversed.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        e.toString(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static const _presets = [
    ('Product', '/deep-link/app/products/p42'),
    ('Order', '/deep-link/app/orders/o7'),
    ('Profile', '/deep-link/app/profile'),
    ('Invalid', '/deep-link/app/products/!!!'),
  ];
}
