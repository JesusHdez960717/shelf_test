import 'http_entity.dart';
import 'http_method.dart';

class RequestEntity<T> extends HttpEntity<T> {
  final Uri url;

  /// The original [Uri] for the request.
  final Uri requestedUri;
  final String handlerPath;

  ///url con la que se definio la ruta, ex: https://mi-url.com/{path-param-1}/test/{path-param-2}
  late final String templateUrl;

  final String protocolVersion;

  final HttpMethod method;

  late final Map<String, String> pathParams;
  late final Map<String, String> queryParams;

  RequestEntity({
    required this.method,
    required this.requestedUri,
    super.headers,
    super.body,
    String? protocolVersion,
    String? handlerPath,
    Uri? url,
  })  : protocolVersion = protocolVersion ?? '1.1',
        url = _computeUrl(requestedUri, handlerPath, url),
        handlerPath = _computeHandlerPath(requestedUri, handlerPath, url) {
    try {
      // Trigger URI parsing methods that may throw format exception (in Request
      // constructor or in handlers / routing).
      requestedUri.pathSegments;
      requestedUri.queryParametersAll;
    } on FormatException catch (e) {
      throw ArgumentError.value(
          requestedUri, 'requestedUri', 'URI parsing failed: $e');
    }

    if (!requestedUri.isAbsolute) {
      throw ArgumentError.value(
          requestedUri, 'requestedUri', 'must be an absolute URL.');
    }

    if (requestedUri.fragment.isNotEmpty) {
      throw ArgumentError.value(
          requestedUri, 'requestedUri', 'may not have a fragment.');
    }

    // Notice that because relative paths must encode colon (':') as %3A we
    // cannot actually combine this.handlerPath and this.url.path, but we can
    // compare the pathSegments. In practice exposing this.url.path as a Uri
    // and not a String is probably the underlying flaw here.
    final handlerPart = Uri(path: this.handlerPath).pathSegments.join('/');
    final rest = this.url.pathSegments.join('/');
    final join = this.url.path.startsWith('/') ? '/' : '';
    final pathSegments = '$handlerPart$join$rest';
    if (pathSegments != requestedUri.pathSegments.join('/')) {
      throw ArgumentError.value(
          requestedUri,
          'requestedUri',
          'handlerPath "${this.handlerPath}" and url "${this.url}" must '
              'combine to equal requestedUri path "${requestedUri.path}".');
    }

    queryParams = _extractQueryParams(requestedUri.toString());
  }

  void setUpPathParams(String template) {
    templateUrl = template;
    pathParams = _extractPathParams(
      templateUrl,
      requestedUri.toString(),
    );
  }
}

Map<String, String> _extractPathParams(String templateUrl, String actualUrl) {
  actualUrl = Uri.parse(actualUrl).path; //remove http(s)://domain.com

  // Separar la parte de la URL que contiene los parámetros de consulta (si existe)
  String templateUrlPath = templateUrl.split('?').first;
  String actualUrlPath = actualUrl.split('?').first;

  // Crear una expresión regular para encontrar los parámetros de ruta en la plantilla
  final RegExp pathParamPattern = RegExp(r'{([^}]+)}');

  // Crear una expresión regular para capturar los valores correspondientes en la URL real
  String regexPattern = templateUrlPath.replaceAllMapped(
      pathParamPattern, (match) => r'([^/?]+)');

  // Añadir el inicio (^) y el final opcional ($) para asegurar una coincidencia completa
  regexPattern = '^' + regexPattern;

  // Encontrar los valores de los parámetros de ruta en la URL real
  final RegExpMatch? matchUrl = RegExp(regexPattern).firstMatch(actualUrlPath);

  Map<String, String> pathParam = {};
  Iterable<RegExpMatch> matches = pathParamPattern.allMatches(templateUrlPath);

  int index = 1;
  for (final RegExpMatch match in matches) {
    String paramName = match.group(1)!;
    String paramValue = matchUrl?.group(index++) ?? '';
    pathParam[paramName] = paramValue;
  }

  return pathParam;
}

Map<String, String> _extractQueryParams(String actualUrl) {
  Uri uri = Uri.parse(actualUrl);
  return uri.queryParameters;
}

/// Computes `url` from the provided [Request] constructor arguments.
///
/// If [url] is `null`, the value is inferred from [requestedUri] and
/// [handlerPath] if available. Otherwise [url] is returned.
Uri _computeUrl(Uri requestedUri, String? handlerPath, Uri? url) {
  if (handlerPath != null &&
      handlerPath != requestedUri.path &&
      !handlerPath.endsWith('/')) {
    handlerPath += '/';
  }

  if (url != null) {
    if (url.scheme.isNotEmpty || url.hasAuthority || url.fragment.isNotEmpty) {
      throw ArgumentError('url "$url" may contain only a path and query '
          'parameters.');
    }

    if (!requestedUri.path.endsWith(url.path)) {
      throw ArgumentError('url "$url" must be a suffix of requestedUri '
          '"$requestedUri".');
    }

    if (requestedUri.query != url.query) {
      throw ArgumentError('url "$url" must have the same query parameters '
          'as requestedUri "$requestedUri".');
    }

    if (url.path.startsWith('/')) {
      throw ArgumentError('url "$url" must be relative.');
    }

    var startOfUrl = requestedUri.path.length - url.path.length;
    if (url.path.isNotEmpty &&
        requestedUri.path.substring(startOfUrl - 1, startOfUrl) != '/') {
      throw ArgumentError('url "$url" must be on a path boundary in '
          'requestedUri "$requestedUri".');
    }

    return url;
  } else if (handlerPath != null) {
    return Uri(
        path: requestedUri.path.substring(handlerPath.length),
        query: requestedUri.query);
  } else {
    // Skip the initial "/".
    var path = requestedUri.path.substring(1);
    return Uri(path: path, query: requestedUri.query);
  }
}

/// Computes `handlerPath` from the provided [Request] constructor arguments.
///
/// If [handlerPath] is `null`, the value is inferred from [requestedUri] and
/// [url] if available. Otherwise [handlerPath] is returned.
String _computeHandlerPath(Uri requestedUri, String? handlerPath, Uri? url) {
  if (handlerPath != null &&
      handlerPath != requestedUri.path &&
      !handlerPath.endsWith('/')) {
    handlerPath += '/';
  }

  if (handlerPath != null) {
    if (!requestedUri.path.startsWith(handlerPath)) {
      throw ArgumentError('handlerPath "$handlerPath" must be a prefix of '
          'requestedUri path "${requestedUri.path}"');
    }

    if (!handlerPath.startsWith('/')) {
      throw ArgumentError('handlerPath "$handlerPath" must be root-relative.');
    }

    return handlerPath;
  } else if (url != null) {
    if (url.path.isEmpty) return requestedUri.path;

    var index = requestedUri.path.indexOf(url.path);
    return requestedUri.path.substring(0, index);
  } else {
    return '/';
  }
}
