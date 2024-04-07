import 'dart:convert';
import 'dart:io';

final _fileUploadUri = Uri.http("192.168.2.1:8000");

Future<void> uploadFileToService(File file) async {
  HttpClient httpClient = HttpClient();

  try {
    HttpClientRequest request = await httpClient.postUrl(_fileUploadUri);
    request.headers.contentType = ContentType('application', 'octet-stream');
    request.contentLength = await file.length();
    await request.addStream(file.openRead());
    await request.close();

    HttpClientResponse response = await request.close();
    await response.transform(utf8.decoder).forEach(print);
  } catch (e) {
    print('Error uploading file: $e');
  } finally {
    httpClient.close();
  }
}
