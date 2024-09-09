import 'dart:convert';

import 'package:http_parser/http_parser.dart';

import 'http_entity.dart';
import 'http_headers.dart';
import 'http_status.dart';

class ResponseEntity extends HttpEntity {
  HttpStatus status;

  ResponseEntity({
    required super.headers,
    required super.body,
    required this.status,
  });

  ResponseEntity.ok({
    HttpHeaders? headers,
    Object? body,
  }) : this(
          status: HttpStatus.OK,
          body: body,
          headers: headers,
        );

  ResponseEntity.internalServerError({
    HttpHeaders? headers,
    Object? body,
  }) : this(
          status: HttpStatus.INTERNAL_SERVER_ERROR,
          body: body ?? 'Internal Server Error',
          headers: headers,
        );

  ResponseEntity.badRequest({
    HttpHeaders? headers,
    Object? body,
  }) : this(
          status: HttpStatus.BAD_REQUEST,
          body: body ?? 'Bad Request',
          headers: headers,
        );

  ResponseEntity.notFound({
    HttpHeaders? headers,
    Object? body,
  }) : this(
          status: HttpStatus.NOT_FOUND,
          body: body ?? 'Not found',
          headers: headers,
        );

  ResponseEntity.methodNotAllowed({
    HttpHeaders? headers,
    Object? body,
  }) : this(
          status: HttpStatus.METHOD_NOT_ALLOWED,
          body: body ?? 'Method not allowed',
          headers: headers,
        );

  /// The date and time after which the response's data should be considered
  /// stale.
  ///
  /// This is parsed from the Expires header in [headers]. If [headers] doesn't
  /// have an Expires header, this will be `null`.
  DateTime? get expires {
    if (_expiresCache != null) return _expiresCache;
    if (!headers.containsKey(HttpHeaders.EXPIRES)) return null;
    _expiresCache = parseHttpDate(headers.singleValues[HttpHeaders.EXPIRES]!);
    return _expiresCache;
  }

  DateTime? _expiresCache;

  /// The date and time the source of the response's data was last modified.
  ///
  /// This is parsed from the Last-Modified header in [headers]. If [headers]
  /// doesn't have a Last-Modified header, this will be `null`.
  DateTime? get lastModified {
    if (_lastModifiedCache != null) return _lastModifiedCache;
    if (!headers.containsKey(HttpHeaders.LAST_MODIFIED)) return null;
    _lastModifiedCache =
        parseHttpDate(headers.singleValues[HttpHeaders.LAST_MODIFIED]!);
    return _lastModifiedCache;
  }

  DateTime? _lastModifiedCache;

  /// The contents of the content-length field in [headers].
  ///
  /// If not set, `null`.
  int? get contentLength {
    if (_contentLengthCache != null) return _contentLengthCache;
    if (!headers.containsKey(HttpHeaders.CONTENT_LENGTH)) return null;
    _contentLengthCache =
        int.parse(headers.singleValues[HttpHeaders.CONTENT_LENGTH]!);
    return _contentLengthCache;
  }

  int? _contentLengthCache;

  /// The MIME type of the message.
  ///
  /// This is parsed from the Content-Type header in [headers]. It contains only
  /// the MIME type, without any Content-Type parameters.
  ///
  /// If [headers] doesn't have a Content-Type header, this will be `null`.
  String? get mimeType {
    var contentType = _contentType;
    if (contentType == null) return null;
    return contentType.mimeType;
  }

  /// The parsed version of the Content-Type header in [headers].
  ///
  /// This is cached for efficient access.
  MediaType? get _contentType {
    if (_contentTypeCache != null) return _contentTypeCache;
    final contentTypeValue = headers.singleValues[HttpHeaders.CONTENT_TYPE];
    if (contentTypeValue == null) return null;
    return _contentTypeCache = MediaType.parse(contentTypeValue);
  }

  MediaType? _contentTypeCache;

  ResponseEntity copyWith({
    Map<String, Object?>? headers,
    Object? body,
  }) {
    final headersAll = updateHeaders(this.headers, headers);

    return ResponseEntity(
      status: status,
      body: body ?? body,
      headers: headers == null ? super.headers : HttpHeaders(headersAll),
    );
  }
}
