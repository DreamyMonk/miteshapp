// Minimal static file server for the release web build (no external deps).
// Usage: dart tool/serve.dart [port]
import 'dart:io';

const _mime = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript',
  '.mjs': 'application/javascript',
  '.json': 'application/json',
  '.css': 'text/css',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.bin': 'application/octet-stream',
  '.symbols': 'application/octet-stream',
};

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.parse(args[0]) : 8090;
  final root = Directory('build/web').absolute;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Serving ${root.path} at http://127.0.0.1:$port');
  await for (final req in server) {
    try {
      var p = Uri.decodeComponent(req.uri.path);
      if (p == '/' || p.isEmpty) p = '/index.html';
      var file = File('${root.path}$p');
      if (!await file.exists()) {
        // SPA fallback
        file = File('${root.path}/index.html');
      }
      final ext = p.contains('.') ? p.substring(p.lastIndexOf('.')) : '';
      req.response.headers.set('Content-Type', _mime[ext] ?? 'application/octet-stream');
      req.response.headers.set('Cache-Control', 'no-store');
      await req.response.addStream(file.openRead());
      await req.response.close();
    } catch (_) {
      req.response.statusCode = HttpStatus.internalServerError;
      await req.response.close();
    }
  }
}
