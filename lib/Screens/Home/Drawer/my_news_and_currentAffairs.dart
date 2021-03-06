import 'package:agriglance/constants/news_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyNewsAndCurrentAffairs extends StatefulWidget {
  @override
  _MyNewsAndCurrentAffairsState createState() =>
      _MyNewsAndCurrentAffairsState();
}

class _MyNewsAndCurrentAffairsState extends State<MyNewsAndCurrentAffairs> {
  String _newsPostedBy = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("News"), centerTitle: true),
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
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("News")
                .where("uid", isEqualTo: FirebaseAuth.instance.currentUser.uid)
                .orderBy("isApprovedByAdmin", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.amber,
                  ),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot news = snapshot.data.docs[index];
                  _newsPostedBy =
                      news['uname'] != "" ? news['uname'] : "Anonymous";
                  return NewsCard(
                      approved: news['isApprovedByAdmin'],
                      newsTitle: news['title'],
                      newsDescription: news['description'],
                      newsFile: news['fileUrl'],
                      newsLink: news['newsLink'],
                      newsDate: news['postedAt'],
                      newsPostedBy: _newsPostedBy);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
