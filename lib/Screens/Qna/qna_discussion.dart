import 'package:agriglance/Services/authenticate.dart';
import 'package:agriglance/constants/comment_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Discussion extends StatefulWidget {
  String question;
  String description;
  String postedBy;
  String qid;
  String category;

  Discussion(
      {this.description,
      this.postedBy,
      this.question,
      this.qid,
      this.category});

  @override
  _DiscussionState createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  String comment = "";
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  Future<void> _uploadComment() async {
    if (myController.text != null && myController.text != "") {
      await FirebaseFirestore.instance
          .collection("qna")
          .doc(widget.qid)
          .collection("comments")
          .add({
        "content": myController.text,
        "postedBy": FirebaseAuth.instance.currentUser.displayName,
        "timeOfComment": DateTime.now(),
      });
      myController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("QNA - ${widget.category}"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 700.0,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 25.0, // soften the shadow
              spreadRadius: 5.0, //extend the shadow
              offset: Offset(
                15.0,
                15.0,
              ),
            )
          ], color: Colors.yellow[50], border: Border.all(color: Colors.white)),
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Text(
                      widget.question,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25.0),
                    ),
                    Text(
                      widget.description,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Divider(
                      thickness: 4.0,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("qna")
                      .doc(widget.qid)
                      .collection("comments")
                      .orderBy('timeOfComment')
                      .snapshots(),
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? Text("Loading")
                        : ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot com =
                                  snapshot.data.documents[index];
                              return CommentCard(
                                  comment: com['content'],
                                  postedBy: com['postedBy']);
                            },
                          );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: (FirebaseAuth.instance.currentUser != null)
          ? Padding(
              padding: EdgeInsets.only(
                  right: 8.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                  left: 10.0),
              child: Row(
                children: [
                  Container(
                    width: (kIsWeb) ? deviceWidth * 0.90 : deviceWidth / 1.4,
                    child: TextField(
                      controller: myController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(50.0),
                            ),
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey[800]),
                          hintText: "Type in your comment",
                          fillColor: Colors.white70),
                    ),
                  ),
                  SizedBox(
                    width: 3.0,
                  ),
                  RawMaterialButton(
                    onPressed: () => _uploadComment(),
                    elevation: 2.0,
                    fillColor: Colors.amber,
                    child: Icon(
                      Icons.send,
                      size: 30.0,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  )
                ],
              ),
            )
          : Container(
              child: RaisedButton(
              color: Colors.amber,
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Authenticate()));
              },
              child: Text("Login to Reply"),
            )),
    );
  }
}
