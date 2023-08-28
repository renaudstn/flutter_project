// import 'package:flutter/material.dart';
// import 'package:markdown_widget/markdown_widget.dart';
//
// import '../../data/data_model.dart';
// import '../screens/service_details_page.dart';
//
// class ServiceTile extends StatelessWidget {
//   final Service service;
//
//   const ServiceTile({super.key, required this.service});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//
//       // alignment: Alignment.center,
//       // clipBehavior: Clip.hardEdge,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(5),
//           border: Border.all(
//             color: serviceColor(service.qualite_de_service_id),
//             width: 3,
//           )),
//
//       padding: const EdgeInsets.all(15),
//
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => UserDetailsPage(user: service)));
//         },
//         child: Column(
//           // crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               service.libelle,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//             ),
//             const Divider(
//               thickness: 1.0,
//               // color: Colors.white,
//             ),
//             // Text(
//
//             Expanded(
//               child:
//                   MarkdownWidget(
//                     data: service.description,
//                   ),
//             )
//
//             // style: const TextStyle(color: Colors.white),
//             // maxLines: 5,
//             // overflow: TextOverflow.ellipsis,
//             // overflow: TextOverflow.visible,
//
//             // ),
//           ],
//         ),
//       ),
//       // ),
//     );
//   }
//
// serviceColor(int qualiteDeServiceId) {
//   switch (qualiteDeServiceId) {
//     case 1:
//       return const Color(0xff04dc9a);
//     case 2:
//       return const Color(0xffdd9e51);
//     case 3:
//       return const Color(0xffff3d71);
//   }
// }
// }

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:meteo_du_numerique/data/data_model.dart';

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

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.index,
    required this.service,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  }) : super(key: key);

  final int index;
  final Service service;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      color: backgroundColor ?? Colors.white,
      padding: const EdgeInsets.all(15),
      height: extent,
      // height: ,
      // child: Center(
      // child: CircleAvatar(
      //   minRadius: 20,
      //   maxRadius: 20,
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   child: Text('$index', style: const TextStyle(fontSize: 20)),
      // ),
      // ),

      child: InkWell(
        onTap: () {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => UserDetailsPage(user: service)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              service.libelle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(
              thickness: 1.0,
              // color: Colors.white,
            ),
            // Text(

            Expanded(

              child: MarkdownWidget(
                data: service.description,

              ),
            )

            // style: const TextStyle(color: Colors.white),
            // maxLines: 5,
            // overflow: TextOverflow.ellipsis,


            // ),
          ],
        ),
      ),
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: const Color(0xff04dc9a),
        )
      ],
    );
  }
}
