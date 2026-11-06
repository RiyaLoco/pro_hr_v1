import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/data/models/res/leave_request_models.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/leave_attachment_view.dart';

void main() {
  test(
    'web-created requests preserve explicit URL and fall back to disk key',
    () {
      const raw = 'leave-requests/medical-report.pdf';
      final explicit = LeaveRequest.fromJson({
        'attachment': raw,
        'attachment_url': 'https://files.example.com/medical-report.pdf',
      });
      expect(
        explicit.attachmentUrl,
        'https://files.example.com/medical-report.pdf',
      );
      for (final missingUrl in [null, '', '  ', 'null']) {
        final request = LeaveRequest.fromJson({
          'attachment': raw,
          'attachment_url': missingUrl,
        });
        expect(request.attachmentUrl, raw);
        expect(
          AppUrlService.attachmentUrl(request.attachmentUrl!),
          '${Uri.parse(AppUrlService.baseUrl).origin}/storage/$raw',
        );
      }
      expect(LeaveRequest.fromJson({'attachment': null}).attachmentUrl, isNull);
    },
  );

  testWidgets('web PDF is shown as an openable file row on mobile', (
    tester,
  ) async {
    final request = LeaveRequest.fromJson({
      'attachment': 'leave-requests/Medical Report.PDF',
      'attachment_url':
          'http://localhost:8000/storage/leave-requests/Medical%20Report.PDF?download=1',
    });
    final url = AppUrlService.attachmentUrl(request.attachmentUrl!);
    expect(Uri.parse(url).host, Uri.parse(AppUrlService.baseUrl).host);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LeaveAttachmentView(url: url)),
      ),
    );
    expect(find.text('Medical Report.PDF'), findsOneWidget);
    expect(find.text('Tap to open PDF'), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
