import 'package:flutter/material.dart';
import 'package:main_hoon_arjun/providers/translation.dart';
import 'package:provider/provider.dart';

import 'package:main_hoon_arjun/widgets/shlok_selection.dart';
import 'package:main_hoon_arjun/widgets/verse_page.dart';

class AdhyayOverviewScreen extends StatefulWidget {
  static const routename = "/AdhyayOverviewScreen";

  final String title;
  final String adhyayName;
  final List<Map<String, dynamic>> chapterData;
  final List<String> shlokList;
  final int initialPage;

  bool isBookmarked;
  String bookmarkedShlok;

  AdhyayOverviewScreen({
    this.title,
    this.adhyayName,
    this.chapterData,
    this.shlokList,
    this.initialPage,
  });

  @override
  State<AdhyayOverviewScreen> createState() => _AdhyayOverviewScreenState();
}

class _AdhyayOverviewScreenState extends State<AdhyayOverviewScreen> {
  PageController controller;
  int pagechanged;
  String currentShlok;
  bool isBookmark;

  var doc;

  @override
  void initState() {
    super.initState();
    pagechanged = widget.initialPage + 1;
    controller = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    var _deviceSize = MediaQuery.of(context).size;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Translation(),
        ),
      ],
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Scaffold(
          backgroundColor: Colors.orange.shade50,
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(_deviceSize.height * 0.070),
              child: BuildAppBar(
                chapterData: widget.chapterData,
                shlokList: widget.shlokList,
                controller: controller,
                adhyayName: widget.adhyayName,
                adhyayNumber: widget.title,
                deviceSize: _deviceSize,
              )),
          body: Stack(
            children: [
              PageView.builder(
                onPageChanged: (index) {
                  pagechanged = index + 1;
                },
                controller: controller,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return index == widget.shlokList.length - 1
                      ? VersePage(
                          isLastPage: true,
                          currentShlok:
                              "Chapter${widget.chapterData[index]['chapter']}_${widget.shlokList[index]}",
                          verseNumber: index + 1,
                          shlokTitle: widget.chapterData[index]['shlok'],
                          pageController: controller,
                          shlokText: widget.chapterData[index]['text'],
                          meaning: widget.chapterData[index]['meaning'],
                          translation: widget.chapterData[index]['translation'],
                        )
                      : VersePage(
                          isLastPage: false,
                          currentShlok:
                              "Chapter${widget.chapterData[index]['chapter']}_${widget.shlokList[index]}",
                          verseNumber: index + 1,
                          shlokTitle: widget.chapterData[index]['shlok'],
                          pageController: controller,
                          shlokText: widget.chapterData[index]['text'],
                          meaning: widget.chapterData[index]['meaning'],
                          translation: widget.chapterData[index]['translation'],
                        );
                },
                itemCount: widget.shlokList.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildAppBar extends StatelessWidget {
  final PageController controller;

  BuildAppBar({
    @required this.controller,
    @required this.adhyayName,
    @required this.adhyayNumber,
    @required this.chapterData,
    @required this.shlokList,
    this.deviceSize,
  });
  final deviceSize;
  final String adhyayName;
  final String adhyayNumber;
  final List<Map<String, dynamic>> chapterData;
  final List<String> shlokList;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.orange), //change your color here
      elevation: 0,
      backgroundColor: Colors.orange.shade100,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: deviceSize.width * 0.02,
              top: deviceSize.height * 0.01,
            ),
            child: Text(
              adhyayName,
              style: TextStyle(
                fontSize: deviceSize.height * 0.022,
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: deviceSize.width * 0.02),
            child: Text(
              adhyayNumber.substring(0, 7) + " " + adhyayNumber.substring(7),
              style: TextStyle(
                  fontSize: deviceSize.height * 0.017,
                  color: Colors.orange[600],
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(
            right: deviceSize.width * 0.03,
          ),
          child: IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ShlokSelection(
                        chapterData: chapterData,
                        shlokList: shlokList,
                        pageController: controller,
                      );
                    });
              },
              icon: Image.asset(
                "assets/images/gridViewIcon.png",
                height: 26,
              )),
        )
      ],
    );
  }
}
