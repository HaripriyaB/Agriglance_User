import 'package:agriglance/Screens/Jobs/job_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class JobCard extends StatefulWidget {
  String jobType;
  String orgName;
  String jobDesc;
  String jobSubject;
  String jobSkills;
  int jobPosts;
  String salary;
  String orgLink;
  String postedByName;
  int index;
  String jobId;

  JobCard(
      {this.jobDesc,
      this.jobPosts,
      this.jobSkills,
      this.jobSubject,
      this.jobType,
      this.orgLink,
      this.orgName,
      this.salary,
      this.postedByName,
      this.index,
      this.jobId});

  @override
  _JobCardState createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  int count = 0;
  @override
  void initState() {
    super.initState();
    countDocuments();
  }
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => JobDetails(
                      jobDesc: widget.jobDesc,
                      jobPosts: widget.jobPosts,
                      jobSkills: widget.jobSkills,
                      jobSubject: widget.jobSubject,
                      jobType: widget.jobType,
                      orgLink: widget.orgLink,
                      orgName: widget.orgName,
                      salary: widget.salary,
                      postedByName: widget.postedByName,
                      jobId: widget.jobId,
                    ))),
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.indigo, width: 3.0),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.index + 1}. ${widget.orgName}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  "Salary: " + widget.salary,
                  style: TextStyle(fontSize: 18.0),
                ),
                (widget.postedByName != null)
                    ? Text(
                        "Posted By: " + widget.postedByName,
                        style: TextStyle(fontSize: 16.0),
                      )
                    : Text(
                        "Posted By : Anonymous",
                        style: TextStyle(fontSize: 16.0),
                      ),
                Text("${count.toString()} applicants")
              ],
            ),
          ),
        ),
      ),
    );
  }

  void countDocuments() async {
    QuerySnapshot _myDoc = await FirebaseFirestore.instance
        .collection("jobs")
        .doc(widget.jobId)
        .collection("applicants")
        .get();
    List<DocumentSnapshot> _myDocCount = _myDoc.docs;
    setState(() {
      count = _myDocCount.length;
    });
  }
}
