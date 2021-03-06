import 'dart:io';
import 'dart:math';

import 'package:agriglance/Services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:universal_html/html.dart' as html;

class AddDocument extends StatefulWidget {
  @override
  _AddDocumentState createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  String uid = FirebaseAuth.instance.currentUser.uid;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _title;
  String _author;
  String _description;
  String _keywords;
  String _type = "Choose Type";
  String _paperUrl;
  FilePickerResult _filePickerResult;
  String absolutePath = "";
  String fileName = "";
  String fileUrl = "";
  var file;
  String uName;
  bool showUploadButton = true;

  @override
  void initState() {
    super.initState();
    FirestoreService().getUser(uid).then((value) {
      uName = value.fullName;
    });
  }

  void _submitForm() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save();
      _uploadImageToFirebase();
      Navigator.pop(context);
    }
  }

  Future<void> _uploadImageToFirebase() async {
    await FirebaseFirestore.instance.collection("documents").add({
      'isApprovedByAdmin': false,
      'type': _type,
      'title': _title,
      'description': _description,
      'keywords': _keywords,
      'author': _author,
      'docUrl': _paperUrl,
      'fileName': fileName,
      'postedBy': uid,
      'postedByName': uName
    });
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    Fluttertoast.showToast(msg: message);
  }

  bool visible = false;

  loadProgress() {
    if (visible == true) {
      setState(() {
        visible = false;
      });
    } else {
      setState(() {
        visible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Document"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            width: 700.0,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 25.0, // soften the shadow
                    spreadRadius: 5.0, //extend the shadow
                    offset: Offset(
                      15.0,
                      15.0,
                    ),
                  )
                ],
                color: Colors.yellow[50],
                border: Border.all(color: Colors.white)),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: InputDecoration(
                      icon: Icon(Icons.category),
                    ),
                    validator: (value) =>
                        value == "Choose Type" ? "Choose Type" : null,
                    hint: Text("Choose Type"),
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    onChanged: (String newValue) {
                      setState(() {
                        _type = newValue;
                      });
                    },
                    items: <String>[
                      "Choose Type",
                      "ARTICLE",
                      "RESEARCH PAPER",
                      "PPT",
                      'Other'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    validator: (val) =>
                        val.isEmpty ? 'Title is Required' : null,
                    onSaved: (val) => _title = val,
                    decoration: InputDecoration(
                      icon: Icon(Icons.title),
                      hintText: 'Enter the title',
                      labelText: 'Title',
                    ),
                  ),
                  TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    validator: (val) =>
                        val.isEmpty ? 'Author Name is Required' : null,
                    onSaved: (val) => _author = val,
                    decoration: InputDecoration(
                      icon: Icon(Icons.edit),
                      hintText: 'Enter Author Name',
                      labelText: 'Author Name',
                    ),
                  ),
                  TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(300)],
                    onSaved: (val) => _description = val,
                    decoration: InputDecoration(
                      icon: Icon(Icons.book),
                      hintText: 'Describe',
                      labelText: 'Description/Abstract/Summary',
                    ),
                  ),
                  TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    validator: (val) =>
                        val.isEmpty ? 'KeyWords are Required' : null,
                    onSaved: (val) => _keywords = val,
                    decoration: InputDecoration(
                      icon: Icon(Icons.bookmark_outlined),
                      hintText: 'Enter the keywords',
                      labelText: 'KeyWords',
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.all(MediaQuery.of(context).size.height / 20),
                    child: OutlineButton(
                      splashColor: Colors.yellow,
                      onPressed: () {
                        setState(() {
                          getPDF();
                        });
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      borderSide:
                          BorderSide(color: Color(0xFF3EC3C1), width: 2.0),
                      child: Text(
                        'Select PDF',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Center(
                      child: Text(
                    "File selected : $absolutePath",
                    style: TextStyle(fontSize: 16.0),
                  )),
                  Visibility(
                    visible: showUploadButton,
                    child: Container(
                      padding: EdgeInsets.all(40.0),
                      child: OutlineButton(
                        onPressed: () {
                          setState(() {
                            loadProgress();
                            showUploadButton = false;
                            uploadStarted();
                          });
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        borderSide:
                            BorderSide(color: Color(0xFF3EC3C1), width: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Upload PDF',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Visibility(
                          visible: visible, child: CircularProgressIndicator()),
                      Visibility(
                          visible: visible,
                          child: Text(
                              "Uploading your file.. Please wait. Do not navigate back."))
                    ],
                  ),
                  Visibility(
                    visible: _paperUrl == null ? false : true,
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: RaisedButton(
                        splashColor: Colors.grey,
                        color: Colors.yellow,
                        onPressed: () {
                          _submitForm();
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        highlightElevation: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'Submit for Admin Approval',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future getPDF() async {
    var random = new Random();
    for (var i = 0; i < 20; i++) {
      print(random.nextInt(100));
      fileName += random.nextInt(100).toString();
    }
    if (!kIsWeb) {
      _filePickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: ['pdf', 'doc', 'xls', 'csv','ppt','pptx'],
          allowCompression: true);
      if (_filePickerResult != null) {
        setState(() {
          file = File(_filePickerResult.files.single.path);
          List<String> p = file.path.split("/").toList();
          absolutePath = file.path.split("/")[p.length - 1];
          fileName += '$absolutePath';
        });
      } else {
        showMessage("No file Selected!");
      }
    } else {
      html.InputElement uploadInput = html.FileUploadInputElement();
      uploadInput.click();

      uploadInput.onChange.listen((e) {
        final userFile = uploadInput.files.first;
        final reader = html.FileReader();
        reader.readAsDataUrl(userFile);
        reader.onLoadEnd.listen((event) {
          setState(() {
            file = userFile;
            absolutePath = userFile.name;
            fileName += absolutePath;
          });
        });
      });
    }
  }

  Future uploadStarted() async {
    if (file != null) {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("studyMaterials/Documents/" + fileName);
      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = storageReference.putBlob(file);
      } else {
        uploadTask = storageReference.putFile(file);
      }
      uploadTask.whenComplete(() async {
        try {
          loadProgress();
          await storageReference.getDownloadURL().then((value) {
            print("***********" + value + "**********");
            setState(() {
              _paperUrl = value;
            });
          });
        } catch (onError) {
          print("Error in uploading file: " + onError.message);
        }
      });
    }
  }
}
