import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart' hide Text;
// import 'package:markdown/markdown.dart';
import 'package:meteo_du_numerique/domain/repository.dart';

import '../../data/data_model.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.box}) : super(key: key);
  final Box box;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<String> _tokenStream;
  late List<dynamic> services;
  final List<Service> _services = <Service>[];
  List<Service> _servicesDisplay = <Service>[];

  late int _filterId;

  @override
  void initState() {
    super.initState();

    extents = List<int>.generate(10000, (int index) => rnd.nextInt(7) + 1);

    fetchServices().then((value) {
      setState(() {
        // _isLoading = false;
        _services.addAll(value);
        // todo filter
        // final filtered = _services
        //     .where((service) => service.libelle.contains("COLIBRIS"))
        //     .toList();
        // _servicesDisplay = filtered;
        _servicesDisplay = _services;
        _servicesDisplay.sort((a, b) =>
            b.qualite_de_service_id.compareTo(a.qualite_de_service_id));
      });
    });
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String get hostname {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:1337';
      // return 'http://172.29.222.125:1337';
      // return 'http://127.0.0.1:1337';
    } else {
      // return 'http://localhost:1337';
      return 'http://127.0.0.1:1337';
      // return 'http://172.29.222.125:1337';
      // return 'http://10.0.2.2:1337';
    }
  }

  Future<void> fetchservices() async {
    String url = "https://www.toutatice.fr/strapi/services";
    // String url = "$hostname/api/services";
    // String url = "http://127.0.0.1:1337/api/services";
    // String url = "http://172.29.222.125:1337/api/services";
    // String url = "http://10.0.2.2:1337/api/services";
    var authToken = widget.box.get("authToken");
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    var response = await http.get(Uri.parse(url), headers: headers);
    var responseData = json.decode(response.body);
    setState(() {
      services = responseData;
    });
  }

  List<Service> filtered(int value) {
    return _services
        .where((service) => service.qualite_de_service_id == value)
        .toList();
  }

  static const List<Widget> icons = <Widget>[
    Icon(Icons.sunny, color: Colors.green),
    Icon(Icons.cloud, color: Colors.blueAccent),
    Icon(Icons.flash_on, color: Colors.redAccent),
  ];

  final List<bool> _selectedState = <bool>[false, false, true];

  Color mColor = const Color(0xFF6200EE),
      mColor0 = const Color(0xFF6200EE),
      mColor1 = const Color(0xFF6200EE);
  List<bool> isSelected = <bool>[false, false, false];

  final rnd = Random();
  late List<int> extents;
  int crossAxisCount = 4;
  int columnsCount = 2;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 200,
          //set your height
          centerTitle: true,
          backgroundColor: Colors.white70.withOpacity(0.9),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 30),
          title: Column(children: [
            const Text('La météo du numérique'),
            _searchBar(),
            SizedBox(
                width: 450.0, // hardcoded for testing purpose
                height: 50,
                child: LayoutBuilder(builder: (context, constraints) {
                  return ToggleButtons(
                    constraints: BoxConstraints.expand(
                        width: constraints.maxWidth / 3.1),
                    //number 2 is number of toggle buttons
                    direction: Axis.horizontal,
                    // color: Colors.black.withOpacity(0.60),
                    color: Colors.black,
                    selectedColor: mColor,
                    selectedBorderColor: mColor0,
                    fillColor: mColor1.withOpacity(0.08),
                    splashColor: Colors.grey.withOpacity(0.12),
                    hoverColor: const Color(0xFF6200EE).withOpacity(0.04),
                    borderRadius: BorderRadius.circular(4.0),
                    // constraints: BoxConstraints(minHeight: 36.0),
                    isSelected: isSelected,
                    onPressed: (index) {
                      // Respond to button selection
                      setState(() {
                        isSelected[0] = false;
                        isSelected[1] = false;
                        isSelected[2] = false;
                        if (index == 0) {
                          mColor = Colors.green;
                          mColor0 = Colors.green;
                          mColor1 = Colors.green;
                        }
                        if (index == 1) {
                          mColor = Colors.blueAccent;
                          mColor0 = Colors.blueAccent;
                          mColor1 = Colors.blueAccent;
                        }
                        if (index == 2) {
                          mColor = Colors.redAccent;
                          mColor0 = Colors.redAccent;
                          mColor1 = Colors.redAccent;
                        }

                        if (_servicesDisplay.isNotEmpty &&
                            _servicesDisplay.every((element) =>
                                element.qualite_de_service_id == index + 1)) {
                          isSelected = <bool>[false, false, false];

                          _servicesDisplay = _services;
                        } else {
                          _servicesDisplay = filtered(index + 1);
                          isSelected[index] = !isSelected[index];
                        }
                      });
                    },
                    children: icons,
                  );
                })),
          ])),

// todo
      body: Padding(
        padding: const EdgeInsets.only(top: 1),

        // child: MasonryGridView.count(
        //   crossAxisCount: 2,
        //   mainAxisSpacing: 8,
        //   crossAxisSpacing: 4,
        //   itemCount: _servicesDisplay.length,
        //   itemBuilder: (context, index) {
        //     return Column(
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Text(
        //           _servicesDisplay[index].libelle,
        //           overflow: TextOverflow.ellipsis,
        //         ),
        //       ],
        //     );
        //   },
        // ),

        child: AlignedGridView.extent(
          maxCrossAxisExtent: 600,
          mainAxisSpacing: 10,
          crossAxisSpacing: 6,
          itemCount: _servicesDisplay.length,
          itemBuilder: (context, index) {
            return MasonryGridTile(
              service: _servicesDisplay[index],
            );
          },
        ),
      ),

      // body: Padding(
      // padding: const EdgeInsets.only(top: 1),
      // child: Column(
      //   children: [
      //     const Padding(padding: EdgeInsets.only(bottom: 8.0)),
      //     Expanded(
      //         child: GridView.builder(
      //             padding: const EdgeInsets.all(8.0),
      //             gridDelegate:
      //                 const SliverGridDelegateWithMaxCrossAxisExtent(
      //                     maxCrossAxisExtent: 450,
      //                     childAspectRatio: 4 / 2,
      //                     crossAxisSpacing: 10,
      //                     mainAxisSpacing: 10),
      //             itemCount: _servicesDisplay.length,
      //             shrinkWrap: true,
      //             itemBuilder: (BuildContext ctx, index) {
      //               return Tile(
      //                   index: index, service: _servicesDisplay[index]);
      //             }))
      //   ],
      // ),
    );
  }

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        autofocus: false,
        onChanged: (searchText) {
          searchText = searchText.toLowerCase();
          setState(() {
            _servicesDisplay = _services.where((u) {
              var lName = u.libelle.toLowerCase();
              var dName = u.description.toLowerCase();
              return lName.contains(searchText)
                  // || dName.contains(searchText)
                  ;
            }).toList();
          });
        },
        // controller: _textController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          prefixIcon: const Icon(Icons.search),
          hintText: 'Recherchez une application',
        ),
      ),
    );
  }
}

class MasonryGridTile extends StatelessWidget {
  final Service service;
  const MasonryGridTile({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ClipRRect(
          //   borderRadius: const BorderRadius.only(
          //     topLeft: Radius.circular(10.0),
          //     topRight: Radius.circular(10.0),
          //   ),
          //   child: Image(
          //     image: AssetImage(image),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Name",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color.fromRGBO(74, 74, 74, 1)),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.download,
                          color: Colors.teal,
                        ))
                  ],
                ),
                Html(
                  data : markdownToHtml(service.description)


                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
