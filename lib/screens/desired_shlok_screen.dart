// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:main_hoon_arjun/screens/comment_screen.dart';
import 'package:main_hoon_arjun/widgets/shareImage.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/translation_card.dart';
import '../widgets/profile_picture.dart';
import '../widgets/shlok_card.dart';
import '../widgets/speaker_icon_button.dart';
import '../providers/playing_shlok.dart';

class DesiredShlokScreen extends StatefulWidget {
  static const routeName = '/desiredShlok-screen';

  DesiredShlokScreen({this.emotions, this.shlokMap});

  dynamic emotions;
  Map<String, dynamic> shlokMap;

  @override
  State<DesiredShlokScreen> createState() => _DesiredShlokScreenState();
}

class _DesiredShlokScreenState extends State<DesiredShlokScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = ScreenshotController();

  var _user;
  var doc;

  String currentShlok;
  String shlokNo;
  String chapterNo;
  bool isFavorite = false;

  Future<String> getshlokUrl() async {
    return await FirebaseStorage.instance
        .ref()
        .child('Shlok Audio Files')
        .child(currentShlok.substring(0, 9))
        .child('Chap${chapterNo}_Shlok$shlokNo.mp3')
        .getDownloadURL();
  }

  void toggleFavShlok() {
    isFavorite = !isFavorite;
  }

  bool itExists;

  @override
  void initState() {
    super.initState();
    () async {
      _user = FirebaseAuth.instance.currentUser;
      doc = await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(_user.uid)
          .get();

      itExists = doc.exists;
    }();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    SpeakerIcnBtn.player.stop();

    if (!doc.exists) {
      await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(_user.uid)
          .set({
        'fav_sholks': [currentShlok]
      });
    } else {
      var data = doc.data();
      var favoriteShloks = data['fav_sholks'];
      if (isFavorite) {
        if (!favoriteShloks.contains(currentShlok)) {
          favoriteShloks.add(currentShlok);
          await FirebaseFirestore.instance
              .collection('user_favorites')
              .doc(_user.uid)
              .set({'fav_sholks': favoriteShloks});
        }
      } else {
        favoriteShloks.remove(currentShlok);
        await FirebaseFirestore.instance
            .collection('user_favorites')
            .doc(_user.uid)
            .set({'fav_sholks': favoriteShloks});
      }
    }
  }

  bool isShareVisible = true;

  @override
  Widget build(BuildContext context) {
    final _deviceSize = MediaQuery.of(context).size;

    return FutureBuilder(
      future: widget.emotions == null
          ? FirebaseFirestore.instance.collection('emotions').doc('Happy').get()
          : FirebaseFirestore.instance
              .collection('emotions')
              .doc(widget.emotions['emotion'])
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: SpinKitFadingCircle(
                color: Colors.orange,
              ),
            ),
            backgroundColor: Colors.orange.shade50,
          );
        }
        if (snapshot.hasData) {
          if (widget.shlokMap != null) {
            currentShlok =
                '${widget.shlokMap["Chapter"]}_${widget.shlokMap["ShlokNo"]}';
            chapterNo = currentShlok.substring(7, 9);
            shlokNo = currentShlok.substring(15);
          }
          if (widget.emotions != null) {
            var allShloks = snapshot.data['shloks'];
            currentShlok = allShloks[Random().nextInt(allShloks.length)];
            chapterNo = currentShlok.substring(7, 9);
            shlokNo = currentShlok.substring(15);
          }

          if (itExists) {
            var docData = doc.data();
            var favoriteShloks = docData['fav_sholks'];
            if (favoriteShloks.contains(currentShlok)) {
              isFavorite = true;
            }
          }
        }
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("Shlok"),
            actions: [
              ProfilePicture(),
            ],
          ),
          backgroundColor: Colors.orange.shade50,
          body: ListView(
            children: [
              Screenshot(
                controller: _controller,
                child: ShlokCard(
                  currentShlok: currentShlok,
                  isFavorite: isFavorite,
                  toggleFavorite: toggleFavShlok,
                  shlokNo: shlokNo,
                  chapterNo: chapterNo,
                ),
              ),
              SizedBox(
                height: _deviceSize.height * 0.03,
              ),
              Container(
                margin:
                    EdgeInsets.symmetric(horizontal: _deviceSize.width * 0.42),
                child: ChangeNotifierProvider(
                  create: (ctx) => PlayingShlok(),
                  child: SpeakerIcnBtn(
                    audioUrl: getshlokUrl(),
                    shlokIndex: 0,
                    isDesired: true,
                  ),
                ),
              ),
              SizedBox(
                height: _deviceSize.height * 0.03,
              ),
              TranslationCard(
                currentShlok: currentShlok,
                shlokNo: shlokNo,
                chapterNo: chapterNo,
              ),
              //Comment button
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     primary: Colors.orange,
              //     shape: CircleBorder(),
              //   ),
              //   child: Container(
              //     padding: const EdgeInsets.all(12),
              //     child: Icon(
              //       Icons.comment,
              //       color: Colors.orange.shade50,
              //     ),
              //   ),
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => CommentScreen(
              //                 currentShloK: currentShlok,
              //               )),
              //     );
              //   },
              // ),    
              //comment button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentScreen(
                        currentShloK: currentShlok,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                     color: Colors.orange[100],
                    // border: Border.all(
                    //   color: Colors.orange,
                    // ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.fromLTRB(35, 5, 35, 50),
                  padding: EdgeInsets.symmetric(vertical: 6),
                  width: double.infinity,
                  child: Center(
                      child: Text(
                    'View thoughts..',
                    style:  TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                  )),
                ),
              )
            ],
          ),
          floatingActionButton: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.orange,
              shape: CircleBorder(),
            ),
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Icon(
                Icons.share,
                color: Colors.orange.shade50,
              ),
            ),
            onPressed: () async {
              final image = await _controller.capture();
              if (image != null) {
                // await saveImage(image);
                ShareImage.shareImage(image);
              }
            },
          ),
        );
      },
    );
  }
}
