import 'package:flutter/material.dart';
import 'package:newmap2/Product/ProductList.dart';
import 'package:newmap2/Product/SearchProduct.dart';
import '../ChangeLanguage/app_translations.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> category = [
    "Brake Disc",
    "Seat belt",
    "Oil Filter",
    "Spark Plug"
  ];

  final List<Color> colors = [
    Color(0xffF19821),
    Color(0xff99BACB),
    Color(0xff498D7C),
    Color(0xff4E97F2),
    Color(0xffEFB958),
    Color(0xffB196C4),
    Color(0xffF49824),
    Color(0xffF95F35),
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> topGenres = [
      AppTranslations.of(context).text("allitems"),
      AppTranslations.of(context).text("mainitem"),
      AppTranslations.of(context).text("tool"),
      AppTranslations.of(context).text("accessories")
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProductList()));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height*0.10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      shape: BoxShape.rectangle,
                      color: Colors.redAccent,
                    ),
                    child: Center(

                      child: Text(
                        AppTranslations.of(context).text("all"),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, top: 20),
              child: Text(
                AppTranslations.of(context).text("categories"),
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: (MediaQuery.of(context).size.width / (2 * 100)),
              children: List.generate(4, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SearchProduct("type", category[index])));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          shape: BoxShape.rectangle,
                          color: colors[index],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                          child: Text(
                            topGenres[index],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
