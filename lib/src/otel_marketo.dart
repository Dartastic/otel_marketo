// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_marketo_suppression.dart';

const _tracerName = 'dartastic_otel_libs_marketo';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class MarketoResult {
  /// Creates a result.
  const MarketoResult({
    this.munchkinId,
    this.entityKind,
    this.entityId,
    this.action,
    this.programId,
    this.programName,
    this.campaignId,
    this.smartCampaignStatus,
    this.smartListId,
    this.staticListId,
    this.leadCount,
    this.activityType,
    this.emailId,
    this.emailDeliveredCount,
    this.emailBouncedCount,
    this.bulkJobId,
    this.bulkJobStatus,
    this.exportRows,
    this.dailyApiCallsUsed,
    this.dailyApiCallsLimit,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// Munchkin id (`xxx-yyy-zzz`) identifying the Marketo instance.
  final String? munchkinId;

  /// `lead`, `program`, `campaign`, `smart_campaign`, `static_list`,
  /// `smart_list`, `email`, `email_template`, `form`, `landing_page`,
  /// `activity`, `bulk_extract`, `bulk_import`, `custom_object`,
  /// `company`, `opportunity`, `sales_person`, `named_account`,
  /// `program_member`.
  final String? entityKind;

  final String? entityId;

  /// `create`, `update`, `delete`, `get`, `list`, `describe`,
  /// `query`, `clone`, `schedule`, `pause`, `unschedule`, `request`.
  final String? action;

  final String? programId;
  final String? programName;

  final String? campaignId;

  /// `active`, `inactive`, `scheduled`.
  final String? smartCampaignStatus;

  final String? smartListId;
  final String? staticListId;

  /// Number of leads affected / returned.
  final int? leadCount;

  /// Marketo activity type id (numeric).
  final int? activityType;

  final String? emailId;

  /// Delivery + bounce counts on email send report.
  final int? emailDeliveredCount;
  final int? emailBouncedCount;

  /// Bulk Extract / Import job id and status (`Created`, `Queued`,
  /// `Processing`, `Completed`, `Cancelled`, `Failed`).
  final String? bulkJobId;
  final String? bulkJobStatus;
  final int? exportRows;

  final int? dailyApiCallsUsed;
  final int? dailyApiCallsLimit;

  /// Marketo error code (e.g. `601` access token invalid, `602` expired,
  /// `606` rate limit exceeded, `607` daily quota reached, `610` not found,
  /// `611` system error, `612` bad request, `1003` empty list,
  /// `1004` not found).
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class MarketoCallResult<T> {
  /// Creates a call result.
  const MarketoCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final MarketoResult? result;
}

/// Wraps a Marketo Engage API call in a CLIENT span. [operation] is one of
/// `lead.create`, `lead.update`, `lead.upsert`, `lead.delete`,
/// `lead.get`, `lead.list`, `lead.byFilter`, `lead.partition`,
/// `program.create`, `program.update`, `program.delete`, `program.clone`,
/// `program.schedule`, `program.approve`, `program.unapprove`,
/// `campaign.request`, `campaign.schedule`, `campaign.trigger`,
/// `smartList.get`, `smartList.leads`, `staticList.addLeads`,
/// `staticList.removeLeads`, `staticList.member`,
/// `activity.get`, `activity.list`, `activity.deleted`,
/// `email.send`, `email.sendTest`, `email.update`, `email.clone`,
/// `bulkExtract.create`, `bulkExtract.enqueue`, `bulkExtract.cancel`,
/// `bulkExtract.status`, `bulkExtract.file`,
/// `bulkImport.create`, `bulkImport.status`, `bulkImport.failures`,
/// `bulkImport.warnings`, `customObject.upsert`, `customObject.delete`,
/// `customObject.get`, `customObject.list`, `auth.token`.
Future<T> tracedMarketo<T>({
  required String operation,
  required Future<MarketoCallResult<T>> Function() invoke,
}) async {
  if (marketoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'marketo',
    'rpc.method': operation,
    'marketo.operation': operation,
  };

  final span = _tracer().startSpan(
    'marketo $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.munchkinId != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.munchkin_id',
          res.munchkinId!,
        ));
      }
      if (res.entityKind != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.entity.kind',
          res.entityKind!,
        ));
      }
      if (res.entityId != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.entity.id',
          res.entityId!,
        ));
      }
      if (res.action != null) {
        extras.add(OTelAPI.attributeString('marketo.action', res.action!));
      }
      if (res.programId != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.program.id',
          res.programId!,
        ));
      }
      if (res.programName != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.program.name',
          res.programName!,
        ));
      }
      if (res.campaignId != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.campaign.id',
          res.campaignId!,
        ));
      }
      if (res.smartCampaignStatus != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.smart_campaign.status',
          res.smartCampaignStatus!,
        ));
      }
      if (res.smartListId != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.smart_list.id',
          res.smartListId!,
        ));
      }
      if (res.staticListId != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.static_list.id',
          res.staticListId!,
        ));
      }
      if (res.leadCount != null) {
        extras.add(OTelAPI.attributeInt('marketo.lead.count', res.leadCount!));
      }
      if (res.activityType != null) {
        extras.add(OTelAPI.attributeInt(
          'marketo.activity.type',
          res.activityType!,
        ));
      }
      if (res.emailId != null) {
        extras.add(OTelAPI.attributeString('marketo.email.id', res.emailId!));
      }
      if (res.emailDeliveredCount != null) {
        extras.add(OTelAPI.attributeInt(
          'marketo.email.delivered_count',
          res.emailDeliveredCount!,
        ));
      }
      if (res.emailBouncedCount != null) {
        extras.add(OTelAPI.attributeInt(
          'marketo.email.bounced_count',
          res.emailBouncedCount!,
        ));
      }
      if (res.bulkJobId != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.bulk.job_id',
          res.bulkJobId!,
        ));
      }
      if (res.bulkJobStatus != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.bulk.job_status',
          res.bulkJobStatus!,
        ));
        if (res.bulkJobStatus == 'Failed') {
          span.setStatus(SpanStatusCode.Error, 'Marketo bulk job Failed');
        }
      }
      if (res.exportRows != null) {
        extras.add(OTelAPI.attributeInt(
          'marketo.bulk.export_rows',
          res.exportRows!,
        ));
      }
      if (res.dailyApiCallsUsed != null) {
        extras.add(OTelAPI.attributeInt(
          'marketo.quota.daily_used',
          res.dailyApiCallsUsed!,
        ));
      }
      if (res.dailyApiCallsLimit != null) {
        extras.add(OTelAPI.attributeInt(
          'marketo.quota.daily_limit',
          res.dailyApiCallsLimit!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Marketo ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'marketo.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Marketo HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
