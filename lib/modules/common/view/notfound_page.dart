import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  Widget bodyData() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.search,
              size: 100.0,
              color: Colors.black,
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Page Not Found"),
      ),
      body: bodyData(),
    );
  }
}
