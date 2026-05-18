// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_marketo/otel_marketo.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_marketo-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('lead.upsert records entity + count + quota', () async {
    await tracedMarketo<String>(
      operation: 'lead.upsert',
      invoke: () async => const MarketoCallResult(
        value: 'ok',
        result: MarketoResult(
          munchkinId: '123-XYZ-456',
          entityKind: 'lead',
          action: 'update',
          leadCount: 250,
          dailyApiCallsUsed: 8500,
          dailyApiCallsLimit: 50000,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('marketo lead.upsert')!);
    expect(a['marketo.lead.count'], 250);
    expect(a['marketo.quota.daily_used'], 8500);
  });

  test('Failed bulk job sets span error', () async {
    await tracedMarketo<String>(
      operation: 'bulkExtract.status',
      invoke: () async => const MarketoCallResult(
        value: 'ok',
        result: MarketoResult(
          entityKind: 'bulk_extract',
          bulkJobId: 'bj_1',
          bulkJobStatus: 'Failed',
        ),
      ),
    );
    expect(
      spans.findSpanByName('marketo bulkExtract.status')!.status,
      SpanStatusCode.Error,
    );
  });

  test('rate-limit error code (606) sets span error', () async {
    await tracedMarketo<String>(
      operation: 'lead.get',
      invoke: () async => const MarketoCallResult(
        value: 'ok',
        result: MarketoResult(
          errorCode: '606',
          errorMessage: 'Max rate limit exceeded',
        ),
      ),
    );
    expect(
      spans.findSpanByName('marketo lead.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutMarketoInstrumentationAsync(() async {
      await tracedMarketo<String>(
        operation: 'auth.token',
        invoke: () async => const MarketoCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('marketo '), isEmpty);
  });
}
