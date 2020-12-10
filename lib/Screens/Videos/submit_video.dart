import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmitVideo extends StatefulWidget {
  @override
  _SubmitVideoState createState() => _SubmitVideoState();
}

class _SubmitVideoState extends State<SubmitVideo> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _lectureTitle = "";
  String _youtubeChannelKey = "";
  String _embedVideo = "";
  bool _isApproved = false;
  String _postedBy = "";

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text("Submit Video"), centerTitle: true),
      body: Container(
          padding: EdgeInsets.only(left: width / 25),
          width: width / 1.3,
          child: Form(
            key: _formKey,
            child: ListView(children: <Widget>[
              SizedBox(
                height: height / 25,
              ),
              TextFormField(
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                keyboardType: TextInputType.text,
                validator: (val) =>
                    val.isEmpty ? 'Lecture title is required' : null,
                onSaved: (val) => _lectureTitle = val,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 5.0),
                  icon: Icon(Icons.title),
                  hintText: 'Enter lecture title',
                  labelText: 'Lecture Title',
                ),
              ),
              SizedBox(
                height: height * 0.1,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                onSaved: (val) => _youtubeChannelKey = val,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  hintText: 'Enter Youtube channel key',
                  labelText: 'Youtube Channel Key',
                ),
              ),
              SizedBox(
                height: height * 0.1,
              ),
              TextFormField(
                keyboardType: TextInputType.url,
                onSaved: (val) => _embedVideo = val,
                decoration: InputDecoration(
                  icon: Icon(Icons.link),
                  hintText: 'Enter youtube video url',
                  labelText: 'Youtube video url',
                ),
              ),
              SizedBox(
                height: height * 0.1,
              ),
              OutlineButton(
                  borderSide: BorderSide(color: Color(0xFF3EC3C1), width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      await FirebaseFirestore.instance
                          .collection("Videos")
                          .add({
                        "isApprovedByAdmin": _isApproved,
                        "lectureTitle": _lectureTitle,
                        "videoUrl": _embedVideo,
                        "youtubeChannelName": _youtubeChannelKey,
                        "postedBy":
                            FirebaseAuth.instance.currentUser.uid != null
                                ? FirebaseAuth.instance.currentUser.uid
                                : "Anonymous"
                      });

                      _formKey.currentState.reset();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              const Text("Details Submitted Successfully")));
                    }
                  }),
            ]),
          )),
    );
  }
}
