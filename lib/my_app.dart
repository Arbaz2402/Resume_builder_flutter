import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'pdf_generator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resume Builder',
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List<Map<String, String>> educationList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resume Builder'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: dobController,
                  decoration:
                      InputDecoration(labelText: 'Date of Birth (MM/DD/YYYY)'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your date of birth';
                    } else if (!_isValidDateFormat(value)) {
                      return 'Invalid date format. Please use MM/DD/YYYY';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!EmailValidator.validate(value)) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text('Educational History', style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: institutionController,
                  decoration: InputDecoration(labelText: 'Institution'),
                ),
                TextFormField(
                  controller: degreeController,
                  decoration: InputDecoration(labelText: 'Degree'),
                ),
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Year of Completion'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_atLeastOneEducationFieldFilled()) {
                        setState(() {
                          educationList.add({
                            'Institution': institutionController.text,
                            'Degree': degreeController.text,
                            'Year of Completion': dateController.text,
                          });
                          institutionController.clear();
                          degreeController.clear();
                          dateController.clear();
                        });
                      } else {
                        _showAlert(
                            'Please fill at least one field in Educational History');
                      }
                    }
                  },
                  child: Text('Add Education'),
                ),
                SizedBox(height: 20),
                Text('Educational History Table',
                    style: TextStyle(fontSize: 18)),
                Column(
                  children: educationList
                      .asMap()
                      .entries
                      .map(
                        (entry) => Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(entry.value['Institution'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.value['Degree'] ?? ''),
                                Text(entry.value['Year of Completion'] ?? ''),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                showDeleteConfirmationDialog(entry.key);
                              },
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool pdfGenerated = await generateAndSavePDF(
                        nameController.text,
                        dobController.text,
                        emailController.text,
                        educationList,
                      );
                      if (pdfGenerated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('PDF generated successfully!'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Generate PDF'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _atLeastOneEducationFieldFilled() {
    return institutionController.text.isNotEmpty ||
        degreeController.text.isNotEmpty ||
        dateController.text.isNotEmpty;
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidDateFormat(String input) {
    RegExp regExp = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    return regExp.hasMatch(input);
  }

  void showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Entry'),
          content: Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  educationList.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
