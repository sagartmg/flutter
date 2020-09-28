import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  var user;
  String id;
  String userId;
  Home({this.id,this.userId,this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.user.email}"),
        ),
        body: Container(
          child: Text("${widget.userId}"),
        ));
  }
}
