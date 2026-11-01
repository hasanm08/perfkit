import 'package:go_router/go_router.dart';

import '../../core/progress/module_progress_store.dart';
import '../../features/about/presentation/about_page.dart';
import '../../features/deep_link_lab/data/auth_session.dart';
import '../../features/deep_link_lab/domain/deep_link_scenarios.dart';
import '../../features/deep_link_lab/presentation/pages/deep_link_lab_page.dart';
import '../../features/deep_link_lab/presentation/pages/deep_link_pages.dart';
import '../../features/memory_lab/presentation/pages/memory_lab_page.dart';
import '../../features/offline_lab/data/offline_lab_scope.dart';
import '../../features/offline_lab/presentation/pages/offline_lab_page.dart';
import '../../features/overview/presentation/overview_page.dart';
import '../../features/performance_lab/presentation/pages/performance_lab_page.dart';
import '../../features/testing_lab/presentation/pages/testing_lab_page.dart';
import '../shell/app_shell.dart';

class AppRouter {
  AppRouter({
    required this.progress,
    OfflineLabScope? offlineScope,
    DeepLinkLabServices? deepLinkServices,
  }) : offlineScope = offlineScope ?? OfflineLabScope(),
       deepLinkServices = deepLinkServices ?? DeepLinkLabServices();

  final ModuleProgressStore progress;
  final OfflineLabScope offlineScope;
  final DeepLinkLabServices deepLinkServices;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => OverviewPage(progress: progress),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/performance',
                builder: (_, _) => PerformanceLabPage(progress: progress),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/memory',
                builder: (_, _) => MemoryLabPage(progress: progress),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/offline',
                builder: (_, _) =>
                    OfflineLabPage(progress: progress, scope: offlineScope),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/deep-link',
                builder: (_, _) => DeepLinkLabPage(
                  progress: progress,
                  services: deepLinkServices,
                ),
                routes: [
                  GoRoute(
                    path: 'login',
                    builder: (_, _) => LoginPage(auth: deepLinkServices.auth),
                  ),
                  GoRoute(
                    path: 'error',
                    builder: (_, state) => DeepLinkErrorPage(
                      message:
                          state.uri.queryParameters['msg'] ?? 'Unknown error',
                    ),
                  ),
                  GoRoute(
                    path: 'broken-flat',
                    builder: (_, state) => BrokenFlatPushPage(
                      to:
                          state.uri.queryParameters['to'] ??
                          '/deep-link/app/products',
                    ),
                  ),
                  StatefulShellRoute.indexedStack(
                    builder: (context, state, navigationShell) {
                      return DeepLinkAppShell(navigationShell: navigationShell);
                    },
                    branches: [
                      StatefulShellBranch(
                        routes: [
                          GoRoute(
                            path: 'app/products',
                            builder: (_, _) => const ProductsListPage(),
                            routes: [
                              GoRoute(
                                path: ':id',
                                builder: (_, state) => ProductDetailPage(
                                  id: state.pathParameters['id']!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      StatefulShellBranch(
                        routes: [
                          GoRoute(
                            path: 'app/orders',
                            builder: (_, _) => const OrdersListPage(),
                            routes: [
                              GoRoute(
                                path: ':id',
                                builder: (_, state) => OrderDetailPage(
                                  id: state.pathParameters['id']!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      StatefulShellBranch(
                        routes: [
                          GoRoute(
                            path: 'app/profile',
                            builder: (_, _) =>
                                ProfilePage(auth: deepLinkServices.auth),
                            redirect: (context, state) {
                              final auth = deepLinkServices.auth;
                              if (!auth.isAuthenticated) {
                                auth.rememberIntended(state.matchedLocation);
                                return '/deep-link/login';
                              }
                              if (auth.status == AuthStatus.expired) {
                                auth.rememberIntended(state.matchedLocation);
                                return '/deep-link/login';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/testing',
                builder: (_, _) => TestingLabPage(progress: progress),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/about', builder: (_, _) => const AboutPage()),
            ],
          ),
        ],
      ),
    ],
  );
}
