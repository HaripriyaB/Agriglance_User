import 'package:agriglance/Screens/Test/test_home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddQuestions extends StatefulWidget {
  final String testName;
  final String testSubject;

  AddQuestions({this.testName, this.testSubject});

  @override
  _AddQuestionsState createState() => _AddQuestionsState();
}

class _AddQuestionsState extends State<AddQuestions> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _question = "";
  String _option1 = "";
  String _option2 = "";
  String _option3 = "";
  String _option4 = "";

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void _submitForm() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      print(widget.testName);
      form.save();
      _uploadQuestion();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Submitted to admin for approval"),
      ));
      Navigator.pop(context);
    }
  }

  Future<void> _uploadQuestion() async {
    await FirebaseFirestore.instance
        .collection("testQuestions")
        .doc(widget.testName)
        .collection("questions")
        .add({
      'isApprovedByAdmin': false,
      'Question': _question,
      'option1': _option1,
      'option2': _option2,
      'option3': _option3,
      'option4': _option4
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Question")),
      body: SafeArea(
          top: true,
          bottom: true,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: ListView(children: <Widget>[
              Text("Question: "),
              TextFormField(
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                validator: (val) => val.isEmpty ? 'Question is required' : null,
                onSaved: (val) => _question = val,
                decoration: InputDecoration(
                  hintText: 'Enter question',
                  labelText: 'Question',
                ),
              ),
              Text("Option 1: "),
              TextFormField(
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                validator: (val) => val.isEmpty ? 'Option is required' : null,
                onSaved: (val) => _option1 = val,
                decoration: InputDecoration(
                  hintText: 'Enter option1 (Correct Answer)',
                  labelText: 'Option 1 (Correct Answer)',
                ),
              ),
              Text("Option 2: "),
              TextFormField(
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                validator: (val) => val.isEmpty ? 'Option is required' : null,
                onSaved: (val) => _option2 = val,
                decoration: InputDecoration(
                  hintText: 'Enter option 2',
                  labelText: 'Option 2',
                ),
              ),
              Text("Option 3: "),
              TextFormField(
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                validator: (val) => val.isEmpty ? 'Option is required' : null,
                onSaved: (val) => _option3 = val,
                decoration: InputDecoration(
                  hintText: 'Enter option 3',
                  labelText: 'Option 3',
                ),
              ),
              Text("Option 4: "),
              TextFormField(
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                validator: (val) => val.isEmpty ? 'Option is required' : null,
                onSaved: (val) => _option4 = val,
                decoration: InputDecoration(
                  hintText: 'Enter option 4',
                  labelText: 'Option 4',
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 60.0, right: 60.0),
                child: RaisedButton(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: Colors.black87),
                  ),
                  splashColor: Colors.purple,
                  elevation: 10.0,
                  highlightElevation: 30.0,
                  child: const Text(
                    'Submit for Approval',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20.0,
                    ),
                  ),
                  color: Colors.blue[300],
                  textColor: Colors.white,
                  onPressed: () {
                    _submitForm();
                    _formKey.currentState.reset();
                  },
                ),
              ),
            ]),
          )),
    );
  }
}
