import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:night_solver/screens/preference_page.dart';
import 'package:night_solver/utils/size_utils.dart';

import '../theme/app_style.dart';
import '../utils/color_constant.dart';

class Providers extends StatefulWidget {
  const Providers({Key? key,required this.IdList, required this.salonName} ) : super(key: key);
  final IdList;
  final salonName;
  @override
  State<Providers> createState() => _ProvidersState();
}
//TODO fais en logo
class _ProvidersState extends State<Providers>{
  var providers = {
  "Netflix":0,
  "Amazon Prime Video" : 0,
  "Disney Plus" : 0,
  "Apple TV":0,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.gray900,
      appBar:  AppBar(
          backgroundColor: ColorConstant.gray900,
          leading: IconButton(
            icon: ImageIcon(AssetImage("assets/icons/back_arrow_red.png"), color: ColorConstant.red900,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "Select your platform",
                    style: AppStyle.txtPoppinsBold30
                ),
                TextSpan(
                    text: ".",
                    style: AppStyle.txtPoppinsBold30Red
                ),
              ]),
              textAlign: TextAlign.left
          )
      ),
      body:
          Column(children: [
            Wrap(
              children: [
                ProvideroCell("Netflix"),
                ProvideroCell("Amazon Prime Video"),
                ProvideroCell("Disney Plus"),
                ProvideroCell("Apple TV"),
              ],
            ),
            Padding(
                padding: getPadding(top: 400),
                child:
            buildSubmit())
          ]),
    );
  }
  Widget ProvideroCell( String field){
    return Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: (providers[field]==0) ? MaterialStateProperty.all<Color>(ColorConstant.gray800) : MaterialStateProperty.all<Color>(ColorConstant.red900),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)
                  )
              )
          ),
            onPressed: (){
              setState(() {
                if(providers[field]==0){
                  providers[field]=1;
                }else{
                  providers[field]=0;
                }
              }
              );
              },
            child: Text(
              field,
              style: (providers[field]==0) ? AppStyle.txtPoppinsMedium18 : AppStyle.txtPoppinsMedium18Grey,
            )
        )
    );
  }
  Widget buildSubmit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () {
              for (String member in widget.IdList){
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(member)
                    .set({'salons' : {widget.salonName : {'providers' : providers}}}, SetOptions(merge : true));
              }
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Preferences(salonName: widget.salonName, IdList : widget.IdList, providerStat : providers)));
            },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(ColorConstant.redA700),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)
              )
            )
          ),
            child: Text(
                'Next',
                style: AppStyle.txtPoppinsMedium18Grey
            ),
          ),
      ],
    );
  }
}