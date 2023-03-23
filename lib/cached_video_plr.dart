import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CachedVideoPlayerController controller;
  var timeElapset = 0;
  double percent = 0;
  var isPlaying = true;
  @override
  void initState() {
    controller = CachedVideoPlayerController.network(
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4");

    controller.initialize().then((value) {
      controller.setLooping(true);
      controller.play();
      setState(() {});
    });

    controller.addListener(() {
      // print(controller.value);
      // print(controller.value.duration.inMilliseconds);
      // print(controller.value.position.inMilliseconds);
      setState(() {
        percent = controller.value.position.inMilliseconds /
            controller.value.duration.inMilliseconds *
            100;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(controller.value.position);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: Stack(
        children: [
          Center(
              child: controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: CachedVideoPlayer(controller))
                  : const CircularProgressIndicator()),
          Positioned(
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(.4))]),
              width: MediaQuery.of(context).size.width,
              // width: 400,
              child: Row(
                children: [
                  InkWell(
                      onTap: () async {
                        if (isPlaying) {
                          await controller.pause();
                          isPlaying = false;
                        } else {
                          await controller.play();
                          isPlaying = true;
                        }
                        setState(() {});
                      },
                      child: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),
                  Text(Duration(
                          milliseconds: (percent *
                                  controller.value.duration.inMilliseconds /
                                  100)
                              .toInt())
                      // .inMinutes
                      .toString()
                      .substring(0, 7)),
                  // "${Duration(milliseconds: (percent * controller.value.duration.inMilliseconds).toInt()).inMinutes} :// ${Duration(milliseconds: (percent * controller.value.duration.inMilliseconds).toInt()).toString().substring(0, 7)}"),
                  Expanded(
                    child: Slider(
                        min: 0,
                        max: 100,
                        value: percent,
                        onChanged: (v) async {
                          if (v > 0) {
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      content: SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: CircularProgressIndicator()),
                                    ));
                            percent = v;
                            await controller.seekTo(Duration(
                                milliseconds: (percent /
                                        100 *
                                        controller
                                            .value.duration.inMilliseconds)
                                    .toInt()));
                            Navigator.pop(context);
                            setState(() {});
                          }
                        }),
                  ),
                  Text(controller.value.duration
                      // .inMinutes
                      .toString()
                      .substring(0, 7)),
                ],
              ),
            ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
