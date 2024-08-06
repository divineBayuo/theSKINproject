import 'package:flutter/material.dart';
import 'package:skin_app/MongoDBModel.dart';
import 'package:skin_app/dbHelper/mongodb.dart';
import 'dart:convert';
import 'dart:typed_data';
//import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
//import 'package:bson/bson.dart';
//import 'package:jwt_decoder/jwt_decoder.dart';

class PatientData extends StatefulWidget {
  const PatientData({super.key});

  @override
  State<PatientData> createState() => _PatientData();
}

class _PatientData extends State<PatientData> {
  Future<List<Map<String, dynamic>>>? futureData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
    //_decodeToken();
    _fetchrefData();
  }

  void _fetchData() {
    setState(() {
      futureData = MongoDatabase.getData();
    });
  }

  Future<void> _fetchrefData() async {
    setState(() {
      futureData = MongoDatabase.getData();
    });
  }

  Future<void> _refreshData() async {
    await _fetchrefData();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Function to convert base64 string to Uint8List
  Uint8List base64ToImage(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64: $e');
      return Uint8List(0);
    }
  }

  Future<void> _generatePdf(MongoDbModel data, String filename) async {
    final pdf = pw.Document();

    // Decode base64 image
    Uint8List? imageBytes;
    if (data.imageBase64 != null && data.imageBase64!.isNotEmpty) {
      try {
        imageBytes = base64Decode(data.imageBase64!);
        print('Decoded Bytes Length: ${imageBytes.length}');
      } catch (e) {
        print('Error decoding image: $e');
        imageBytes = null;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Patient ID: ${data.id.toHexString()}',
                    style: pw.TextStyle(
                        fontSize: 17, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Full Name: ${data.fullname}',
                    style: const pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 7),
                pw.Text('Location: ${data.location}'),
                pw.SizedBox(height: 7),
                pw.Text('DOB: ${data.dob}'),
                pw.SizedBox(height: 7),
                pw.Text('Sex: ${data.sex}'),
                pw.SizedBox(height: 7),
                pw.Text('Phone: ${data.phone}'),
                pw.SizedBox(height: 7),
                pw.Text('Emergency: ${data.emergency}'),
                pw.SizedBox(height: 7),
                pw.Text('Emergency Contact: ${data.emergentcontact}'),
                pw.SizedBox(height: 7),
                pw.Text('Mode of Detection: ${data.modeofdetection}'),
                pw.SizedBox(height: 7),
                pw.Text(
                    'Other Mode of Detection: ${data.othermodeofdetection}'),
                pw.SizedBox(height: 7),
                pw.Text('Classification of Lesion: ${data.classification}'),
                pw.SizedBox(height: 7),
                pw.Text('Duration before Reporting: ${data.duration}'),
                pw.SizedBox(height: 7),
                pw.Text('Date of Clinical Examination: ${data.dateofclinexam}'),
                pw.SizedBox(height: 7),
                pw.Text('Limitation of Movement: ${data.limitation}'),
                pw.SizedBox(height: 7),
                pw.Text('Number of Lesions: ${data.numberoflesions}'),
                pw.SizedBox(height: 7),
                pw.Text(
                    'Size of Biggest Lesion: ${data.diameter1} by ${data.diameter2} cm'),
                pw.SizedBox(height: 7),
                pw.Text('Type of Lesion: ${data.typeoflesion}'),
                pw.SizedBox(height: 7),
                pw.Text('Location of lesion: ${data.locationofswelling}'),
                pw.SizedBox(height: 10),
                if (imageBytes != null && imageBytes.isNotEmpty) ...[
                  pw.Container(
                    width: 200,
                    height: 200,
                    child: pw.Image(pw.MemoryImage(imageBytes),
                        fit: pw.BoxFit.cover),
                  ),
                ] else
                  pw.Text('No image data available or error decoding image.'),
                pw.SizedBox(height: 10),
                pw.Text('Clinical Suspicion: ${data.clinicalsuspicion}'),
                pw.SizedBox(height: 7),
                pw.Text('Other: ${data.other}'),
                pw.SizedBox(height: 7),
                pw.Text('Any Other Notes: ${data.anyother}'),
                pw.SizedBox(height: 10),
                pw.Text('Comments from Review: ${data.comment}'),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    // Save PDF file using Printing package
    Printing.sharePdf(bytes: bytes, filename: filename);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade500,
      appBar: AppBar(
        title: const Text(
          'Patient Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder(
            future: futureData,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  var totalData = snapshot.data.length;
                  print('Total Data: $totalData' /* + totalData.toString() */);
                  return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Column(children: [
                          displayCard(
                              MongoDbModel.fromJson(snapshot.data[index])),
                          const SizedBox(
                            height: 10.0,
                          )
                        ]);
                      });
                } else {
                  return const Center(
                    child: Text('No Data Available'),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget displayCard(MongoDbModel data) {
    // ignore: unused_local_variable
    Uint8List? imageBytes;
    if (data.imageBase64 != null && data.imageBase64!.isNotEmpty) {
      try {
        print('Decoding Base64: ${data.imageBase64}');
        imageBytes = base64ToImage(data.imageBase64!);
        print('Decoded Bytes Length: ${imageBytes.length}');
      } catch (e) {
        print('Error decoding image: $e');
      }
    }

    return Card(
        color: Colors.green.shade100,
        elevation: 3.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "${data.id}",
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Full name: ${data.fullname}",
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text("Location: ${data.location}"),
              const SizedBox(height: 10),
              Text("DOB: ${data.dob}"),
              const SizedBox(height: 10),
              Text("Sex: ${data.sex}"),
              const SizedBox(height: 10),
              Text("Phone: ${data.phone}"),
              const SizedBox(height: 10),
              Text("Emergency : ${data.emergency}"),
              const SizedBox(height: 10),
              Text("Emergency Contact: ${data.emergentcontact}"),
              const SizedBox(height: 10),
              Text("Mode of Detection: ${data.modeofdetection}"),
              const SizedBox(height: 10),
              Text("Other Mode of Detection: ${data.othermodeofdetection}"),
              const SizedBox(height: 10),
              Text("Classification of Lesion: ${data.classification}"),
              const SizedBox(height: 10),
              Text("Duration before Reporting: ${data.duration}"),
              const SizedBox(height: 10),
              Text("Date of Clinical Examination: ${data.dateofclinexam}"),
              const SizedBox(height: 10),
              Text("Limitation of Movement: ${data.limitation}"),
              const SizedBox(height: 10),
              Text("Number of Lesions: ${data.numberoflesions}"),
              const SizedBox(height: 10),
              Text(
                  "Size of Biggest Lesion: ${data.diameter1} by ${data.diameter2}"),
              const SizedBox(height: 10),
              Text("Type of Lesion: ${data.typeoflesion}"),
              const SizedBox(height: 10),
              Text("Location of Lesion: ${data.locationofswelling}"),
              const SizedBox(height: 10),
              if (imageBytes != null && imageBytes.isNotEmpty)
                Image.memory(
                  imageBytes,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, StackTrace) {
                    return const Text('Error displaying image');
                  },
                )
              else
                const Text('No image data available'),
              const SizedBox(height: 10),
              Text(
                  "Image: ${data.imageBase64 != null ? 'Image displayed above' : 'No image available'}"),
              const SizedBox(height: 10),
              Text("Clinical Suspicion: ${data.clinicalsuspicion}"),
              const SizedBox(height: 10),
              Text("Other: ${data.other}"),
              const SizedBox(height: 10),
              Text("Any Other Notes: ${data.anyother}"),
              const SizedBox(height: 10),
              Text("Comments from Review: ${data.comment}"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      bool confirmed = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Download'),
                            content: Text(
                                "Download Patient Card of: ${data.fullname}?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Download'),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmed) {
                        try {
                          String filename =
                              'SKiNAPPpatient_${data.id.toHexString()}.pdf';
                          await _generatePdf(data, filename);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('PDF Successfully Generated!')),
                          );
                        } catch (e) {
                          print('Error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error generating PDF: $e')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green.shade900,
                        elevation: 5.0),
                    child: const Icon(Icons.download),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        bool confirmed = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text(
                                  "Are you sure you want to delete this patient card?"),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: const Text("Delete"),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmed) {
                          try {
                            await MongoDatabase.delete(data.id.oid);
                            _fetchData();
                            //setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Patient Card Successfully Deleted!')),
                            );
                          } catch (e) {
                            print('Error: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red.shade900,
                          elevation: 5.0),
                      child: const Icon(Icons.delete))
                ],
              ),
            ],
          ),
        ));
  }
}
