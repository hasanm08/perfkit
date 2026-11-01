import 'package:flutter/widgets.dart';

import '../../../core/models/lab_scenario.dart';
import '../../../core/widgets/lab_demo_controller.dart';
import '../data/auth_session.dart';
import '../data/deep_link_handler.dart';
import '../data/link_event_log.dart';
import '../data/notification_nav_queue.dart';
import '../presentation/widgets/link_tester_panel.dart';

class DeepLinkLabServices {
  DeepLinkLabServices() {
    auth = AuthSession();
    log = LinkEventLog();
    handler = DeepLinkHandler(log: log);
    notifications = NotificationNavQueue(auth: auth, log: log);
  }

  late final AuthSession auth;
  late final LinkEventLog log;
  late final DeepLinkHandler handler;
  late final NotificationNavQueue notifications;
}

List<LabScenario> buildDeepLinkScenarios(DeepLinkLabServices s) => [
  _S(
    id: 'dl-cold-warm',
    title: '1. Cold-Start vs Warm-Start',
    problem: 'Broken only handles links while the app is already running.',
    diagnosis:
        'Toggle Cold start and Fire link. Broken ignores cold links; '
        'Fixed stores initialLink and dedupes.',
    fix: 'Handle initial + stream links; avoid processing the same link twice.',
    broken:
        'lib/features/deep_link_lab/data/deep_link_handler.dart (ingestBroken)',
    fixed:
        'lib/features/deep_link_lab/data/deep_link_handler.dart (ingestFixed)',
    focus: DeepLinkFocus.coldWarm,
    s: s,
  ),
  _S(
    id: 'dl-auth',
    title: '2. Authentication Redirects',
    problem: 'Broken navigates to protected pages before auth and loses destination.',
    diagnosis:
        'Sign out, Fire link to an order. Broken opens protected UI; '
        'Fixed routes to login and resumes after Sign in.',
    fix: 'Auth-aware redirect, preserve intended destination, handle expiry.',
    broken: 'lib/features/deep_link_lab/presentation/widgets/link_tester_panel.dart',
    fixed: 'lib/features/deep_link_lab/data/auth_session.dart',
    focus: DeepLinkFocus.auth,
    s: s,
  ),
  _S(
    id: 'dl-nested',
    title: '3. Nested Navigation',
    problem: 'Broken pushes routes without respecting nested tab structure.',
    diagnosis:
        'Fire a product link. Broken uses flat push; Fixed uses nested go.',
    fix: 'Clear route hierarchy / ShellRoute; preserve tab state; correct back stack.',
    broken:
        'lib/features/deep_link_lab/presentation/pages/deep_link_pages.dart',
    fixed: 'lib/app/router/app_router.dart (deep-link ShellRoute)',
    focus: DeepLinkFocus.nested,
    s: s,
  ),
  _S(
    id: 'dl-invalid',
    title: '4. Invalid & Expired Links',
    problem: 'Broken crashes or blanks on malformed URLs / missing resources.',
    diagnosis:
        'Use Invalid preset. Fixed shows error page; Broken navigates blindly.',
    fix: 'Validate params, handle missing resources, provide fallback pages.',
    broken: 'lib/features/deep_link_lab/presentation/widgets/link_tester_panel.dart',
    fixed: 'lib/features/deep_link_lab/presentation/pages/deep_link_pages.dart',
    focus: DeepLinkFocus.invalid,
    s: s,
  ),
  _S(
    id: 'dl-notification',
    title: '5. Push Notification Navigation',
    problem:
        'Broken navigates immediately ignoring lifecycle and authentication.',
    diagnosis:
        'Set lifecycle to background/terminated, Fire link. Fixed queues; '
        'Broken jumps immediately.',
    fix: 'Queue intents until foreground + auth ready; prevent duplicates.',
    broken: 'lib/features/deep_link_lab/data/notification_nav_queue.dart (ingestBroken)',
    fixed: 'lib/features/deep_link_lab/data/notification_nav_queue.dart (ingestFixed)',
    focus: DeepLinkFocus.notification,
    s: s,
  ),
];

class _S extends LabScenario {
  _S({
    required this.id,
    required this.title,
    required String problem,
    required String diagnosis,
    required String fix,
    required String broken,
    required String fixed,
    required this.focus,
    required this.s,
  }) : problemSummary = problem,
       diagnosis = diagnosis,
       recommendedFix = fix,
       brokenSourcePath = broken,
       fixedSourcePath = fixed;

  @override
  final String id;
  @override
  final String title;
  @override
  final String problemSummary;
  @override
  final String diagnosis;
  @override
  final String recommendedFix;
  @override
  final String brokenSourcePath;
  @override
  final String fixedSourcePath;
  final DeepLinkFocus focus;
  final DeepLinkLabServices s;

  @override
  Widget buildDemo({
    required bool useFixed,
    required LabDemoController controller,
  }) {
    return LinkTesterPanel(
      controller: controller,
      useFixed: useFixed,
      focus: focus,
      auth: s.auth,
      handler: s.handler,
      log: s.log,
      notifications: s.notifications,
    );
  }
}
