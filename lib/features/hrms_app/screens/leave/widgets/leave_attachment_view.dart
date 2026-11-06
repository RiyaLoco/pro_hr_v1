import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LeaveAttachmentView extends StatelessWidget {
  final String url;

  const LeaveAttachmentView({super.key, required this.url});

  bool get _isImage {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    return ['.jpg', '.jpeg', '.png', '.webp'].any(path.endsWith);
  }

  bool get _isPdf =>
      Uri.tryParse(url)?.path.toLowerCase().endsWith('.pdf') == true;

  String get _fileName {
    final segments = Uri.tryParse(url)?.pathSegments ?? const [];
    return segments.isEmpty ? 'Attachment' : segments.last;
  }

  @override
  Widget build(BuildContext context) {
    return _isImage ? _buildImage(context) : _buildFileTile();
  }

  Widget _buildImage(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _openFullscreen(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 170,
            height: 200,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, _, _) => Container(
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: PColor.textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileTile() {
    return InkWell(
      onTap: _openExternally,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PColor.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(
              _isPdf
                  ? Icons.picture_as_pdf_outlined
                  : Icons.description_outlined,
              color: PColor.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: PColor.textColor),
                  ),
                  if (_isPdf) const Text('Tap to open PDF'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new, size: 18, color: PColor.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternally() async {
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw Exception('Could not open file');
    } catch (_) {
      Get.snackbar('Error', 'Could not open this file.');
    }
  }

  void _openFullscreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(child: Image.network(url, fit: BoxFit.contain)),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
