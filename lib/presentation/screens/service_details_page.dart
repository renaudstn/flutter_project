import 'package:flutter/material.dart';

// import 'package:searching_list_with_json/data/data_model.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../../data/data_model.dart';

class UserDetailsPage extends StatelessWidget {
  final Service user;

  UserDetailsPage({required this.user});

  // void customLaunch(command) async {
  //   if (await canLaunch(command)) {
  //     await launch(command);
  //   } else {
  //     print('Error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.id} : ${user.libelle}'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // SizedBox(
            //   height: 12.0,
            // ),
            // Text(
            //   '${user.qualite_de_service}',
            //   style: TextStyle(
            //     fontSize: 25.0,
            //     fontWeight: FontWeight.w700,
            //   ),
            //   textAlign: TextAlign.left,
            // ),
            SizedBox(
              height: 12.0,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 12.0, bottom: 20.0),
                  child: Text(
                    user.description,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
