import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/colors.dart';
import '../../data/auth_session.dart';

class DeepLinkLabHome extends StatelessWidget {
  const DeepLinkLabHome({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class DeepLinkAppShell extends StatelessWidget {
  const DeepLinkAppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: PerfKitColors.surface,
          child: Row(
            children: [
              _Tab(
                label: 'Products',
                selected: navigationShell.currentIndex == 0,
                onTap: () => navigationShell.goBranch(0),
              ),
              _Tab(
                label: 'Orders',
                selected: navigationShell.currentIndex == 1,
                onTap: () => navigationShell.goBranch(1),
              ),
              _Tab(
                label: 'Profile',
                selected: navigationShell.currentIndex == 2,
                onTap: () => navigationShell.goBranch(2),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: navigationShell),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? PerfKitColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? PerfKitColors.primaryText
                : PerfKitColors.secondaryText,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class ProductsListPage extends StatelessWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (_, i) => ListTile(
        title: Text('Product p$i'),
        onTap: () => context.go('/deep-link/app/products/p$i'),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final valid = RegExp(r'^p\d+$').hasMatch(id);
    if (!valid) {
      return Center(
        child: Text(
          'Missing product: $id',
          style: const TextStyle(color: PerfKitColors.danger),
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Product $id',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Deep-linked product detail',
            style: TextStyle(color: PerfKitColors.secondaryText),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.go('/deep-link/app/products'),
            child: const Text('Back to products'),
          ),
        ],
      ),
    );
  }
}

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (_, i) => ListTile(
        title: Text('Order o$i'),
        onTap: () => context.go('/deep-link/app/orders/o$i'),
      ),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final valid = RegExp(r'^o\d+$').hasMatch(id);
    if (!valid) {
      return Center(
        child: Text(
          'Missing order: $id',
          style: const TextStyle(color: PerfKitColors.danger),
        ),
      );
    }
    return Center(
      child: Text(
        'Order $id',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.auth});
  final AuthSession auth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Profile (${auth.status.name})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: auth.signOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.auth});
  final AuthSession auth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  auth.intendedDestination == null
                      ? 'No saved destination'
                      : 'After login → ${auth.intendedDestination}',
                  style: const TextStyle(
                    color: PerfKitColors.secondaryText,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    auth.signIn();
                    final dest =
                        auth.takeIntended() ?? '/deep-link/app/products';
                    context.go(dest);
                  },
                  child: const Text('Simulate login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeepLinkErrorPage extends StatelessWidget {
  const DeepLinkErrorPage({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: PerfKitColors.danger,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.go('/deep-link'),
            child: const Text('Back to lab'),
          ),
        ],
      ),
    );
  }
}

class BrokenFlatPushPage extends StatelessWidget {
  const BrokenFlatPushPage({super.key, required this.to});
  final String to;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Broken flat push',
            style: TextStyle(
              color: PerfKitColors.broken,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text('Bypassed nested tabs. Intended: $to'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go(to),
            child: const Text('Go to intended (fixed path)'),
          ),
        ],
      ),
    );
  }
}
