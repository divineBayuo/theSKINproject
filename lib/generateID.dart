import 'package:intl/intl.dart'; // For date formatting

class PatientIdGenerator {
  static int _sequenceNumber = 1; // Starting sequence number

  static String generatePatientId() {
    // Generate current timestamp formatted as ddmmyy-hhmmss
    String timestamp = DateFormat('ddMMyy-HHmmss').format(DateTime.now());

    // Generate padded sequence number
    String paddedSequence = _sequenceNumber.toString().padLeft(4, '0');

    String patientId = 'GHA-$timestamp-$paddedSequence';

    // Increment the sequence number for the next ID
    _sequenceNumber++;

    return patientId;
  }
}
/* 
void main() {
  // Example usage
  String patientId1 = PatientIdGenerator.generatePatientId();
  String patientId2 = PatientIdGenerator.generatePatientId();

  print("Patient1: $patientId1");
  print("Patient2: $patientId2");
} */