import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String text;
  final Widget widget;
  Loading({this.text, @required this.widget});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
//        color: Colors.transparent,
        color: Color(0x55000000),
        child: Center(
          child: SizedBox(
            width: 130.0,
            height: 130.0,
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.white54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  widget,
                  (text == null || text.length == 0)
                      ? Container()
                      : Container(
                          padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
                          child: FittedBox(
                            child: Text(
                              text == null ? "loading" : text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .color),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
