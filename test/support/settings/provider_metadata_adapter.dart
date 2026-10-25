import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Synthetic transport fixtures; exercises the production request builder.
class ProviderMetadataAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int status = 200;
  bool failTransport = false;
  Future<void> Function()? beforeResponse;
  Map<String, dynamic>? responseOverride;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    await beforeResponse?.call();
    if (failTransport) {
      throw DioException(
        requestOptions: options,
        message: 'private transport detail',
      );
    }
    final google = options.uri.host == 'generativelanguage.googleapis.com';
    final model = options.uri.pathSegments.last;
    final data =
        responseOverride ??
        (model == 'models'
            ? {google ? 'models' : 'data': <Object>[]}
            : {
                google ? 'name' : 'id': google ? 'models/$model' : model,
                if (google) 'supportedGenerationMethods': ['generateContent'],
                if (google) 'inputTokenLimit': 1048576,
                if (google) 'outputTokenLimit': 65536,
              });
    return ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}

  Dio client() => Dio()..httpClientAdapter = this;
}
