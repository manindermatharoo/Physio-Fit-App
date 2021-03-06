import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physio_tracker_app/services/cloud_database.dart';
import 'package:physio_tracker_app/models/event.dart';
import 'package:physio_tracker_app/models/user.dart';
import 'package:physio_tracker_app/screens/explore/explore.dart';
import 'package:physio_tracker_app/screens/physio_home/physioHome.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PhysioHomeProviderWrapper extends StatelessWidget {
  const PhysioHomeProviderWrapper({Key key, @required this.textController}) : super(key: key);
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    final FirebaseUser _user = Provider.of<FirebaseUser>(context);
    String uid = "";
    if (_user != null) {
      uid = _user.uid;
    }
    return  StreamProvider<List<User>>.value(value: CloudDatabase.streamPatients(uid),
      child: PhysioHome(textController: textController,),);
  }
}

