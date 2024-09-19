import 'dart:convert';
import 'package:skin_app/MongoDBModel.dart';
//import 'package:skin_app/PatientData.dart';
import 'package:skin_app/dbHelper/mongodb.dart';
import './MyHomePage.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:skin_app/services/api.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mongo_dart/mongo_dart.dart' as M;
import 'generateID.dart';

class AddPatient extends StatefulWidget {
  const AddPatient({super.key});

  @override
  State<AddPatient> createState() => _AddPatientState();
}

class _AddPatientState extends State<AddPatient> {
  final _formKey = GlobalKey<FormState>();
  String? _currentLocation = '';
  final TextEditingController _IDNumberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _diameterofBiggestLesion1Controller =
      TextEditingController();
  final TextEditingController _diameterofBiggestLesion2Controller =
      TextEditingController();
  final TextEditingController _emergencyContactNameController =
      TextEditingController();
  final TextEditingController _numberofLesionsController =
      TextEditingController();
  final TextEditingController _durationofSicknessController =
      TextEditingController();
  final TextEditingController _otherclinicalSuspicionController =
      TextEditingController();
  final TextEditingController _anyOtherNotesController =
      TextEditingController();
  final TextEditingController _otherModeofDetectionController =
      TextEditingController();

  //var _checkInsertUpdate = "Insert";

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _IDNumberController.text = generateUniqueID();
  }

  String generateUniqueID() {
    return PatientIdGenerator.generatePatientId();
    //return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _fetchLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    if (!mounted) return;

    setState(() {
      _currentLocation =
          '(${locationData.latitude}, ${locationData.longitude})';
    });
  }

  @override
  void dispose() {
    // Cancel any timers or listeners here
    // Properly dispose of controllers and other resources
    _IDNumberController.dispose();
    _fullNameController.dispose();
    _diameterofBiggestLesion1Controller.dispose();
    _diameterofBiggestLesion2Controller.dispose();
    _emergencyContactNameController.dispose();
    _numberofLesionsController.dispose();
    _durationofSicknessController.dispose();
    _otherclinicalSuspicionController.dispose();
    _anyOtherNotesController.dispose();
    _otherModeofDetectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Patient',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        //height: MediaQuery.of(context).size.height / 1.5,
        //width: MediaQuery.of(context).size.height / 1.5,
        child: patientDataForm(
          formKey: _formKey,
          currentLocation: _currentLocation,
          IDNumberController: _IDNumberController,
          fullNameController: _fullNameController,
          diameterofBiggestLesion1: _diameterofBiggestLesion1Controller,
          diameterofBiggestLesion2: _diameterofBiggestLesion2Controller,
          emergencyContactNameController: _emergencyContactNameController,
          numberofLesionsController: _numberofLesionsController,
          durationofSicknessController: _durationofSicknessController,
          otherclinicalSuspicion: _otherclinicalSuspicionController,
          anyOtherNotes: _anyOtherNotesController,
          otherModeofDetection: _otherModeofDetectionController,
          //textEditingController: _textEditingControllerFullName,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class patientDataForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  String? currentLocation;
  final TextEditingController IDNumberController;
  final TextEditingController fullNameController;
  final TextEditingController otherModeofDetection;
  final TextEditingController diameterofBiggestLesion1;
  final TextEditingController diameterofBiggestLesion2;
  final TextEditingController numberofLesionsController;
  final TextEditingController durationofSicknessController;
  final TextEditingController emergencyContactNameController;
  final TextEditingController otherclinicalSuspicion;
  final TextEditingController anyOtherNotes;

  patientDataForm(
      {super.key,
      //required this.textEditingController,
      required this.formKey,
      required this.IDNumberController,
      required this.fullNameController,
      required this.emergencyContactNameController,
      required this.diameterofBiggestLesion1,
      required this.diameterofBiggestLesion2,
      required this.durationofSicknessController,
      required this.numberofLesionsController,
      required this.otherModeofDetection,
      required this.otherclinicalSuspicion,
      required this.anyOtherNotes,
      this.currentLocation});

  @override
  State<patientDataForm> createState() => _patientDataFormState();
}

class _patientDataFormState extends State<patientDataForm> {
  //final _formKey = GlobalKey<FormState>();
  String? _selectedSex;
  String? _modeofDetection;
  //String? _locationofLesion;
  //String? _typeofLesion;
  String? _classificationofPatient;
  String? _limitationofMovement;
  //String? _clinicalSuspicion;
  DateTime? _selectedDate1, _selectedDate2;
  final TextEditingController _phoneNumberController1 = TextEditingController();
  final TextEditingController _phoneNumberController2 = TextEditingController();

  final List<String> _clinicalSuspicion = [];
  final List<String> _locationofLesion = [];
  final List<String> _typeofLesion = [];

  File? _imageFile;

  Future<void> selectImage(ImageSource source) async {
    final imageFile = await ImagePicker().pickImage(source: source);

    if (imageFile != null) {
      setState(() {
        _imageFile = File(imageFile.path);
      });
    }
  }

  void printSubmissionDetails() {
    print(
        'ID: ${widget.IDNumberController.text}\nfullname: ${widget.fullNameController.text}\nlocation: ${widget.currentLocation}\nDOB: $_selectedDate1\nsex: $_selectedSex\nphone: ${_phoneNumberController1.text}\nEm. Name: ${widget.emergencyContactNameController.text}\nEm. Contact: ${_phoneNumberController2.text}\nmode of detection: $_modeofDetection\nother: ${widget.otherModeofDetection.text}\nclassification of patient: $_classificationofPatient\nduration of sickness: ${widget.durationofSicknessController.text}\ndate of appointment: $_selectedDate2\nlimitation of movement: $_limitationofMovement\nnumber of lesions: ${widget.numberofLesionsController.text}\ndiameter of biggest lesion: ${widget.diameterofBiggestLesion1.text} by ${widget.diameterofBiggestLesion2.text}\ntype of lesion: $_typeofLesion\nlocation of lesion: $_locationofLesion\nclinical suspicion: $_clinicalSuspicion\nother: ${widget.otherclinicalSuspicion.text}\nany other notes: ${widget.anyOtherNotes.text}\n');
  }

  void submitPatientData() async {
    Map<String, String> data = {
      'ID': widget.IDNumberController.text,
      'fullName': widget.fullNameController.text,
      'location': widget.currentLocation ?? '',
      'DOB': _selectedDate1?.toIso8601String() ?? '',
      'sex': _selectedSex ?? '',
      'phone': _phoneNumberController1.text,
      'emergencyContactName': widget.emergencyContactNameController.text,
      'emergencyContact': _phoneNumberController2.text,
      'modeOfDetection': _modeofDetection ?? '',
      'otherModeOfDetection': widget.otherModeofDetection.text,
      'classificationOfPatient': _classificationofPatient ?? '',
      'durationOfSickness': widget.durationofSicknessController.text,
      'dateOfAppointment': _selectedDate2?.toIso8601String() ?? '',
      'limitationOfMovement': _limitationofMovement ?? '',
      'numberOfLesions': widget.numberofLesionsController.text,
      'diameterOfBiggestLesion':
          '${widget.diameterofBiggestLesion1.text} by ${widget.diameterofBiggestLesion2.text}',
      'typeOfLesion': _typeofLesion.join(', '),
      'locationOfLesion': _locationofLesion.join(', '),
      'clinicalSuspicion': _clinicalSuspicion.join(', '),
      'otherClinicalSuspicion': widget.otherclinicalSuspicion.text,
      'anyOtherNotes': widget.anyOtherNotes.text,
    };

    File? imageFile =
        _imageFile; // Get your image file here, e.g., from an image picker

    if (imageFile != null && await imageFile.exists()) {
      bool result = await Api.addPatient(data, imageFile);

      if (result) {
        // Successfully submitted
        print("Data submitted successfully.");
      } else {
        // Submission failed
        print("Failed to submit data.");
      }
    } else {
      print("No image selected or file does not exist.");
    }
  }

  Future<void> createPatient(BuildContext context) async {
    final uri = Uri.parse('http://localhost:3000/api/patient'); //backend point

    //Form data
    Map<String, String> patientData = {
      'ID': widget.IDNumberController.text,
      'fullName': widget.fullNameController.text,
      'location': widget.currentLocation ?? '',
      'DOB': _selectedDate1?.toIso8601String() ?? '',
      'sex': _selectedSex ?? '',
      'phone': _phoneNumberController1.text,
      'emergencyContactName': widget.emergencyContactNameController.text,
      'emergencyContact': _phoneNumberController2.text,
      'modeOfDetection': _modeofDetection ?? '',
      'otherModeOfDetection': widget.otherModeofDetection.text,
      'classificationOfPatient': _classificationofPatient ?? '',
      'durationOfSickness': widget.durationofSicknessController.text,
      'dateOfAppointment': _selectedDate2?.toIso8601String() ?? '',
      'limitationOfMovement': _limitationofMovement ?? '',
      'numberOfLesions': widget.numberofLesionsController.text,
      'diameterOfBiggestLesion':
          '${widget.diameterofBiggestLesion1.text} by ${widget.diameterofBiggestLesion2.text}',
      'typeOfLesion': _typeofLesion.join(', '),
      'locationOfLesion': _locationofLesion.join(', '),
      'clinicalSuspicion': _clinicalSuspicion.join(', '),
      'otherClinicalSuspicion': widget.otherclinicalSuspicion.text,
      'anyOtherNotes': widget.anyOtherNotes.text,
    };

    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? token = prefs.getString('token');

    /* if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not authenticated.')),
      );
      return;
    } */

    //Prepare the request
    var request = http.MultipartRequest('POST', uri);
    patientData.forEach((key, value) {
      request.fields[key] = value;
    });

    //Add image while available
    if (_imageFile != null) {
      var mimeTypeData = lookupMimeType(_imageFile!.path)!.split('/');
      var file = await http.MultipartFile.fromPath(
        'file',
        _imageFile!.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      );
      request.files.add(file);
    }

    //request.headers['Authorization'] = 'Bearer $token';

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        //Successfully created the patient
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data Submitted Successfully!')),
        );
      } else {
        //Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit data.')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occured: $e')),
      );
    }
  }

  final _checkInsertUpdate = "Insert Patient Data";

  @override
  Widget build(BuildContext context) {
    /* final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is! MongoDbModel) {
      // Handle the case where arguments are null or not of type MongoDbModel
      return Center(
        child: Text('Invalid arguments'),
      );
    }

    MongoDbModel data = arguments as MongoDbModel;
    //widget.IDNumberController.text = data._id;
    widget.fullNameController.text = data.fullname;
    widget.currentLocation = data.location;
    _selectedDate1 = data.dob as DateTime?;
    _selectedSex = data.sex;
    _phoneNumberController1.text = data.phone;
    widget.emergencyContactNameController.text = data.emergency;
    _phoneNumberController2.text = data.emergentcontact;
    _modeofDetection = data.modeofdetection;
    widget.otherModeofDetection.text = data.othermodeofdetection;
    _classificationofPatient = data.classification;
    widget.durationofSicknessController.text = data.duration;
    _selectedDate2 = data.dateofclinexam as DateTime?;
    _limitationofMovement = data.limitation;
    widget.numberofLesionsController.text = data.numberoflesions;
    widget.diameterofBiggestLesion1.text = data.diameter1;
    widget.diameterofBiggestLesion2.text = data.diameter2;
    _typeofLesion = data.typeoflesion;
    _locationofLesion = data.locationofswelling;
    _imageFile = data.imageBase64 as File?;
    _clinicalSuspicion = data.clinicalsuspicion;
    widget.otherclinicalSuspicion.text = data.other;
    widget.anyOtherNotes.text = data.anyother;
    _checkInsertUpdate = "Update Patient Data"; */

    return ListView(
      children: [
        Form(
          key: widget.formKey,
          child: Column(
            children: <Widget>[
              Text(_checkInsertUpdate),
              const Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                readOnly: true,
                controller: widget.IDNumberController,
                decoration: InputDecoration(
                  labelText: 'ID Number',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: widget.fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                    text: widget.currentLocation != null
                        ? "${widget.currentLocation}"
                        : ''),
                decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    suffixIcon: const Icon(Icons.my_location)),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedDate1 != null
                      ? "${_selectedDate1!.day}/${_selectedDate1!.month}/${_selectedDate1!.year}"
                      : '',
                ),
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final selectedDate1 = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDate1 != null) {
                        setState(
                          () {
                            _selectedDate1 = selectedDate1;
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Sex',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                value: _selectedSex,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSex = newValue;
                  });
                },
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _phoneNumberController1,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ('Please enter a valid phone number.');
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'In case of emergency',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: widget.emergencyContactNameController,
                decoration: InputDecoration(
                  labelText: 'Contact Name',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _phoneNumberController2,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ('Please enter a valid phone number.');
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Contact\'s Phone Number',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 45.0),
              const Text(
                'History At Admission',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Mode of Detection',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                value: _modeofDetection,
                onChanged: (String? newValue) {
                  setState(() {
                    _modeofDetection = newValue;
                  });
                },
                items:
                    <String>['Active Screening', 'Passive/Voluntary', 'Other']
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: widget.otherModeofDetection,
                decoration: InputDecoration(
                  labelText: 'State if other:',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Classification of Patient',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                value: _classificationofPatient,
                onChanged: (String? newValue) {
                  setState(() {
                    _classificationofPatient = newValue;
                  });
                },
                items: <String>['New', 'Recurrent/Relapse']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: widget.durationofSicknessController,
                decoration: InputDecoration(
                  labelText: 'Duration of Sickness before Seeking Healthcare',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 45.0),
              const Text(
                'Initial Clinical Examination',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                    text: _selectedDate2 != null
                        ? '${_selectedDate2!.day}/${_selectedDate2!.month}/${_selectedDate2!.year}'
                        : ''),
                decoration: InputDecoration(
                  labelText: 'Date of Clinical Examination',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final selectDate2 = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (selectDate2 != null) {
                        setState(
                          () {
                            _selectedDate2 = selectDate2;
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Limitation of Movement',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                value: _limitationofMovement,
                onChanged: (String? newValue) {
                  setState(() {
                    _limitationofMovement = newValue;
                  });
                },
                items: <String>['Yes', 'No']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: widget.numberofLesionsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Number of Lesions',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              Row(children: [
                const Text('Diameter of \nBiggest Lesion'),
                const SizedBox(width: 10.0),
                Flexible(
                  child: TextFormField(
                    controller: widget.diameterofBiggestLesion1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5.0),
                const Text('cm /'),
                const SizedBox(width: 5.0),
                Flexible(
                  child: TextFormField(
                    controller: widget.diameterofBiggestLesion2,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5.0),
                const Text('cm'),
              ]),
              const SizedBox(height: 45.0),
              const Text('Type of Lesion(s) / Swelling'),
              Row(
                children: [
                  Flexible(
                    child: Column(
                      children: <Widget>[
                        CheckboxListTile(
                          title: const Text('Macule (M)'),
                          value: _typeofLesion.contains('Macule (M)'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _typeofLesion.add('Macule (M)');
                              } else {
                                _typeofLesion.remove('Macule (M)');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Oedema (E)'),
                          value: _typeofLesion.contains('Oedema (E)'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _typeofLesion.add('Oedema (E)');
                              } else {
                                _typeofLesion.remove('(Oedema (E)');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Papilloma (Pa)'),
                          value: _typeofLesion.contains('Papilloma (Pa)'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _typeofLesion.add('Papilloma (Pa)');
                              } else {
                                _typeofLesion.remove('Papilloma (Pa)');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Plaque (Q)'),
                          value: _typeofLesion.contains('Plaque (Q)'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _typeofLesion.add('Plaque (Q)');
                              } else {
                                _typeofLesion.remove('Plaque (Q)');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Ulcer (U)'),
                          value: _typeofLesion.contains('Ulcer (U)'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _typeofLesion.add('Ulcer (U)');
                              } else {
                                _typeofLesion.remove('Ulcer (U)');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Flexible(
                    child: Column(children: <Widget>[
                      CheckboxListTile(
                        title: const Text('Nodule (N)'),
                        value: _typeofLesion.contains('Nodule (N)'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _typeofLesion.add('Nodule (N)');
                            } else {
                              _typeofLesion.remove('Nodule (N)');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Osteomyelitis (O)'),
                        value: _typeofLesion.contains('Osteomyelitis (O)'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _typeofLesion.add('Osteomyelitis (O)');
                            } else {
                              _typeofLesion.remove('Osteomyelitis (O)');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Papule (P)'),
                        value: _typeofLesion.contains('Papule (P)'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _typeofLesion.add('Papule (P)');
                            } else {
                              _typeofLesion.remove('Papule (P)');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Skin Patches (S)'),
                        value: _typeofLesion.contains('Skin Patches (S)'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _typeofLesion.add('Skin Patches (S)');
                            } else {
                              _typeofLesion.remove('Skin Patches (S)');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Vesicles (V)'),
                        value: _typeofLesion.contains('Vesicles (V)'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _typeofLesion.add('Vesicles (V)');
                            } else {
                              _typeofLesion.remove('Vesicles (V)');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 45.0),
              const Text('Location of Lesion(s) or Swelling'),
              Row(
                children: [
                  Flexible(
                    child: Column(
                      children: <Widget>[
                        CheckboxListTile(
                          title: const Text('Abdomen (AB)'),
                          value: _locationofLesion.contains('Abdomen (AB)'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _locationofLesion.add('Abdomen (AB)');
                              } else {
                                _locationofLesion.remove('Abdomen (AB)');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Breast (BR)'),
                          value: _locationofLesion.contains('Breast (BR)'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _locationofLesion.add('Breast (BR)');
                              } else {
                                _locationofLesion.remove('Breast (BR)');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Buttocks/Perineum (BP)'),
                          value: _locationofLesion
                              .contains('Buttocks/Perineum (BP)'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _locationofLesion.add('Buttocks/Perineum (BP)');
                              } else {
                                _locationofLesion
                                    .remove('Buttocks/Perineum (BP)');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Toe'),
                          value: _locationofLesion.contains('Toe'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _locationofLesion.add('Toe');
                              } else {
                                _locationofLesion.remove('Toe');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Face'),
                          value: _locationofLesion.contains('Face'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _locationofLesion.add('Face');
                              } else {
                                _locationofLesion.remove('Face');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Upper Limb (UL)'),
                          value: _locationofLesion.contains('Upper Limb (UL)'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _locationofLesion.add('Upper Limb (UL)');
                              } else {
                                _locationofLesion.remove('Upper Limb (UL)');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Genitalia'),
                          value: _locationofLesion.contains('Genitalia'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                _locationofLesion.add('Genitalia');
                              } else {
                                _locationofLesion.remove('Genitalia');
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Flexible(
                    child: Column(children: <Widget>[
                      CheckboxListTile(
                        title: const Text('Back (BK)'),
                        value: _locationofLesion.contains('Back (BK)'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _locationofLesion.add('Back (BK)');
                            } else {
                              _locationofLesion.remove('Back (BK)');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Thorax'),
                        value: _locationofLesion.contains('Thorax'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _locationofLesion.add('Thorax');
                            } else {
                              _locationofLesion.remove('Thorax');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Eye'),
                        value: _locationofLesion.contains('Eye'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _locationofLesion.add('Eye');
                            } else {
                              _locationofLesion.remove('Eye');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Ear'),
                        value: _locationofLesion.contains('Ear'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _locationofLesion.add('Ear');
                            } else {
                              _locationofLesion.remove('Ear');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Lower Limb (LL)'),
                        value: _locationofLesion.contains('Lower Limb (LL)'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _locationofLesion.add('Lower Limb (LL)');
                            } else {
                              _locationofLesion.remove('Lower Limb (LL)');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Finger'),
                        value: _locationofLesion.contains('Finger'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _locationofLesion.add('Finger');
                            } else {
                              _locationofLesion.remove('Finger');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Inguinal/Groin'),
                        value: _locationofLesion.contains('Inguinal/Groin'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value!) {
                              _locationofLesion.add('Inguinal/Groin');
                            } else {
                              _locationofLesion.remove('Inguinal/Groin');
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Text(
                      'Click button to take picture of lesion/swelling.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    _imageFile != null
                        ? Image.file(_imageFile!)
                        : const Placeholder(),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () => selectImage(ImageSource.camera),
                      child: const Text(
                        'Take picture',
                        style: TextStyle(color: Colors.brown),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => selectImage(ImageSource.gallery),
                      child: const Text(
                        'Select picture',
                        style: TextStyle(color: Colors.brown),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 45.0),
              const Text(
                'Clinical Suspicion',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              Container(
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('BU'),
                      value: _clinicalSuspicion.contains('BU'),
                      //groupValue: _clinicalSuspicion,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value!) {
                            _clinicalSuspicion.add('BU');
                          } else {
                            _clinicalSuspicion.remove('BU');
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('CL'),
                      value: _clinicalSuspicion.contains('CL'),
                      //groupValue: _clinicalSuspicion,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value!) {
                            _clinicalSuspicion.add('CL');
                          } else {
                            _clinicalSuspicion.remove('CL');
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Leprosy'),
                      value: _clinicalSuspicion.contains('Leprosy'),
                      //groupValue: _clinicalSuspicion,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value!) {
                            _clinicalSuspicion.add('Leprosy');
                          } else {
                            _clinicalSuspicion.remove('Leprosy');
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Lymphatic Filariasis'),
                      value:
                          _clinicalSuspicion.contains('Lymphatic Filariasis'),
                      //groupValue: _clinicalSuspicion,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value!) {
                            _clinicalSuspicion.add('Lymphatic Filariasis');
                          } else {
                            _clinicalSuspicion.remove('Lymphatic Filariasis');
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Yaws'),
                      value: _clinicalSuspicion.contains('Yaws'),
                      //groupValue: _clinicalSuspicion,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value!) {
                            _clinicalSuspicion.add('Yaws');
                          } else {
                            _clinicalSuspicion.remove('Yaws');
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Other'),
                      value: _clinicalSuspicion.contains('Other'),
                      //groupValue: _clinicalSuspicion,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value!) {
                            _clinicalSuspicion.add('Other');
                          } else {
                            _clinicalSuspicion.remove('Other');
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: widget.otherclinicalSuspicion,
                decoration: InputDecoration(
                  labelText: 'State if other:',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: widget.anyOtherNotes,
                decoration: InputDecoration(
                  labelText: 'Any other notes:',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Submission'),
                        content: const Text('Are you sure you want to submit?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              //Toast.show("Data Submitted!");
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              /*   if (_checkInsertUpdate == "Update Patient Data") {
                                _updateData(
                                    data.id,
                                    data.fullname,
                                    data.location,
                                    data.dob,
                                    data.sex,
                                    data.phone,
                                    data.emergency,
                                    data.emergentcontact,
                                    data.modeofdetection,
                                    data.othermodeofdetection,
                                    data.classification,
                                    data.duration,
                                    data.dateofclinexam,
                                    data.limitation,
                                    data.numberoflesions,
                                    data.diameter1,
                                    data.diameter2,
                                    data.typeoflesion,
                                    data.locationofswelling,
                                    data.imageBase64,
                                    data.clinicalsuspicion,
                                    data.other,
                                    data.anyother);
                              } else { */
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MyHomePage()));
                              //Send data submitted to DB, print data;
                              //createPatient(context, this);
                              printSubmissionDetails();
                              /* submitPatientData();
                              createPatient(context); */
                              _insertData(
                                  widget.fullNameController.text,
                                  widget.currentLocation.toString(),
                                  _selectedDate1.toString(),
                                  _selectedSex.toString(),
                                  _phoneNumberController1.text,
                                  widget.emergencyContactNameController.text,
                                  _phoneNumberController2.text,
                                  _modeofDetection.toString(),
                                  widget.otherModeofDetection.text,
                                  _classificationofPatient.toString(),
                                  widget.durationofSicknessController.text,
                                  _selectedDate2.toString(),
                                  _limitationofMovement.toString(),
                                  widget.numberofLesionsController.text,
                                  widget.diameterofBiggestLesion1.text,
                                  widget.diameterofBiggestLesion2.text,
                                  _typeofLesion,
                                  _locationofLesion,
                                  _imageFile,
                                  _clinicalSuspicion,
                                  widget.otherclinicalSuspicion.text,
                                  widget.anyOtherNotes.text);
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.brown)),
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ),
              /*  OutlinedButton(
                  onPressed: () {
                  //  _fakeData();
                  },
                  child: Text('Generate Data')) */
            ],
          ),
        ),
      ],
    );
  }

  /* Future<void> _updateData(
      M.ObjectId id,
      String fullname,
      String location,
      String dob,
      String sex,
      String phone,
      String emergency,
      String emergentcontact,
      String modeofdetection,
      String othermodeofdetection,
      String classification,
      String duration,
      String dateofclinexam,
      String limitation,
      String numberoflesions,
      String diameter1,
      String diameter2,
      List<String> typeoflesion,
      List<String> locationofswelling,
      String? imageBase64,
      List<String> clinicalsuspicion,
      String other,
      String anyother) async {
    // Convert the image to base64 if it's not null
    /* String? imageBase64;
      if (image != null) {
        final bytes = await image.readAsBytes();
        imageBase64 = base64Encode(bytes);
      } */

    final updateData = MongoDbModel(
        id: id,
        fullname: fullname,
        location: location,
        dob: dob,
        sex: sex,
        phone: phone,
        emergency: emergency,
        emergentcontact: emergentcontact,
        modeofdetection: modeofdetection,
        othermodeofdetection: othermodeofdetection,
        classification: classification,
        duration: duration,
        dateofclinexam: dateofclinexam,
        limitation: limitation,
        numberoflesions: numberoflesions,
        diameter1: diameter1,
        diameter2: diameter2,
        typeoflesion: typeoflesion,
        locationofswelling: locationofswelling,
        imageBase64: imageBase64,
        clinicalsuspicion: clinicalsuspicion,
        other: other,
        anyother: anyother);

    await MongoDatabase.update(updateData)
        .whenComplete(() => Navigator.pop(context));
  }
 */
  Future<void> _insertData(
      String fullname,
      String location,
      String dob,
      String sex,
      String phone,
      String emergency,
      String emergentcontact,
      String modeofdetection,
      String othermodeofdetection,
      String classification,
      String duration,
      String dateofclinexam,
      String limitation,
      String numberoflesions,
      String diameter1,
      String diameter2,
      List<String> typeoflesion,
      List<String> locationofswelling,
      File? image,
      List<String> clinicalsuspicion,
      String other,
      String anyother) async {
    var id = M.ObjectId();

    // Convert the image to a base64 string
    String? imageBase64;
    if (image != null) {
      imageBase64 = await imageToBase64(image);
    }

    final data = MongoDbModel(
        id: id,
        fullname: fullname,
        location: location,
        dob: dob,
        sex: sex,
        phone: phone,
        emergency: emergency,
        emergentcontact: emergentcontact,
        modeofdetection: modeofdetection,
        othermodeofdetection: othermodeofdetection,
        classification: classification,
        duration: duration,
        dateofclinexam: dateofclinexam,
        limitation: limitation,
        numberoflesions: numberoflesions,
        diameter1: diameter1,
        diameter2: diameter2,
        typeoflesion: typeoflesion,
        locationofswelling: locationofswelling,
        imageBase64: imageBase64,
        clinicalsuspicion: clinicalsuspicion,
        other: other,
        anyother: anyother);
    try {
      // ignore: unused_local_variable
      var result = await MongoDatabase.insert(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inserted patient ID${id.toHexString()}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to insert data: ${e.toString()}')));
      }
    }
    // _clearall();
  }

  /* void _clearall() {
    widget.fullNameController.text = "";
    widget.currentLocation = "";
    _selectedDate1, _selectedSex, _phoneNumberController1.text, widget.emergencyContactNameController.text, _phoneNumberController2.text, _modeofDetection, widget.otherModeofDetection.text, _classificationofPatient, widget.durationofSicknessController.text, _selectedDate2, _limitationofMovement, widget.numberofLesionsController.text, ‘${widget.diameterofBiggestLesion1.text} by ${widget.diameterofBiggestLesion2.text}’, _typeofLesion, _locationofLesion, imageFile, _clinicalSuspicion, widget.otherclinicalSuspicion.text, widget.anyOtherNotes.text

  } */

  /* void _fakeData() {
    setState(() {
      widget.fullNameController.text = faker.person.name();
      _selectedDate1 = faker.date.dateTime();
      _phoneNumberController1.text = faker.phoneNumber.toString();
      widget.emergencyContactNameController.text = faker.person.name();
      _phoneNumberController2.text = faker.phoneNumber.toString();
      _selectedDate2 = faker.date.dateTime();
      widget.otherclinicalSuspicion.text = faker.randomGenerator.toString();
      widget.anyOtherNotes.text = faker.randomGenerator.toString();
      //_imageFile = faker.image.file;
    });
  } */
}

// Example function to convert a file to a base64 string
Future<String> imageToBase64(File image) async {
  final bytes = await image.readAsBytes();
  return base64Encode(bytes);
}
