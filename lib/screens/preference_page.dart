import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/screens/custom_toast.dart';
import 'package:night_solver/screens/result_screen.dart';

import '../theme/app_style.dart';
import '../utils/color_constant.dart';

class Preferences extends StatefulWidget {
  const Preferences({Key? key, required this.salonName, required this.IdList, required this.providerStat}) : super(key: key);
  final salonName;
  final providerStat;
  final IdList;
  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  double actionValue = 50;
  double aventureValue = 50;
  double comedieValue = 50;
  double crimeValue = 50;
  double dramaValue = 50;
  double fantasyValue = 50;
  double horrorValue = 50;
  double scifiValue = 50;

  Color mainColor = const Color(0xff3C3261);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.gray900,
      appBar: AppBar(
          backgroundColor: ColorConstant.gray900,
          leading: IconButton(
            icon: ImageIcon(AssetImage("assets/icons/back_arrow_red.png"), color: ColorConstant.red900,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "Which genres",
                    style: AppStyle.txtPoppinsBold30
                ),
                TextSpan(
                    text: "?",
                    style: AppStyle.txtPoppinsBold30Red
                ),
              ]),
              textAlign: TextAlign.left
          )
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Adventure',
                textAlign: TextAlign.left,
                style: AppStyle.txtPoppinsBold30),
            buildSideLabel("aventureValue", aventureValue),
            Text('Action',
                style: AppStyle.txtPoppinsBold30),
            buildSideLabel("actionValue", actionValue),
            Text('Comedy',
                style: AppStyle.txtPoppinsBold30),
            buildSideLabel("comedieValue", comedieValue),
            Text('Crime',
                style: AppStyle.txtPoppinsBold30),
            buildSideLabel("crimeValue", crimeValue),
            Text('Drama',
                style: AppStyle.txtPoppinsBold30),
            buildSideLabel("dramaValue", dramaValue),
            Text('Fantasy',
                style: AppStyle.txtPoppinsBold30),
            buildSideLabel("fantasyValue", fantasyValue),
            Text('Horror',
                style: AppStyle.txtPoppinsBold30),
            buildSideLabel("horrorValue", horrorValue),
            Text('Sci-Fi',
                style: AppStyle.txtPoppinsBold30),
            buildSideLabel("scifiValue", scifiValue),
            buildSubmit(),
          ],
        ),
      ),
    );
  }

  Widget buildSideLabel(String field, double value) {
    return Row(
      children: [
        Text('Not at all',
            style: AppStyle.txtPoppinsMedium18Red),
        Expanded(
          child: Slider(
            value: value,
            activeColor: ColorConstant.red900,
            inactiveColor: ColorConstant.gray700,
            min: 0,
            max: 100,
            divisions: 4,
            onChanged: (newValue) {
              setState(() {
                if (field == "aventureValue") {
                  aventureValue = newValue;
                } else if (field == "actionValue") {
                  actionValue = newValue;
                } else if (field == "comedieValue") {
                  comedieValue = newValue;
                }else if (field == "crimeValue") {
                  crimeValue = newValue;
                }else if (field == "dramaValue") {
                  dramaValue = newValue;
                }else if (field == "fantasyValue") {
                  fantasyValue = newValue;
                }else if (field == "horrorValue") {
                  horrorValue = newValue;
                }else if (field == "scifiValue") {
                  scifiValue = newValue;
                }
              });
            },
          ),
        ),
        Text('A lot',
            style: AppStyle.txtPoppinsMedium18Red),
      ],
    );
  }

  Widget buildSubmit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          //width: MediaQuery.of(context).size.width- 80,
          height: 60,
          child: ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser!;
              for (String member in widget.IdList){
                FirebaseFirestore.instance
                  .collection('users')
                  .doc(member)
                  .set({
                    'salons' :
                      {widget.salonName :
                        {'preferences' :
                          {user.uid :
                            {'aventure': aventureValue,
                              'action': actionValue,
                              'comedie': comedieValue,
                              'crime': crimeValue,
                              'drama':dramaValue,
                              'fantasy': fantasyValue,
                              'horror': horrorValue,
                              'scifi': scifiValue,
                            }
                          }
                        }
                      }
                    },
                  SetOptions(merge : true));
                }
              final snapshot = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
              var setPreferences = snapshot.data()!['salons'][widget.salonName]['preferences'].keys;
              List result = widget.IdList.where((element) => !setPreferences.contains(element)).toList();
              if(result.length != 0){
                CustomToast.showToast(context, 'your preferences have been updated');
                List names = [];
                for (int i = 0; i < result.length; i++){
                  final DocumentReference friendDocRef =
                  FirebaseFirestore.instance.collection('users').doc(result[i]);
                  DocumentSnapshot snapshot = await friendDocRef.get();
                  final String friendName = snapshot['displayName'];
                  names.add(friendName);
                }
                String showNames = names.length > 2 ? '${names.sublist(0, names.length - 1).join(", ")} and ${names.last}' : names.join(' and ');
                CustomToast.showToast(context, 'waiting for $showNames to set their preferences');
              }
              else{
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ResultScreen(
                      salonName : widget.salonName,
                      IdList : widget.IdList,
                      providers: widget.providerStat
                  )));}}
,
            child: Text('Submit',
                style: AppStyle.txtPoppinsMedium18Grey),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(ColorConstant.redA700),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)
                    )
                )
            ),
          ),
        ),
      ],
    );
  }
}
