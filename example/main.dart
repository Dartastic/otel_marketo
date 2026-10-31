// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_marketo/otel_marketo.dart';

/// Traces Marketo Engage calls with OpenTelemetry.
///
/// `otel_marketo` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Marketo Engage call in
/// [tracedMarketo]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'marketo-example');

  // Wraps a Marketo Engage API call in a CLIENT span.
  final marketoId = await tracedMarketo<String>(
    operation: 'lead.create',
    invoke: () async {
      // Make the Marketo Engage call here, then report what it returned.
      const id = 'marketo_8f3a2c';
      return const MarketoCallResult(
          value: id,
          result: MarketoResult(
              munchkinId: '3Mtw8f3a2c-yyy-zzz',
              entityKind: 'lead',
              entityId: 'entity_8f3a2c',
              action: 'create',
              programId: 'program_8f3a2c',
              programName: 'example',
              campaignId: 'campaign_8f3a2c',
              smartCampaignStatus: 'active',
              smartListId: 'smartlist_8f3a2c',
              staticListId: 'staticlist_8f3a2c',
              leadCount: 3,
              activityType: 1,
              emailId: 'email_8f3a2c',
              emailDeliveredCount: 3,
              emailBouncedCount: 3,
              bulkJobId: 'Created',
              bulkJobStatus: 'succeeded',
              exportRows: 443,
              dailyApiCallsUsed: 1,
              dailyApiCallsLimit: 25,
              errorCode: '601',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedMarketo lead.create returned $marketoId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutMarketoInstrumentationAsync.
  await runWithoutMarketoInstrumentationAsync(
    () => tracedMarketo<String>(
      operation: 'lead.create',
      invoke: () async {
        const id = 'marketo_8f3a2c';
        return const MarketoCallResult(
            value: id,
            result: MarketoResult(
                munchkinId: '3Mtw8f3a2c-yyy-zzz',
                entityKind: 'lead',
                entityId: 'entity_8f3a2c',
                action: 'create',
                programId: 'program_8f3a2c',
                programName: 'example',
                campaignId: 'campaign_8f3a2c',
                smartCampaignStatus: 'active',
                smartListId: 'smartlist_8f3a2c',
                staticListId: 'staticlist_8f3a2c',
                leadCount: 3,
                activityType: 1,
                emailId: 'email_8f3a2c',
                emailDeliveredCount: 3,
                emailBouncedCount: 3,
                bulkJobId: 'Created',
                bulkJobStatus: 'succeeded',
                exportRows: 443,
                dailyApiCallsUsed: 1,
                dailyApiCallsLimit: 25,
                errorCode: '601',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
