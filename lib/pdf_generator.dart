import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';

Future<bool> generateAndSavePDF(
  String name,
  String dob,
  String email,
  List<Map<String, String>> educationList,
) async {
  try {
    final doc = pw.Document();

    doc.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('$name Resume', style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 10),
            pw.Text('Name:            $name'),
            pw.Text('Date of Birth: $dob'),
            pw.Text('Email:             $email'),
            pw.SizedBox(height: 20),
            pw.Text('Educational History', style: pw.TextStyle(fontSize: 18)),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(children: [
                  pw.Text('Institution'),
                  pw.Text('Degree'),
                  pw.Text('Year of Completion'),
                ]),
                ...educationList.map((education) => pw.TableRow(children: [
                      pw.Text(education['Institution'] ?? ''),
                      pw.Text(education['Degree'] ?? ''),
                      pw.Text(education['Year of Completion'] ?? ''),
                    ])),
              ],
            ),
          ],
        );
      },
    ));

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/Resume.pdf');
    await file.writeAsBytes(await doc.save());

    await Share.shareFiles([file.path]);

    return true;
  } catch (e) {
    print('Error generating PDF: $e');
    return false;
  }
}
