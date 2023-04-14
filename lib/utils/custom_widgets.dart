import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:night_solver/utils/size_utils.dart';

import '../screens/movie_details.dart';
import '../theme/app_style.dart';
import 'color_constant.dart';
import 'movie_info.dart';

class VerticalMovieCard extends StatelessWidget {
  const VerticalMovieCard({
    super.key,
    required this.item,
  });

  final MovieInfo item;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: () => Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => MovieDetail(item: item))),
      child: Container(
    width: getHorizontalSize(379),
    height: getVerticalSize(273),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(item.urlImage, fit: BoxFit.fill, filterQuality: FilterQuality.high,)
        ),
        Padding(padding: getMargin(left: 16),
            child: Column(
                children: [
                  Container(
                      height: getVerticalSize(60),
                      width: getHorizontalSize(163),
                      child:Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyle.txtPoppinsBold20
                          )
                      )
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                          TextSpan(
                              children: [
                                TextSpan( text: item.rating.toString()),
                                WidgetSpan(child: SizedBox(width: getHorizontalSize(20))),
                                WidgetSpan(child: RatingBarIndicator(
                                  itemBuilder: (context, index) => Icon(Icons.star_rounded, color: ColorConstant.red900),
                                  itemCount: 5,
                                  rating: item.rating,
                                  itemSize: getSize(28),
                                  unratedColor: ColorConstant.gray700,
                                ),
                                )
                              ],
                              style: AppStyle.txtPoppinsMedium22
                          )
                      )
                  ),

                  Container(
                    height: getVerticalSize(30),
                    width: getHorizontalSize(161),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Action, Fantasy, Adventure",
                      style: AppStyle.txtPoppinsRegular14,
                    ),
                  ),
                  Container(
                      height: getVerticalSize(100),
                      width: getHorizontalSize(180),
                      child: Text(
                          item.synopsis,
                          style: AppStyle.txtPoppinsRegular13
                      )
                  )
                ])
        )
      ],
    ),
  ));
}