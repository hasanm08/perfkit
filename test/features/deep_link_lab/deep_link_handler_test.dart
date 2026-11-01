import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/features/deep_link_lab/data/deep_link_handler.dart';
import 'package:perfkit/features/deep_link_lab/data/link_event_log.dart';

void main() {
  test('fixed handler stores cold-start and dedupes', () {
    final log = LinkEventLog();
    final handler = DeepLinkHandler(log: log);
    final uri = Uri.parse('perfkit://app/products/p1');

    handler.ingestFixed(uri, coldStart: true);
    expect(handler.initialLink, uri);

    handler.ingestFixed(uri, coldStart: false);
    expect(log.events.where((e) => e.message.contains('deduped')).length, 1);
  });

  test('broken handler ignores cold-start', () {
    final log = LinkEventLog();
    final handler = DeepLinkHandler(log: log);
    final uri = Uri.parse('perfkit://app/products/p1');
    handler.ingestBroken(uri, coldStart: true);
    expect(handler.initialLink, isNull);
    expect(log.events.last.message, contains('ignored cold-start'));
  });
}
