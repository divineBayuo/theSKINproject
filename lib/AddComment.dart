import 'package:flutter/material.dart';
import 'package:skin_app/MongoDBModel.dart';
import 'package:skin_app/dbHelper/mongodb.dart';
import 'package:intl/intl.dart';

class AddComment extends StatefulWidget {
  final MongoDbModel data;
  final ValueChanged<String> onCommentAdded;

  const AddComment({required this.data, required this.onCommentAdded, super.key});

  @override
  State<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.data.comment ?? '';
  }

  @override
  void dispose() {
    // TODO: implement ==
    _commentController.dispose();
    super.dispose();
  }

  void _updateComment() async {
    String comment = _commentController.text;
    // Get the current date and time
    String currentTime = DateFormat('dd-MM-yyy HH:mm:ss').format(DateTime.now());
    // Append the date and time to the comment
    comment += '\n\nSubmitted on: $currentTime';

    widget.data.comment = comment;
    await MongoDatabase.update(widget.data);
    widget.onCommentAdded(comment);
    Navigator.pop(context); //Back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Comment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                  'Here, you can make any updates to the patient during review. Add any comments, notes, recommendations, et cetera, during review. NB: This field is for HEALTHCARE PROFESSIONALS only.'),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                'NB: This field is for HEALTHCARE PROFESSIONALS only.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 40.0,
              ),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment / Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _updateComment,
                /* () async {
                  // Handle comment submission logic here
                  String comment = _commentController.text;
                  // Update patient data with new comment
                  MongoDbModel updatedData = widget.data;
                  updatedData.comment = comment;
                  // Update the data in the database
                  try {
                    await MongoDatabase.update(updatedData);
                    // Print the comment for debugging purposes
                    print('Comment: $comment');
                    // Navigate back to the previous page
                    Navigator.pop(context);
                  } catch (e) {
                    // TODO
                    print('Error updating comment: $e');
                    // Show error message to the user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating comment: $e')),
                    );
                  }
                } */
                child: const Text('Save Comment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
