import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/upload_provider.dart';
import '../widgets/file_card.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UploadProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dock File Sender'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error Banner
              if (provider.errorMessage != null && provider.state == UploadState.error) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade900),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Success Banner
              if (provider.state == UploadState.success) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green.shade900),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Upload completed successfully!",
                          style: TextStyle(color: Colors.green.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Picked File Card
              if (provider.selectedFile != null) ...[
                FileCard(
                  file: provider.selectedFile!,
                  onClear: () {
                    if (provider.state != UploadState.uploading) {
                      provider.clearSelection();
                    }
                  },
                ),
                const SizedBox(height: 24),
              ] else if (provider.state != UploadState.success && provider.state != UploadState.uploading) ...[
                // Pick File Button (only show if no file is selected and not uploading/success)
                OutlinedButton.icon(
                  onPressed: provider.state == UploadState.pickingFile ? null : () => provider.pickFile(),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select File'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Upload Progress
              if (provider.state == UploadState.uploading) ...[
                Column(
                  children: [
                    const SpinKitPulse(
                      color: Colors.blueAccent,
                      size: 50.0,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: provider.uploadProgress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\${(provider.uploadProgress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Uploading file...'),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Upload Action Button
              if (provider.selectedFile != null && provider.state != UploadState.uploading) ...[
                ElevatedButton(
                  onPressed: () => provider.uploadFile(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Upload to Dock', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 24),
              ],

              const Divider(),
              const SizedBox(height: 16),

              // Dock Status UI
              const Text(
                'Currently on Dock Device:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: provider.dockFiles.isEmpty
                    ? const Center(
                        child: Text(
                          'No files currently on dock.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.dockFiles.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.insert_drive_file_outlined),
                            title: Text(provider.dockFiles[index]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
