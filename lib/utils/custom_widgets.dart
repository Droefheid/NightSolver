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
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieDetail(item: item))),
      child: Container(
        width: getHorizontalSize(379),
        height: getVerticalSize(273),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack( children:[
                  Container(
                      height: getVerticalSize(273),
                      width: getHorizontalSize(182),
                      child:
                      Image.network(item.urlImage, fit: BoxFit.fill, filterQuality: FilterQuality.high,)),
                  Positioned(
                    right: getHorizontalSize(-1),
                    child: Container(
                      child: IconButton(
                        onPressed: null,
                        icon: ImageIcon(
                          AssetImage(
                            item.canDelete
                                ? 'assets/icons/bookmark_filled.png'
                                : 'assets/icons/bookmark_empty.png',
                          ),
                          color: item.canDelete ? ColorConstant.red900 : ColorConstant.whiteA700,
                        ),
                      ),
                    ),
                  ),
                ])
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
                          width: getHorizontalSize(163),
                          child: Text(
                            item.synopsis,
                            style: AppStyle.txtPoppinsRegular13,
                            maxLines: 7,
                            overflow: TextOverflow.ellipsis,
                          )
                      )
                    ])
            )
          ],
        ),
      ));
}

class GenreButton extends StatefulWidget {

  final String title;
  final Function(String, bool) onSelectedGenre;
  final bool isSelected;

  const GenreButton({
    super.key,
    required this.title,
    required this.onSelectedGenre,
    required this.isSelected
  });

  @override
  State<GenreButton> createState() => _GenreButtonState();
}

class _GenreButtonState extends State<GenreButton> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getVerticalSize(25),
        child: TextButton(
          onPressed: () => {
            widget.onSelectedGenre(widget.title, !widget.isSelected)
          },
          child: Text(
            widget.title,
            style: widget.isSelected
                ? AppStyle.txtPoppinsRegular14Gray900
                : AppStyle.txtPoppinsRegular14,
          ),
          style: TextButton.styleFrom(
            backgroundColor:
            widget.isSelected ? ColorConstant.red900 : ColorConstant.gray90001,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
    ));
  }
}