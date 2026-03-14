import 'dart:async';
import 'package:http/http.dart' as http;

class MultipartProgressRequest extends http.MultipartRequest {
  final void Function(int bytes, int totalBytes)? onProgress;
  final int? expectedTotalBytes;

  MultipartProgressRequest(String method, Uri url, {this.onProgress, this.expectedTotalBytes})
      : super(method, url);

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    if (onProgress == null) return byteStream;

    final total = expectedTotalBytes ?? contentLength;
    int bytes = 0;

    final controller = StreamController<List<int>>(sync: true);

    byteStream.listen(
      (List<int> chunk) {
        bytes += chunk.length;
        if (onProgress != null) {
          onProgress!(bytes, total);
        }
        controller.add(chunk);
      },
      onDone: () {
        controller.close();
      },
      onError: (error, stackTrace) {
        controller.addError(error, stackTrace);
      },
      cancelOnError: true,
    );

    return http.ByteStream(controller.stream);
  }
}
