import 'dart:io';
import 'package:flutter/material.dart';

class FileCard extends StatelessWidget {
  final File file;
  final VoidCallback onClear;

  const FileCard({Key? key, required this.file, required this.onClear}) : super(key: key);

  String _formatSize(int bytes) {
    if (bytes < 1024) return '\$bytes B';
    if (bytes < 1024 * 1024) return '\${(bytes / 1024).toStringAsFixed(1)} KB';
    return '\${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final fileName = file.uri.pathSegments.last;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, size: 40, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: FutureBuilder<int>(
                future: file.length(),
                builder: (context, snapshot) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.hasData ? _formatSize(snapshot.data!) : 'Calculating...',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: onClear,
            ),
          ],
        ),
      ),
    );
  }
}
