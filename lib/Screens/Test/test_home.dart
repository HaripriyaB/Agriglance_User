import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'testSubjects.dart';

class TestHome extends StatelessWidget {
  Widget categoryButton(String category, BuildContext context) {
    var style;
    if (kIsWeb)
      style = TextStyle(fontSize: 30.0, fontWeight: FontWeight.w400);
    else
      style = TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400);
    return ButtonTheme(
      minWidth: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.width * 0.09,
      hoverColor: Colors.amber[200],
      child: OutlineButton(
          splashColor: Colors.grey,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TestSubject(
                          category: category,
                        )));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.menu_book_outlined, size: 40.0, color: Color(0xFF3EC3C1)),
              Text(
                category,
                style: style,
              ),
              Icon(Icons.arrow_forward, size: 40.0, color: Color(0xFF3EC3C1))
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          borderSide: BorderSide(color: Color(0xFF3EC3C1), width: 6.0)),
    );
  }

  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: deviceWidth * 0.9,
          height: deviceHeight * 0.9,
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
          ], color: Colors.white, border: Border.all(color: Colors.white)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Test Category",
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: deviceHeight / 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  categoryButton("IPS", context),
                  categoryButton("IAS", context),
                ],
              ),
              SizedBox(
                height: deviceHeight / 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  categoryButton("ICAR SRF", context),
                  categoryButton("NET", context),
                ],
              ),
              SizedBox(
                height: deviceHeight / 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  categoryButton("BHU", context),
                  categoryButton("AFO", context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
