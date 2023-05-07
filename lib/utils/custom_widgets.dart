import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:night_solver/screens/custom_toast.dart';
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
                  AspectRatio(aspectRatio: 3/4, child:
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
            Expanded(
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
                                    WidgetSpan(child: SizedBox(width: getHorizontalSize(22))),
                                    TextSpan( text: item.rating.toString()),
                                    WidgetSpan(child: SizedBox(width: getHorizontalSize(2))),
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
                          GetGenresNames(item.genres),
                          style: AppStyle.txtPoppinsRegular14,
                          overflow: TextOverflow.ellipsis,
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


class VerticalMovieCardWithLikeButton extends StatefulWidget {
  const VerticalMovieCardWithLikeButton(
    {Key? key,
    required this.item,
    required this.salonName,
    required this.IdList})
    : super(key: key);
  final MovieInfo item;
  final String salonName;
  final List IdList;

  @override
  State<StatefulWidget> createState() => VerticalMovieCardWithLikeButtonState();
}

class VerticalMovieCardWithLikeButtonState extends State<VerticalMovieCardWithLikeButton>{
  bool isVoted = false;
  final user = FirebaseAuth.instance.currentUser!;

  void unVoteMovie() async {
    for (String member in widget.IdList) {
      final DocumentReference DocRef = FirebaseFirestore.instance.collection('users').doc(member);
      DocRef.update({'salons.${widget.salonName}.votes.${user.uid}': FieldValue.arrayRemove([widget.item.id])});
    }
    CustomToast.showToast(context, ' You unvoted ${widget.item.title}');
  }

  void voteMovie() async {
    for (String member in widget.IdList) {
      final DocumentReference DocRef = FirebaseFirestore.instance.collection('users').doc(member);
      DocRef.update({'salons.${widget.salonName}.votes.${user.uid}': FieldValue.arrayUnion([widget.item.id])});
    }
    CustomToast.showToast(context, ' You voted for ${widget.item.title}');
  }


  Future<void> getData() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    var votes = snapshot.data()!['salons'][widget.salonName]['votes'];
    if(votes != null){
      if(votes[user.uid].contains(widget.item.id)){
        setState(() {
          isVoted = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

    @override
  Widget build(BuildContext context) =>
      InkWell(
          onTap: () =>
              Navigator.of(context).pop,
          child: Container(
            width: getHorizontalSize(379),
            height: getVerticalSize(273),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(children: [
                      Container(
                          height: getVerticalSize(273),
                          width: getHorizontalSize(163),
                          child:
                          Image.network(widget.item.urlImage, fit: BoxFit.fill,
                            filterQuality: FilterQuality.high,)),
                      Positioned(
                        right: getHorizontalSize(-1),
                        child: Container(
                          child: IconButton(
                            onPressed: null,
                            icon: ImageIcon(
                              AssetImage(
                                widget.item.canDelete
                                    ? 'assets/icons/bookmark_filled.png'
                                    : 'assets/icons/bookmark_empty.png',
                              ),
                              color: widget.item.canDelete
                                  ? ColorConstant.red900
                                  : ColorConstant.whiteA700,
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
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      widget.item.title,
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
                                        TextSpan(text: widget.item.rating.toString()),
                                        WidgetSpan(child: SizedBox(
                                            width: getHorizontalSize(20))),
                                        WidgetSpan(child: RatingBarIndicator(
                                          itemBuilder: (context, index) =>
                                              Icon(Icons.star_rounded,
                                                  color: ColorConstant.red900),
                                          itemCount: 5,
                                          rating: widget.item.rating,
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
                                widget.item.synopsis,
                                style: AppStyle.txtPoppinsRegular13,
                                maxLines: 7,
                                overflow: TextOverflow.ellipsis,
                              )
                          ),
                          Expanded(
                            child: Container(
                              child: IconButton(
                                onPressed: () {
                                  isVoted
                                        ? unVoteMovie()
                                        : voteMovie();
                                  setState(() {
                                    isVoted
                                        ? isVoted = false
                                        : isVoted = true;
                                  });
                                },
                                icon: ImageIcon(
                                  AssetImage(
                                    isVoted
                                        ? 'assets/icons/heart_filled_icon.png'
                                        : 'assets/icons/heart_empty_icon.png',                                  ),
                                  color: isVoted ? ColorConstant.red900 : ColorConstant.whiteA700,
                                ),
                              ),
                            ),
                          ),
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

class ShortVerticalCard extends StatelessWidget {
  const ShortVerticalCard({
    super.key,
    required this.context,
    required this.item,
  });

  final BuildContext context;
  final MovieInfo item;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => MovieDetail(item: item))),
      child: Column(
        children: [
          Expanded(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(children: [
                    AspectRatio(
                        aspectRatio: 0.7,
                        child: Image.network(item.urlImage,
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.high)),
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
              ),)
                  ]))),
          SizedBox(
            height: getVerticalSize(16),
          ),
          Container(
              width: getHorizontalSize(150),
              height: getVerticalSize(40),
              child: Padding(padding: getPadding(left: 2), child:
          Align(alignment: Alignment.centerLeft,
                      child: Text(
                        item.title,
                        style: AppStyle.txtPoppinsSemiBold18,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )))),
          Align( alignment: Alignment.center,
              child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: item.rating.toString()),
                    WidgetSpan(child: SizedBox(width: getHorizontalSize(8),)),
                    WidgetSpan(
                        child: Icon(
                          Icons.star_rounded,
                          color: ColorConstant.red900,
                        )
                    )
                  ],
                  style: AppStyle.txtPoppinsMedium18,
                  ),
              )
          )
        ],
      ));
}