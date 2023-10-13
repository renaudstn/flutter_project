import 'dart:io';
import 'dart:math';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:markdown/markdown.dart' hide Text;
import 'package:meteo_du_numerique/domain/repository.dart';

import '../../data/data_model.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.box}) : super(key: key);
  final Box box;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late List<Service> services;

  DateTime? lastUpdate;
  final List<Service> _services = <Service>[];
  List<Service> _servicesDisplay = <Service>[];

  late AnimationController _con;
  late TextEditingController _textEditingController;
  bool toggle = false;

  bool fav = false;
  bool fav2 = false;
  bool fav3 = false;
  bool fav4 = false;
  bool disableSort = false;

  @override
  void initState() {
    super.initState();

    initializeDateFormatting();

    _textEditingController = TextEditingController();
    _con = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 375),
    );

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

        _servicesDisplay = sortAll(false);

        // todo

        lastUpdate = _services
            .map((e) => e.lastUpdate)
            .reduce((min, e) => e.isAfter(min) ? e : min);
      });
    });
  }

  @override
  void dispose() {
    // disposing states
    super.dispose();
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

  String lastUpdateString(DateTime lastUpdate) {
    String form = DateFormat("dd MMMM yyyy", "fr_FR").format(lastUpdate);
    String hour =
        "${DateFormat("H").format(lastUpdate.add(const Duration(hours: 2)))}h${DateFormat("mm").format(lastUpdate)}";
    return "Dernière mise à jour le $form à $hour";
  }

  List<Service> filtered(int value) {
    var filtered = _services
        .where((service) => service.qualiteDeServiceId == value)
        .toList();
    filtered.sort((a, b) => removeDiacritics(a.libelle.toLowerCase())
        .compareTo(removeDiacritics(b.libelle.toLowerCase())));
    return filtered;
  }

  List<Service> sortAll(bool inverse) {
    var critic1 =
        _services.where((service) => service.qualiteDeServiceId == 1).toList();
    critic1.sort((a, b) => removeDiacritics(a.libelle.toLowerCase())
        .compareTo(removeDiacritics(b.libelle.toLowerCase())));
    var critic2 =
        _services.where((service) => service.qualiteDeServiceId == 2).toList();
    critic2.sort((a, b) => removeDiacritics(a.libelle.toLowerCase())
        .compareTo(removeDiacritics(b.libelle.toLowerCase())));
    var critic3 =
        _services.where((service) => service.qualiteDeServiceId == 3).toList();
    critic3.sort((a, b) => removeDiacritics(a.libelle.toLowerCase())
        .compareTo(removeDiacritics(b.libelle.toLowerCase())));
    if (inverse) {
      critic1.addAll(critic2);
      critic1.addAll(critic3);
      return critic1;
    } else {
      critic3.addAll(critic2);
      critic3.addAll(critic1);
      return critic3;
    }
  }

  // DateTime lastUpdate = _services.reduce((value, element) => max(element.lastUpdate));

  static const List<Widget> icons = <Widget>[
    Icon(Icons.sunny, color: Color(0xff04dc9a)),
    Icon(CupertinoIcons.umbrella_fill, color: Color(0xffdd9e51)),
    Icon(Icons.flash_on, color: Color(0xffff3d71)),
  ];

  Color mColor = const Color(0xFF6200EE),
      mColor0 = const Color(0xFF6200EE),
      mColor1 = const Color(0xFF6200EE);
  List<bool> isSelected = <bool>[false, false, false];

  final rnd = Random();
  late List<int> extents;
  int crossAxisCount = 4;
  int columnsCount = 2;

  final ScrollController _controller = ScrollController();

// This is what you're looking for!
  void _scrollUp() {
    _controller.animateTo(
      0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 234,
        backgroundColor: Colors.indigo,
        // backgroundColor: const Color(0xff222b45),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
        title: Column(children: [
          Container(
            color: Colors.white,
            height: 60,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // _searchBar(),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // width: double.infinity,
                        // height: 50,
                        children: [
                          Image.asset(
                            'images/logo_academie.jpg',
                            // fit: BoxFit.fitHeight
                          ),
                        ]),
                  ),
                ),

                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _servicesDisplay = sortAll(false);
                            isSelected = <bool>[false, false, false];
                            disableSort = false;
                            fav = false;
                            fav2 = false;
                            fav3 = false;
                            fav4 = false;
                          });

                          _scrollUp();
                        },
                        child: Text(
                          'Météo du numérique',
                          style: GoogleFonts.aBeeZee(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ]),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // width: double.infinity,
                        // height: 50,
                        children: [
                          Image.asset(
                            'images/meteo-icon.png',
                            // fit: BoxFit.fitHeight
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),

          // const Text('La météo du numérique'),

          Padding(
            padding: EdgeInsets.zero,
            child: Container(
              color: const Color(0xff222b45),
              // color: Colors.indigo,
              height: 50,
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                        'Retrouvez pendant la période de Rentrée la météo en continu des principaux services numériques de l\'académie',
                        maxLines: 10,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

          //     child: Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     // Image.asset('images/icons8-search-50.png'),
          //     const Text('La météo du numérique'),
          //   ],
          // ),

          Container(
            width: MediaQuery.of(context).size.width,
            color: const Color(0xff222b45),
            padding:
                const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 4.0),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text("Filtrer",
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
                // if (toggle == false)
                Padding(
                  padding: const EdgeInsets.only(left: 35.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return ToggleButtons(
                        constraints: BoxConstraints.expand(
                            width: constraints.maxWidth / 3.05, height: 38),
                        //number 2 is number of toggle buttons
                        direction: Axis.horizontal,
                        // color: Colors.black.withOpacity(0.60),
                        color: Colors.white,
                        selectedColor: mColor,
                        // selectedBorderColor: mColor0,
                        selectedBorderColor: Colors.white,
                        borderColor: Colors.white,
                        // fillColor: mColor1.withOpacity(0.08),
                        fillColor: const Color(0xFF3366ff),
                        splashColor: Colors.grey.withOpacity(0.12),
                        hoverColor: const Color(0xFF6200EE).withOpacity(0.04),
                        borderRadius: BorderRadius.circular(30.0),
                        // constraints: BoxConstraints(minHeight: 36.0),
                        isSelected: isSelected,
                        onPressed: (index) {
                          setState(() => fav3 = false);
                          setState(() => fav4 = false);

                          // Respond to button selection
                          setState(() {
                            isSelected[0] = false;
                            isSelected[1] = false;
                            isSelected[2] = false;
                            if (index == 0) {
                              mColor = const Color(0xff04dc9a);
                              mColor0 = const Color(0xff04dc9a);
                              mColor1 = const Color(0xff04dc9a);
                            }
                            if (index == 1) {
                              mColor = const Color(0xffdd9e51);
                              mColor0 = const Color(0xffdd9e51);
                              mColor1 = const Color(0xffdd9e51);
                            }
                            if (index == 2) {
                              mColor = const Color(0xffff3d71);
                              mColor0 = const Color(0xffff3d71);
                              mColor1 = const Color(0xffff3d71);
                            }

                            if (_servicesDisplay.isNotEmpty &&
                                _servicesDisplay.every((element) =>
                                    element.qualiteDeServiceId == index + 1)) {
                              isSelected = <bool>[false, false, false];
                              disableSort = false;
                              _servicesDisplay = sortAll(false);
                            } else {
                              var begin = _servicesDisplay.isEmpty;

                              isSelected[index] = !isSelected[index];

                              _servicesDisplay = filtered(index + 1);
                              if (begin && _servicesDisplay.isEmpty) {
                                isSelected = <bool>[false, false, false];
                                disableSort = false;
                                _servicesDisplay = sortAll(false);
                              } else {
                                disableSort = true;
                              }
                            }

                            _scrollUp();
                          });
                        },
                        children: icons,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xff222b45),
            padding:
                const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 4.0),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text("Trier",
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
                // const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 35.0),
                  child: Row(
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            if (!disableSort) {
                              setState(() => fav4 = false);
                              setState(() => fav = false);
                              if (fav2) {
                                setState(() => fav2 = false);

                                _servicesDisplay = sortAll(false);
                              } else {
                                if (!fav3) {
                                  _servicesDisplay = sortAll(false);
                                } else {
                                  setState(() => fav2 = true);
                                  _servicesDisplay = sortAll(true);
                                }
                              }
                              setState(() => fav3 = true);
                            } else {
                              null;
                            }
                            _scrollUp();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              fav3
                                  ? const Color(0xFF3366ff)
                                  : const Color(0xff222b45),
                            ),
                            minimumSize: MaterialStateProperty.all(
                                const Size(110.0, 32.0)),
                            // maximumSize: MaterialStateProperty.all(const Size(120.0,32.0)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.0))),
                            side: MaterialStateProperty.all(BorderSide(
                              color:
                                  disableSort ? Colors.white38 : Colors.white,
                            )),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    fav2
                                        ? FontAwesomeIcons.arrowDownLong
                                        : FontAwesomeIcons.arrowUpLong,
                                    size: 20,
                                    color: disableSort
                                        ? Colors.white38
                                        : Colors.white),
                                // const Icon(Icons.sunny, color: Color(0xff04dc9a)),
                                Icon(Icons.sunny,
                                    color: disableSort
                                        ? Colors.white38
                                        : Colors.white),
                              ])),
                      const Spacer(),
                      OutlinedButton(
                          onPressed: () {
                            setState(() => fav3 = false);
                            setState(() => fav2 = false);

                            if (fav) {
                              setState(() => fav = false);

                              _servicesDisplay.sort((a, b) =>
                                  removeDiacritics(a.libelle.toLowerCase())
                                      .compareTo(removeDiacritics(
                                          b.libelle.toLowerCase())));
                            } else {
                              if (!fav4) {
                                _servicesDisplay.sort((a, b) =>
                                    removeDiacritics(a.libelle.toLowerCase())
                                        .compareTo(removeDiacritics(
                                            b.libelle.toLowerCase())));
                              } else {
                                setState(() => fav = true);
                                _servicesDisplay.sort((a, b) =>
                                    removeDiacritics(b.libelle.toLowerCase())
                                        .compareTo(removeDiacritics(
                                            a.libelle.toLowerCase())));
                              }
                            }
                            setState(() => fav4 = true);
                            _scrollUp();
                          },
                          style: ButtonStyle(
                            alignment: Alignment.center,
                            backgroundColor: MaterialStateProperty.all(
                              fav4
                                  ? const Color(0xFF3366ff)
                                  : const Color(0xff222b45),
                            ),
                            minimumSize: MaterialStateProperty.all(
                                const Size(110.0, 32.0)),
                            // maximumSize: MaterialStateProperty.all(const Size(120.0,32.0)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.0))),
                            side: MaterialStateProperty.all(const BorderSide(
                              color: Colors.white,
                            )),
                          ),
                          child: fav
                              ? const Icon(FontAwesomeIcons.arrowUpAZ,
                                  // fontSize: 20,
                                  color: Colors.white)
                              : const Icon(
                                  FontAwesomeIcons.arrowDownAZ,
                                  color: Colors.white,
                                )),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          if (fav3 || fav4) {
                            setState(() {
                              fav3 = false;
                              fav4 = false;
                              fav = false;
                              fav2 = false;
                            });

                            _servicesDisplay = sortAll(false);
                            if (isSelected.contains(true)) {
                              print(isSelected.toString());
                              isSelected.indexOf(true) + 1;
                              _servicesDisplay =
                                  filtered(isSelected.indexOf(true) + 1);
                            }

                            _scrollUp();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xff222b45)),
                          minimumSize: MaterialStateProperty.resolveWith(
                            (states) => const Size(32.0, 32.0),
                          ),
                          shape:
                              MaterialStateProperty.all(const CircleBorder()),
                          side: MaterialStateProperty.all(BorderSide(
                            color: fav3 || fav4 ? Colors.white : Colors.white38,
                          )),
                        ),
                        child: Icon(
                          CupertinoIcons.clear,
                          color: fav3 || fav4 ? Colors.white : Colors.white38,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            // decoration: BoxDecoration(border:),
            color: Colors.indigo,

            height: 20,
            padding: EdgeInsets.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  lastUpdate != null ? lastUpdateString(lastUpdate!) : "",
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ]),
      ),

// todo
      body: Container(
        color: const Color(0xff222b45),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 1),

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

          child: LiquidPullToRefresh(
            borderWidth: 1.5,
            backgroundColor: Colors.white,
            color: Colors.indigo,
            // color: const Color(0xff222b45).withOpacity(0.5),
            height: 80,
            animSpeedFactor: 3,
            springAnimationDurationInMilliseconds: 500,
            showChildOpacityTransition: false,
            onRefresh: () {
              return Future.delayed(
                const Duration(seconds: 1),
                () {
                  fetchServices().then((value) {
                    setState(() {
                      _services.clear();
                      _services.addAll(value);

                      if (isSelected[0]) {
                        _servicesDisplay = filtered(1);
                      } else if (isSelected[1]) {
                        _servicesDisplay = filtered(2);
                      } else if (isSelected[2]) {
                        _servicesDisplay = filtered(3);
                      } else {
                        _servicesDisplay = _services;
                        _servicesDisplay = sortAll(false);
                      }

                      lastUpdate = _services
                          .map((e) => e.lastUpdate)
                          .reduce((min, e) => e.isAfter(min) ? e : min);
                    });
                  });

                  /// adding elements in list after [1 seconds] delay
                  /// to mimic network call
                  ///
                  /// Remember: setState is necessary so that
                  /// build method will run again otherwise
                  /// list will not show all elements
                },
              );
            },
            child: AlignedGridView.extent(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(15),
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

  //TODO fonction à garder pour future évolutions
  _searchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 375),
            height: 40.0,
            width: (toggle == false)
                ? 40.0
                : MediaQuery.of(context).size.width * 0.8,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: -10.0,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Stack(
              children: [
                // AnimatedPositioned(
                //   duration: Duration(milliseconds: 375),
                //   // top: 6.0,
                //   right: 7.0,
                //   curve: Curves.easeOut,
                //   child: AnimatedOpacity(
                //     opacity: (toggle == 0) ? 0.0 : 1.0,
                //     duration: Duration(milliseconds: 200),
                //     child: Container(
                //       padding: EdgeInsets.all(8.0),
                //       decoration: BoxDecoration(
                //         color: Color(0xffF2F3F7),
                //         borderRadius: BorderRadius.circular(30.0),
                //       ),
                //       // child: AnimatedBuilder(
                //       //   child: Icon(
                //       //     Icons.mic,
                //       //     size: 20.0,
                //       //   ),
                //       //   builder: (context, widget) {
                //       //     return Transform.rotate(
                //       //       angle: _con.value * 2.0 * pi,
                //       //       child: widget,
                //       //     );
                //       //   },
                //       //   animation: _con,
                //       // ),
                //     ),
                //   ),
                // ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 575),
                  left: (toggle == false) ? 20.0 : 40.0,
                  // curve: Curves.easeOut,
                  top: 9.5,
                  child: AnimatedOpacity(
                    opacity: (toggle == false) ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: SizedBox(
                      height: 23.0,
                      width: 400.0,
                      child: TextField(
                        controller: _textEditingController,
                        cursorRadius: const Radius.circular(10.0),
                        cursorWidth: 2.0,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: 'Recherchez une application',
                          labelStyle: const TextStyle(
                            color: Color(0xff5B5B5B),
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  // color: Colors.red,
                  shadowColor: Colors.indigo.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30.0),
                  child: IconButton(
                    // hoverColor: Colors.indigo.withOpacity(0.2),

                    splashRadius: 30.0,
                    // splashColor: Colors.red,
                    icon: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 25.0,
                    ),
                    onPressed: () {
                      setState(
                        () {
                          if (toggle == false) {
                            _con.reverse();
                            isSelected = <bool>[false, false, false];

                            _servicesDisplay = _services;
                            toggle = true;
                          } else {
                            _textEditingController.clear();
                            _con.forward();
                            toggle = false;
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    // return Padding(
    //   padding: const EdgeInsets.all(12.0),
    //   child: Container(
    //     decoration: BoxDecoration(
    //       color: Colors.white.withOpacity(0.4),
    //       borderRadius:  BorderRadius.circular(32),
    //     ),
    //     child: TextField(
    //       autofocus: false,
    //       onChanged: (searchText) {
    //         searchText = searchText.toLowerCase();
    //         setState(() {
    //           _servicesDisplay = _services.where((u) {
    //             var lName = u.libelle.toLowerCase();
    //             var dName = u.description.toLowerCase();
    //             return lName.contains(searchText)
    //                 // || dName.contains(searchText)
    //                 ;
    //           }).toList();
    //         });
    //       },
    //       // controller: _textController,
    //       decoration: const InputDecoration(
    //
    //         iconColor: Colors.white,
    //
    //         // enabledBorder: OutlineInputBorder(
    //         //   borderRadius: BorderRadius.circular(40),
    //         //   borderSide: const BorderSide(color: Colors.white),
    //         // ),
    //         // focusedBorder: OutlineInputBorder(
    //         //   borderRadius: BorderRadius.circular(40),
    //         //   borderSide: const BorderSide(color: Color(0xFF3366ff)),
    //         // ),
    //         // errorBorder: OutlineInputBorder(
    //         //     borderRadius: BorderRadius.circular(40),
    //         //     borderSide: const BorderSide(color: Colors.red)),
    //         filled: true,
    //         // fillColor: Colors.white.withOpacity(0.3),
    //         // fillColor: const Color(0xff222b45).withOpacity(0.1),
    //
    //         border: InputBorder.none,
    //         // border: OutlineInputBorder(
    //         //     borderRadius: BorderRadius.circular(40),
    //         //     borderSide: const BorderSide(color: Colors.white)),
    //
    //         prefixIcon: Icon(Icons.search, color: Colors.white),
    //         hintText: ('Recherchez une application'),
    //         hintStyle: TextStyle(fontSize: 18.0, color: Colors.white),
    //       ),
    //     ),
    //   ),
    // );
  }

  void onPressed() {
    print("coucou");
  }
}

class MasonryGridTile extends StatelessWidget {
  final Service service;

  const MasonryGridTile({Key? key, required this.service}) : super(key: key);

  static const List<Widget> icons = <Widget>[
    Icon(
      Icons.sunny,
      color: Color(0xff04dc9a),
      size: 17,
    ),
    Icon(CupertinoIcons.umbrella_fill, color: Color(0xffdd9e51), size: 17),
    Icon(Icons.flash_on, color: Color(0xffff3d71), size: 17),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.02, 0.02],
            colors: [serviceColor(service.qualiteDeServiceId), Colors.white]),
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.white,
        // border: Border(
        //   top: BorderSide(
        //     width: 4.0,
        //     color: serviceColor(service.qualite_de_service_id),
        //   ),
        // ),
        //   border: Border.all(
        //     color: serviceColor(service.qualite_de_service_id),
        //     width: 3,
        //   ),
      ),
      // padding: const EdgeInsets.only(top: 10),
      width: 450,
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      // ClipRRect(
      //   borderRadius: const BorderRadius.only(
      //     topLeft: Radius.circular(10.0),
      //     topRight: Radius.circular(10.0),
      //   ),
      //   child: Image(
      //     image: AssetImage(image),
      //   ),
      // ),
      // Padding(
      //   padding: const EdgeInsets.only(bottom: 5),
      //   child:
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //   color: serviceColor(service.qualite_de_service_id),
          //   height: 4.0,
          // ),
          Padding(
            padding: const EdgeInsets.only(
                bottom: 5.0, left: 15, right: 15, top: 15),
            child: Stack(children: [
              Text(
                service.libelle,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color.fromRGBO(74, 74, 74, 1)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  icons[service.qualiteDeServiceId - 1]
                  // Icon(Icons.ac_unit, size: 15),
                ],
              )
            ]),
          ),
          // const Divider(
          //   thickness: 1.0,
          //   // color: Colors.white,
          // ),
          Container(
            color: serviceColor(service.qualiteDeServiceId),
            height: 25,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  service.qualiteDeService,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Html(data: markdownToHtml(service.description)),
          )
        ],
      ),
      // )
      //   ],
      // ),
    );
  }

  serviceColor(int qualiteDeServiceId) {
    switch (qualiteDeServiceId) {
      case 1:
        return const Color(0xff04dc9a);
      case 2:
        return const Color(0xffdd9e51);
      case 3:
        return const Color(0xffff3d71);
    }
  }
}
