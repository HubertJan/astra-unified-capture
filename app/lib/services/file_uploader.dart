import 'dart:io';
import 'package:http/http.dart' as http;

const _fileUploadUrl = "192.168.2.1:8000";

Future<void> uploadFileToService(File file) async {
  HttpClient httpClient = HttpClient();
  final filename = (file.uri.pathSegments.last);
  final uri = Uri.http(_fileUploadUrl, "/$filename");
  try {
    var request = http.Request('PUT', uri)
      ..headers['content-type'] = 'application/octet-stream'
      ..bodyBytes = await file.readAsBytes();

    var response = await http.Client().send(request);
    print('Response status: ${response.statusCode}');
  } catch (e) {
    print('Error uploading file: $e');
  } finally {
    httpClient.close();
  }
}
//curl -v -F file=1.txt http://192.168.2.1:8000