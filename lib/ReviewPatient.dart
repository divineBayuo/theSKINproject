//import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:skin_app/AddComment.dart';
import 'package:skin_app/MongoDBModel.dart';
import 'package:skin_app/dbHelper/mongodb.dart';
import 'dart:convert';
import 'dart:typed_data';
//import 'package:jwt_decoder/jwt_decoder.dart';

class ReviewPatient extends StatefulWidget {
  //final String token;
  const ReviewPatient({Key? key}) : super(key: key);

  @override
  State<ReviewPatient> createState() => _ReviewPatientState();
}

class _ReviewPatientState extends State<ReviewPatient> {
  Future<List<Map<String, dynamic>>>? futureData;
  //Future<List<Map<String, dynamic>>>? futureData1;

  // late String email;
  //late String name;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
    //_fetchrefData();
  }

  Future<void> _fetchData() async {
    futureData = MongoDatabase.getData();
    print('Fetching data...');
    setState(() {});
  }

  /* Future<void> _fetchrefData() async {
    setState(() {
      futureData1 = MongoDatabase.getData();
    });
  } */

  Future<void> _refreshData() async {
    await _fetchData();
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

  /* void _decodeToken() {
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    setState(() {
      email = jwtDecodedToken['email'] ?? 'Email not available';
      //name = jwtDecodedToken['name'] ?? 'Name not available';
    });
  } */

  // Convert the image to a base64 string
  /* String? imageBase64;
    if(image!=null){
      imageBase64 = await imageToBase64(image);
    } */

  // Convert the base64 string to an image
  /* Image? image;
  if(imageBase64 != null) {
    image = await Base64E
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade500,
      appBar: AppBar(
        title: const Text(
          'Review Patient',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder(
            future: futureData,
            builder: (context, AsyncSnapshot snapshot) {
              /* if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData || snapshot.data.isEmpty) {
                return const Center(
                  child: Text('No Data Available'),
                );
              } else {
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
              } */
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  var totalData = snapshot.data.length;
                  print('Total Data: $totalData' /* + totalData.toString() */);
                  return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Column(children: [
                          displayCard(
                              MongoDbModel.fromJson(snapshot.data[index])),
                          SizedBox(
                            height: 10.0,
                          )
                        ]);
                      });
                } else {
                  return Center(
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
      color: Colors.blue.shade100,
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "${data.id}",
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Full name: ${data.fullname}",
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
            ElevatedButton.icon(
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => /* const */
                            AddComment(
                                data: data,
                                onCommentAdded: (comment) {
                                  data.comment = comment;
                                  _showSnackbar('Comment updated successfully');
                                  _fetchData();
                                })));
              },
              label: const Text('Update Patient Card'),
              icon: const Icon(Icons.edit),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue.shade900,
                backgroundColor: Colors.white,
                elevation: 5.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
