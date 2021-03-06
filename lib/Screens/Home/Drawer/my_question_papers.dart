import 'package:agriglance/constants/question_paper_card.dart';
import 'package:agriglance/constants/study_material_card.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class MyQuestionPapers extends StatefulWidget {
  @override
  _MyQuestionPapersState createState() => _MyQuestionPapersState();
}

enum options { View, Download, Share }

class _MyQuestionPapersState extends State<MyQuestionPapers> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final qpapersCollectionReference =
      FirebaseStorage.instance.ref().child("studyMaterials/QuestionPapers");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Question Papers"),
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
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("question_papers")
                .where("postedBy", isEqualTo: auth.currentUser.uid.toString())
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot qpaper =
                            snapshot.data.documents[index];
                        return GestureDetector(
                          onTap: () async {
                            await _asyncSimpleDialog(
                                context, qpaper['paperUrl'], qpaper['fileName'],qpaper['subject']);
                          },
                          child: QuestionPaperCard(
                            subject: qpaper['subject'],
                            year: qpaper['year'],
                            pdfUrl: qpaper['paperUrl'],
                            examName: qpaper['examName'],
                            postedByName: qpaper['postedByName'],
                            fileName: qpaper['fileName'],
                            approved: qpaper['isApprovedByAdmin'],
                            index: index,
                          ),
                        );
                      });
            },
          ),
        ),
      ),
    );
  }

  void _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  void _shareInApps(String filename, String link) async {
    try {
      WcFlutterShare.share(
          sharePopupTitle: "Agriglance",
          subject: "Download",
          text:
          "Download question paper via this link: FileName: $filename $link \n Visit agriglance.com for more such materials",
          mimeType: 'text/plain');
    } catch (e) {
      print(e);
    }
  }

  Future<options> _asyncSimpleDialog(
      BuildContext context, String url, String filename, String title) async {
    return await showDialog<options>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Choose'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Fluttertoast.showToast(
                      msg: "Question Paper Download started...",
                      gravity: ToastGravity.BOTTOM);
                  // download(url, filename);
                  _launchURL(url);
                },
                child: const Text('Download'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  if (!kIsWeb)
                    _shareInApps(title, url);
                  else
                    _shareInWeb(title, url);
                },
                child: const Text('Share'),
              ),
            ],
          );
        });
  }

  void _shareInWeb(String filename, String url) {
    FlutterClipboard.copy(
        'Download Question Paper via this link: FileName: $filename $url \nGet more study materials and free mock test on agriglance.com ')
        .then((value) {
      Fluttertoast.showToast(
          msg: "Copied To Clipboard!",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG);
    });
  }
}
