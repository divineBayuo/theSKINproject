import 'dart:convert';

import 'package:skin_app/MongoDBModel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> _generatePdf(MongoDbModel data) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Patient ID: ${data.id.toHexString()}',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Full Name: ${data.fullname}',
                style: pw.TextStyle(fontSize: 18)),
            pw.Text('Location: ${data.location}'),
            pw.Text('DOB: ${data.dob}'),
            pw.Text('Sex: ${data.sex}'),
            pw.Text('Phone: ${data.phone}'),
            pw.Text('Emergency: ${data.emergency}'),
            pw.Text('Emergency Contact: ${data.emergentcontact}'),
            pw.Text('Mode of Detection: ${data.modeofdetection}'),
            pw.Text('Other Mode of Detection: ${data.othermodeofdetection}'),
            pw.Text('Classification of Lesion: ${data.classification}'),
            pw.Text('Duration before Reporting: ${data.duration}'),
            pw.Text('Date of Clinical Examination: ${data.dateofclinexam}'),
            pw.Text('Limitation of Movement: ${data.limitation}'),
            pw.Text('Number of Lesions: ${data.numberoflesions}'),
            pw.Text(
                'Size of Biggest Lesion: ${data.diameter1} by ${data.diameter2} cm'),
            pw.Text('Type of Lesion: ${data.typeoflesion}'),
            pw.Text('Location of lesion: ${data.locationofswelling}'),
            if (data.imageBase64 != null && data.imageBase64!.isNotEmpty)
              pw.Image(pw.MemoryImage(base64Decode(data.imageBase64!))),
            pw.Text('Clinical Suspicion: ${data.clinicalsuspicion}'),
            pw.Text('Other: ${data.other}'),
            pw.Text('Any Other Notes: ${data.anyother}'),
            pw.SizedBox(height: 20),
            pw.Text('Comments from Review: ${data.comment}'),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}
