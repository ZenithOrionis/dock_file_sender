import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/dock_status.dart';
import '../utils/constants.dart';
import 'multipart_progress_request.dart';

class ApiService {
  Future<void> uploadFile(File file, {void Function(int, int)? onProgress}) async {
    final uri = Uri.parse(ApiConstants.upload);
    final length = await file.length();
    
    final request = MultipartProgressRequest(
      'POST', 
      uri, 
      onProgress: onProgress,
      expectedTotalBytes: length,
    );
    
    final multipartFile = await http.MultipartFile.fromPath(
      'file', 
      file.path,
    );
    
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Upload failed with status: ${response.statusCode}, ${response.body}');
    }
  }

  Future<DockStatus> checkDockStatus() async {
    final uri = Uri.parse(ApiConstants.dockCheck);
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return DockStatus.fromJson(jsonMap);
    } else {
      throw Exception('Failed to fetch dock status: ${response.statusCode}');
    }
  }

  Future<void> downloadFile(String filename, String savePath) async {
    final uri = Uri.parse('${ApiConstants.dockDownload}$filename');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
  }

  Future<void> deleteFile(String filename) async {
    final uri = Uri.parse('${ApiConstants.dockDelete}$filename');
    final response = await http.delete(uri);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete file: ${response.statusCode}');
    }
  }

  Future<void> activateDevice(String contactNumber, String licenseKey) async {
    final uri = Uri.parse(ApiConstants.deviceActivate);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contact_number': contactNumber,
        'license_key': licenseKey,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Device activation failed: ${response.statusCode}, ${response.body}');
    }
  }
}

