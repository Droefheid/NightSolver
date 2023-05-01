import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/screens/preference_page.dart';
import '../theme/app_style.dart';
import '../utils/color_constant.dart';
class Providers extends StatefulWidget {
  const Providers({Key? key, required this.IdList, required this.salonName})
      : super(key: key);
  final IdList;
  final salonName;
  State<Providers> createState() => _ProvidersState();
}
class _ProvidersState extends State<Providers> {
  // Define provider logos
  Map<String, String> providerLogos = {
    "Netflix": "assets/netflix.png",
    "Amazon Prime Video": "assets/amazon.png",
    "Disney Plus": "assets/disney.png",
    "Apple TV": "assets/apple.png",
  };

  // Define provider selections
  Map<String, bool> providerSelections = {
    "Netflix": false,
    "Amazon Prime Video": false,
    "Disney Plus": false,
    "Apple TV": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.gray900,
      appBar: AppBar(
        backgroundColor: ColorConstant.gray900,
        leading: IconButton(
          icon: ImageIcon(
            AssetImage("assets/icons/back_arrow_red.png"),
            color: ColorConstant.red900,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Select your platform",
                style: AppStyle.txtPoppinsBold30,
              ),
              TextSpan(text: ".", style: AppStyle.txtPoppinsBold30Red),
            ],
          ),
          textAlign: TextAlign.left,
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        children: providerLogos.keys.map((providerName) {
          return GestureDetector(
            onTap: () {
              setState(() {
                providerSelections[providerName] =
                !providerSelections[providerName]!;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: providerSelections[providerName]!
                    ? ColorConstant.red900
                    : ColorConstant.gray800,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Image.asset(
                  providerLogos[providerName]!,
                  fit: BoxFit.contain,
                  height: 100,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: buildSubmit(),
    );
  }
  Widget buildSubmit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            for (String member in widget.IdList) {
              FirebaseFirestore.instance.collection('users').doc(member).set({
                'salons': {
                  widget.salonName: {'providers': providerSelections}
                }
              }, SetOptions(merge: true));
            }
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Preferences(
                    salonName: widget.salonName,
                    IdList: widget.IdList,
                    providerStat: providerSelections)));
          },
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(ColorConstant.redA700),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)))),
          child: Text('Next', style: AppStyle.txtPoppinsMedium18Grey),
        ),
      ],
    );
  }
}
