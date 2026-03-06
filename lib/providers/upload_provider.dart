import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import '../services/api_service.dart';
import '../models/dock_status.dart';

enum UploadState { idle, pickingFile, uploading, success, error }

class UploadProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UploadState _state = UploadState.idle;
  UploadState get state => _state;

  File? _selectedFile;
  File? get selectedFile => _selectedFile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  List<String> _dockFiles = [];
  List<String> get dockFiles => _dockFiles;

  String? _downloadingFile;
  String? get downloadingFile => _downloadingFile;

  String? _deletingFile;
  String? get deletingFile => _deletingFile;

  Timer? _pollingTimer;

  // Maximum file size in bytes (200 MB)
  static const int maxFileSizeBytes = 200 * 1024 * 1024;

  UploadProvider() {
    _startPolling();
  }

  void _startPolling() {
    _fetchDockStatus(); // Initial fetch
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_state != UploadState.uploading) {
        _fetchDockStatus();
      }
    });
  }

  Future<void> _fetchDockStatus() async {
    try {
      final dockStatus = await _apiService.checkDockStatus();
      if (dockStatus.success) {
        _dockFiles = dockStatus.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Polling error: \$e");
    }
  }

  Future<void> pickFile() async {
    _setState(UploadState.pickingFile);
    _errorMessage = null;
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf', 'doc', 'docx', 'mp4', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);
        final int fileSize = await file.length();

        if (fileSize > maxFileSizeBytes) {
          _errorMessage = "File is too large. Maximum size is 200MB.";
          _setState(UploadState.error);
        } else {
          _selectedFile = file;
          _setState(UploadState.idle);
        }
      } else {
        // User canceled picker
        _setState(UploadState.idle);
      }
    } catch (e) {
      _errorMessage = "Failed to pick file: \$e";
      _setState(UploadState.error);
    }
  }

  void clearSelection() {
    _selectedFile = null;
    _setState(UploadState.idle);
  }

  Future<void> uploadFile() async {
    if (_selectedFile == null) return;

    _setState(UploadState.uploading);
    _uploadProgress = 0.0;
    _errorMessage = null;

    try {
      await _apiService.uploadFile(
        _selectedFile!,
        onProgress: (bytes, total) {
          if (total > 0) {
            _uploadProgress = bytes / total;
            notifyListeners();
          }
        },
      );

      _setState(UploadState.success);
      _fetchDockStatus(); // Fetch immediately after upload
      
      // Auto-clear success state after a few seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (_state == UploadState.success) {
          clearSelection();
        }
      });
      
    } catch (e) {
      _errorMessage = "Upload failed: \$e";
      _setState(UploadState.error);
    }
  }

  void _setState(UploadState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> downloadFromServer(String filename) async {
    _downloadingFile = filename;
    notifyListeners();

    try {
      // 1. Download to temporary cache first (no permissions needed)
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = "${tempDir.path}/$filename";
      
      await _apiService.downloadFile(filename, tempPath);

      // 2. Ask user where to save the file using the native Android picker
      final params = SaveFileDialogParams(sourceFilePath: tempPath, fileName: filename);
      final filePath = await FlutterFileDialog.saveFile(params: params);

      if (filePath != null) {
        _errorMessage = null; 
        // Success
      } else {
        _errorMessage = "Download canceled by user.";
      }
    } catch (e) {
      _errorMessage = "Failed to download $filename: $e";
    } finally {
      _downloadingFile = null;
      notifyListeners();
    }
  }

  Future<void> deleteFromServer(String filename) async {
    _deletingFile = filename;
    notifyListeners();

    try {
      await _apiService.deleteFile(filename);
      _errorMessage = null;
      await _fetchDockStatus(); // Refresh the list
    } catch (e) {
      _errorMessage = "Failed to delete $filename: $e";
    } finally {
      _deletingFile = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
