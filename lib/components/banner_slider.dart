
import 'package:app/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> imgList;

class BannerSlider extends StatefulWidget {

  @override
  _BannerSliderState createState() => _BannerSliderState();

}

class _BannerSliderState extends State<BannerSlider> {

  bool loading = true;
  List<Widget> imageSliders;

  Future<void> getBanner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    imgList = prefs.getStringList("banner") ?? [""];
    imageSliders = imgList.map((item) => Container(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            child: Stack(
              children: <Widget>[
                FadeInImage(
                  image: CachedNetworkImageProvider(item),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                  placeholder: AssetImage('assets/white_bg.png'),
                ),
//                Positioned(
//                  top: 0.0,
//                  right: 0.0,
//                  child: Container(
//
//                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
//                    child: Text(
//                      '${(imgList.indexOf(item))+1}/${imgList.length}',
//                      style: TextStyle(
//                        color: kPrimaryColor,
//                        fontSize: 14.0,
//                        fontWeight: FontWeight.w400,
//                      ),
//                    ),
//                  ),
//                ),
              ],
            )
        ),
      ),
    )).toList();
    setState(() {
      loading = false;
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBanner();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Container() : CarouselSlider(
      options: CarouselOptions(
          autoPlay: true,
          height: 130,
          aspectRatio: 2.35,
          enlargeCenterPage: true,
          autoPlayInterval: Duration(seconds: 9),
          viewportFraction: 0.79,
          pauseAutoPlayOnTouch: true,
          disableCenter: true
      ),
      items: imageSliders,
    );
  }
}