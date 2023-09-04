import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:video_player/video_player.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage(
      {Key? key,
      required this.mentor,
      required this.title,
      required this.courseID})
      : super(key: key);

  final String mentor;
  final String title;
  final String courseID;

  @override
  State<CoursesPage> createState() =>
      _CoursesPageState(mentor, title, courseID);
}

class _CoursesPageState extends State<CoursesPage> {
  late String _mentor;
  late String _title;
  late String _courseID;
  String text = '';
  late Widget returned;
  List<Image> _images = [];
  Map<String, VideoPlayerWidget> _vidsControllers = {};
  bool textFinished = false;
  bool picsFinished = false;
  bool vidsFinished = false;

  _CoursesPageState(String mentor, String title, String courseID) {
    _mentor = mentor;
    _title = title;
    _courseID = courseID;
  }

  @override
  void initState() {
    retrieveText();
    retrievePics();
    retrieveVids();
    super.initState();
  }

  Widget setupText() {
    List<String> lines = text.split('\n');
    List<Widget> formattedContent = [];

    List<String> currentList = [];
    for (String line in lines) {
      if (line.startsWith('-') ||
          line.startsWith('*') ||
          line.startsWith('•')) {
        currentList.add(line.substring(1).trim());
      } else {
        if (currentList.isNotEmpty) {
          formattedContent.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: currentList
                  .map((item) => ListTile(
                      contentPadding:
                          EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                      dense: true,
                      visualDensity: VisualDensity(vertical: -4),
                      title: Text(
                        '-$item',
                        style: TextStyle(fontSize: 15),
                      )))
                  .toList(),
            ),
          );
          currentList.clear();
        }
        formattedContent.add(Text(
          line,
          style: TextStyle(fontSize: 15),
        ));
      }
    }

    if (currentList.isNotEmpty) {
      formattedContent.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: currentList
              .map((item) => ListTile(
                  dense: true,
                  visualDensity: VisualDensity(vertical: -4),
                  title: Text('-$item', style: TextStyle(fontSize: 15))))
              .toList(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: formattedContent,
      ),
    );
  }

  void retrieveText() async {
    ListResult check = await StorageCrud.getStorage()
        .ref()
        .child('Mentors/$_mentor/courses/$_courseID')
        .listAll();

    if (check.items.isNotEmpty) {
      for (Reference item in check.items) {
        String name = item.fullPath.split('/').last;
        if (name.contains('text')) {
          Uint8List? result = await StorageCrud.getStorage()
              .ref()
              .child('Mentors/$_mentor/courses/$_courseID/text.txt')
              .getData();
          text = utf8.decode(result!);
          returned = setupText();

          setState(() {
            textFinished = true;
          });
        }
      }
    }
  }

  void retrievePics() async {
    ListResult result = await StorageCrud.getStorage()
        .ref()
        .child('Mentors/$_mentor/courses/$_courseID')
        .listAll();

    if (result.items.isNotEmpty) {
      for (Reference item in result.items) {
        String name = item.fullPath.split('/').last;
        if (name.contains('picture')) {
          Uint8List? tmp = await StorageCrud.getStorage()
              .ref()
              .child('Mentors/$_mentor/courses/$_courseID/$name')
              .getData();
          _images.add(Image.memory(tmp!));
        }
      }
    }

    setState(() {
      picsFinished = true;
    });
  }

  void retrieveVids() async {
    ListResult result = await StorageCrud.getStorage()
        .ref()
        .child('Mentors/$_mentor/courses/$_courseID')
        .listAll();

    for (Reference item in result.items) {
      String name = item.fullPath.split('/').last;
      if (name.contains('video')) {
        String? url = await StorageCrud.getStorage()
            .ref()
            .child('Mentors/$_mentor/courses/$_courseID/$name')
            .getDownloadURL();

        _vidsControllers[url] = VideoPlayerWidget(url: url);
      }
    }

    setState(() {
      vidsFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MyAppBar(
          title: 'Course Page',
        ),
        body: ListView(
          children: [
            //TITLE
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  AppLayout.kModalHorizontalPadding,
                  AppLayout.kHeightSmall,
                  AppLayout.kModalHorizontalPadding,
                  0),
              child: Text(
                _title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            //TEXT
            textFinished
                ? ContainerShadow(
                    margin: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppLayout.kModalHorizontalPadding,
                        vertical: 0),
                    child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 5,
                            vertical: AppLayout.kHeightSmall / 2),
                        child: returned))
                : ContainerShadow(
                    child: Container(height: 150),
                  ),
            Container(
              height: AppLayout.kHeight,
            ),
            //IMAGES
            Container(
              alignment: AlignmentDirectional.topStart,
              padding: const EdgeInsetsDirectional.fromSTEB(
                  AppLayout.kModalHorizontalPadding, 0, 0, 0),
              child: const Text(
                "Images",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(
              height: 0,
              indent: AppLayout.kHorizontalPadding,
              endIndent: AppLayout.kHorizontalPadding,
              thickness: 2,
            ),
            picsFinished
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _images.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      return ContainerShadow(
                          color: const ui.Color(0xffffcc80),
                          margin: EdgeInsetsDirectional.fromSTEB(
                              index % 2 == 0
                                  ? AppLayout.kModalHorizontalPadding
                                  : AppLayout.kModalHorizontalPadding / 2,
                              AppLayout.kHeightSmall,
                              index % 2 != 0
                                  ? AppLayout.kModalHorizontalPadding
                                  : AppLayout.kModalHorizontalPadding / 2,
                              AppLayout.kHeightSmall),
                          child: Image(
                              image: _images[index].image,
                              fit: BoxFit.contain));
                    })
                : Container(),
            Container(
              height: AppLayout.kHeight,
            ),
            //VIDEOS
            Container(
              alignment: AlignmentDirectional.topStart,
              padding: const EdgeInsetsDirectional.fromSTEB(
                  AppLayout.kModalHorizontalPadding, 0, 0, 0),
              child: const Text(
                "Videos",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(
              height: 0,
              indent: AppLayout.kHorizontalPadding,
              endIndent: AppLayout.kHorizontalPadding,
              thickness: 2,
            ),
            vidsFinished
                ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _vidsControllers.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ContainerShadow(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: AppLayout.kModalHorizontalPadding,
                                  vertical: AppLayout.kHeightSmall),
                              color: const ui.Color(0xffffcc80),
                              child: VideoPlayerWidget(
                                  url: _vidsControllers.keys.elementAt(index))),
                        ],
                      );
                    },
                  )
                : Container()
          ],
        ));
  }
}

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState(url);
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late String _url;
  late VideoPlayerController _controller;
  late Future<void> _initVideoPlayerFuture;

  _VideoPlayerWidgetState(String url) {
    _url = url;
  }

  @override
  void initState() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(_url));
    _initVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.play();
      _controller.setLooping(false);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
            future: _initVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller));
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true,
          colors: const VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.black),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  _controller.seekTo(Duration(
                    seconds: _controller.value.position.inSeconds - 10,
                  ));
                },
                child: const Icon(Icons.fast_rewind_outlined)),
            ElevatedButton(
                onPressed: () {
                  _controller.pause();
                },
                child: const Icon(Icons.pause_circle_outline)),
            ElevatedButton(
                onPressed: () {
                  _controller.play();
                },
                child: const Icon(Icons.play_circle_outline)),
            ElevatedButton(
                onPressed: () {
                  _controller.seekTo(Duration(
                    seconds: _controller.value.position.inSeconds + 10,
                  ));
                },
                child: const Icon(Icons.fast_forward_outlined)),
          ],
        )
      ],
    );
  }
}
