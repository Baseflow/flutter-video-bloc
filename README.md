In some of my consultancy projects I see people mix and match multiple state management solutions. This mostly happens because they've copy and pasted `StatefulWidget` solutions from some example found on the internet.. 

It works! OK commit! 

In my option this is a bad habit.. Always look if it’s possible to shorten the code for the implementation, upgrade parts of the implementation with up-to-date solutions or by customizing a small part of the implementation to match the tools/techniques chosen by you! 

Let me show you how I’ve implemented the [video_player](https://pub.dev/packages/video_player) in combination with [flutter_bloc](https://pub.dev/packages/flutter_bloc). The result of this demo can be found [here](https://github.com/Baseflow/flutter-style-guide) and the repo it based upon can be found [here](https://github.com/flutter/plugins/blob/master/packages/video_player/video_player/example/lib/main.dart?web=1&wdLOR=c61F7DC00-E742-D549-9F53-5F6C17ECAD78).

*Note: don’t get me wrong in some cases you need a `StatefulWidgets` or `HookWidget` (flutter_hooks) as you just cannot escape using them when for example adding complex animations to your app. Most of the simple animations can already be implemented by some widgets Flutter offers to you out of the box. You’ll see an example later in this blogpost as well.*


# Requirements
-	Being able to use and understand [BLoC](https://bloclibrary.dev/);
-	Having a basics understanding about animations in Flutter;

# Let’s start building the video widget!
First let’s create a new flutter project, clean up some of the boilerplate code and separate the classes into separate files.

![image](https://user-images.githubusercontent.com/1774351/120816779-a71cc400-c583-11eb-9157-9676155703ce.png)

*main.dart*
```dart
void main() {
  runApp(App());
}
```

*app.dart*
```dart
class App extends StatelessWidget {
  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
```

*home_page.dart*
```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
      ),
      body: const Text('Hello world!'),
    );
  }
}
```
## Added required dependencies
Let’s get our dependencies in place and add the required packages. Add the following dependencies to the `pubspec.yaml`  file.

*pubspec.yaml*
```yaml
dependencies:
  ...
  flutter_bloc: ^7.0.0
  video_player: ^2.1.1
```

Then make sure to get the packages by running the `flutter pub get` command.

## Let’s create our video component!  (controls come later)
Our `Video` widget will be based on the `VideoPlayer` widget from the [video_player](https://pub.dev/packages/video_player) package. The `VideoPlayer` requires a `VideoPlayerController` which we need to store in the BLoC state. 

By storing the `controller` in the BLoC state we’ll be able to pass in the same instance of the `VideoPlayerController` to the `VideoPlayer` widget on each build. To accomplish this, we need to create three files: `video.dart`, `video_cubit.dart` and `video_state.dart`.

In the state we need to store the `controller` and a `loaded` flag.
- `Controller` is required to let the `VideoPlayer` widget and for us to interact with the video once we create some custom controls.
- `Loaded` flag is required to let the UI know when the video is ready to display.

*video_state.dart*
```dart
class VideoState {
  VideoState._({
    required this.controller,
    required this.loaded,
  });

  factory VideoState.initialize({
    required String url,
  }) {
    final controller = VideoPlayerController.network(
      url,
    );
    return VideoState._(
      controller: controller,
      loaded: false,
    );
  }

  final VideoPlayerController controller;
  final bool loaded;

  bool get notLoaded => !loaded;

  VideoState copyWith({
    VideoPlayerController? controller,
    bool? loaded,
  }) {
    return VideoState._(
      controller: controller ?? this.controller,
      loaded: loaded ?? this.loaded,
    );
  }

  Future<void> dispose() async {
    controller.dispose();
  }
}
```

For the `cubit` we just create the `state` by calling the `VideoState.initialize(..)` and pass it into the super class as our `initial state`. The `state` can then be used inside the constructor's body to initialize the `controller` and update the `loaded` flag in our `state` when the `controller` has been succesfully initialized.

*video_bloc.dart*
```dart
class VideoCubit extends Cubit<VideoState> {
  VideoCubit(
    String url, {
    bool autoPlay = true,
  }) : super(VideoState.initialize(
          url: url,
        )) {
    state.controller.initialize().then((_) {
      emit(state.copyWith(
        loaded: true,
      ));
      if (autoPlay) {
        state.controller.play();
      }
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
    });
  }
}
```

Now for the video widget I’ve created a static `Widget blocProvider(..)` method in combination with a private constructor. This way the widget can only be constructed trough calling the `blocProvider(..)` which automatically wraps our `Video` widget with the `VideoCubit`. 

In the build method you can see that based on the loaded flag we show a loading indicator or the `VideoPlayer` widget. I've wrapped them with the `AnimatedSwitcher` widget to provide a smooth transition when replacing one with the other. 

*Note: the `AnimatedSwitcher` is a widget that Flutter provides to easily transition between two different widgets with a animation of your choice.*
 
*video.dart*
```dart
class Video extends StatelessWidget {
  const Video._(
    this.url, {
    Key? key,
    required this.aspectRatio,
  }) : super(key: key);

  static Widget blocProvider(
    String url, {
    required double aspectRatio,
  }) {
    return BlocProvider(
      create: (_) {
        return VideoCubit(url);
      },
      child: Video._(
        url,
        aspectRatio: aspectRatio,
      ),
    );
  }

  final String url;
  final double aspectRatio;

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocBuilder<VideoCubit, VideoState>(
      builder: (_, state) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          child: AspectRatio(
            key: ValueKey(state.loaded),
            aspectRatio: aspectRatio,
            child: state.notLoaded
                ? Center(child: CircularProgressIndicator())
                : VideoPlayer(state.controller),
          ),
        );
      },
    );
  }
}
```

Now we’ll only have to place the video on our home page by replacing the body of the scaffold with the following code.

*Note: I pass in some hard coded arguments into the `Video` widget. In a real-world scenario you would read these values out of the video metadata that you’ve stored somewhere on a database.*

*home_page.dart*
```dart
Column(
  children: [
    Video.blocProvider(
      // Normally you'll get both the URL and the aspect ratio from your video meta data
      'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
      aspectRatio: 1.77,
    ),
    const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Hello world!',
      ),
    ),
  ],
),
```

So now when you’ll run the app you should see something like this.

![2  basic video result](https://user-images.githubusercontent.com/1774351/120820961-99693d80-c587-11eb-9541-24b17941bdd8.gif)

Ok so now we’ve got the basic video in place only we are missing the controls to interact with the video. Of course, there are some packages which provide these to you out of the box, like [chewie](https://pub.dev/packages/chewie), but for this blog post we are going to create our own custom controls. To do this we are going to start with updating our state and add some extra properties.

*video_state.dart*
```dart
  VideoState._({
    …
    required this.controlsVisible,
    required this. controlsVisiblePrevious,
    required this.playing,
    required this.volume,
    required this.volumeBeforeMute,
  });

  factory VideoState.initialize({
    …
    required bool autoPlay,
    required bool controlsVisible,
  }) {
    …
    return VideoState._(
      …
      controlsVisible: controlsVisible,
      controlsVisiblePrevious: controlsVisible,
      playing: autoPlay,
      volume: controller.value.volume,
      volumeBeforeMute: controller.value.volume, 
    …

  final bool controlsVisible;
  final bool controlsVisiblePrevious;
  final bool playing;
  final double volume;
  final double volumeBeforeMute;

  bool get visibilityChanged => controlsVisible != controlsVisiblePrevious;
  bool get visibilityNotChanged => !visibilityChanged;
  bool get notPlaying => !playing;
  bool get controlsNotVisible => !controlsVisible;
  bool get mute => volume <= 0;
  bool get notMute => volume > 0;

  VideoState copyWith({
    …
    bool? controlsVisible,
    bool? playing,
    double? volume,
    double? volumeBeforeMute,
  }) {
    var controlsVisiblePrevious = this.controlsVisiblePrevious;
    if (controlsVisible != null) {
      controlsVisiblePrevious = !controlsVisible;
    }
    return VideoState._(
      …
      controlsVisible: controlsVisible ?? this.controlsVisible,
      controlsVisiblePrevious: controlsVisiblePrevious,
      playing: playing ?? this.playing,
      volume: volume ?? this.volume,
      volumeBeforeMute: volumeBeforeMute ?? this.volumeBeforeMute,
    …
```

*Note: when you reach the point that you’ve got many control properties you could provide the `VideoControls` (to be created) widget with its own state and cubit.*

Now with the state in place we can start extending our cubit so we can start controlling our `Video` widget. 

*video_cubit.dart*
```dart
VideoCubit(
  String url, {
  bool autoPlay = true,
  bool controlsVisible = false,
}) : super(VideoState.initialize(
        url: url,
        autoPlay: autoPlay,
        controlsVisible: controlsVisible,
      )) …

void togglePlay() {
  state.playing ? state.controller.pause() : state.controller.play();
  emit(state.copyWith(
    playing: !state.playing,
  ));
}

void toggleControlsVisibility() {
  emit(state.copyWith(
    controlsVisible: !state.controlsVisible,
  ));

  if (state.controlsNotVisible && state.notPlaying) {
    togglePlay();
  }
}

void setVolume(
  double value,
) {
  state.controller.setVolume(value);
  emit(state.copyWith(
    volume: value,
  ));
}

void toggleMute() {
  var newState = state.copyWith(
    volume: state.mute ? state.volumeBeforeMute : 0,
    volumeBeforeMute: state.notMute ? state.volume : state.volumeBeforeMute,
  );
  state.controller.setVolume(newState.volume);
  emit(newState);
} 
```

Ok so now with the cubit in place we only need to build our `VideoControls` widget together with the `AudioControl`, `PlayControl` and `ProgressIndicatorControl` widgets. 

![3  controls structue](https://user-images.githubusercontent.com/1774351/120828639-5612cd00-c58f-11eb-84d6-8da7002e900c.png)

*Note: the `VideoControls` widget is setup to be used inside of an `Stack` widget.* 

The `GestureDetector` is used to make the controlbar appear or dissapear when the user taps on the video. To also make this a bit more beautiful the `TweenAnimationBuilder` has been added to give an nice animation to this process. 

The `previous.controlsVisible != current.controlsVisible` condition in the `BlocBuilder` makes sure that the controlbar only gets build when the visibility flag has changed. This is good for performance as if the condition is to be removed the entire controlbar will be rebuild also when nonrelevant in the state has been changed.

*video_controls.dart*
```dart
class VideoControls extends StatelessWidget {
  const VideoControls(
    this.controller, {
    Key? key,
    this.iconSize = 36,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 4.0,
    ),
  }) : super(key: key);

  final VideoPlayerController controller;
  final double iconSize;
  final EdgeInsets padding;

  static const _heightProgressControl = 4.0;

  double get height => iconSize + _heightProgressControl + padding.vertical;

  double _getOffsetY(
    bool visible,
    bool initialVisibility,
  ) {
    // No animation on initial visibility
    if (initialVisibility) {
      return 0;
    }
    return visible ? 0 : height * -1;
  }

  Offset _getOffset(
    bool visible,
    bool initialVisibility,
  ) {
    return Offset(
      0.0,
      _getOffsetY(
        visible,
        initialVisibility,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final cubit = BlocProvider.of<VideoCubit>(context);
    return GestureDetector(
      onTap: cubit.toggleControlsVisibility,
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: height,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                BlocBuilder<VideoCubit, VideoState>(
                  buildWhen: (previous, current) {
                    return previous.controlsVisible != current.controlsVisible;
                  },
                  builder: (context, state) {
                    return TweenAnimationBuilder<Offset>(
                      child: _buildBar(
                        context,
                        cubit: cubit,
                      ),
                      duration: Duration(milliseconds: 150),
                      tween: Tween<Offset>(
                        begin: _getOffset(
                          state.controlsNotVisible,
                          state.visibilityNotChanged,
                        ),
                        end: _getOffset(
                          state.controlsVisible,
                          state.visibilityNotChanged,
                        ),
                      ),
                      builder: (_, value, child) {
                        return Positioned(
                          height: height,
                          left: 0.0,
                          right: 0.0,
                          bottom: value.dy,
                          child: child!,
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
    BuildContext context, {
    required VideoCubit cubit,
  }) {
    return Container(
      color: Colors.black38,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlayControl(
                  iconSize: iconSize,
                ),
                AudioControl(
                  iconSize: iconSize,
                ),
              ],
            ),
          ),
          ProgressIndicatorControl(
            controller: controller,
          ),
        ],
      ),
    );
  }
}
```

So for the `PlayControl` below you see that I’ve, again, applied a `buildWhen` condition to make sure the widget only gets rebuild when relevant data in the state has been changed.

*play_control.dart*
```dart
class PlayControl extends StatelessWidget {
  const PlayControl({
    Key? key,
    required this.iconSize,
  }) : super(key: key);

  final double iconSize;

  @override
  Widget build(
    BuildContext context,
  ) {
    final cubit = BlocProvider.of<VideoCubit>(context);
    return BlocBuilder<VideoCubit, VideoState>(
      buildWhen: (previous, current) {
        return previous.playing != current.playing;
      },
      builder: (_, state) {
        return GestureDetector(
          onTap: cubit.togglePlay,
          child: Icon(
            state.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        );
      },
    );
  }
}
```

Yet again for the `AudioControl` I’ve applied a `buildWhen` condition to make sure the widget only gets rebuild when relevant data in the state has been changed.

*audio_control.dart*
```dart
class AudioControl extends StatelessWidget {
  const AudioControl({
    Key? key,
    required this.iconSize,
  }) : super(key: key);

  final double iconSize;

  @override
  Widget build(
    BuildContext context,
  ) {
    final cubit = BlocProvider.of<VideoCubit>(context);
    return BlocBuilder<VideoCubit, VideoState>(
      buildWhen: (previous, current) {
        return previous.volume != current.volume;
      },
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: iconSize,
              child: Slider(
                value: state.volume,
                onChanged: cubit.setVolume,
              ),
            ),
            GestureDetector(
              onTap: cubit.toggleMute,
              child: Icon(
                _determineVolumeIcon(state.volume),
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _determineVolumeIcon(
    double volume,
  ) {
    if (volume == 0) {
      return Icons.volume_off_rounded;
    }
    if (volume < 0.25) {
      return Icons.volume_mute_rounded;
    }
    if (volume < 0.5) {
      return Icons.volume_down_rounded;
    }
    return Icons.volume_up_rounded;
  }
}
```

For the `ProgressIndicatorControl` we just use the existing `VideoProgressIndicator` but with some custom colors applied.

*progress_indicator_control.dart*
```dart
class ProgressIndicatorControl extends StatelessWidget {
  const ProgressIndicatorControl({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(
    BuildContext context,
  ) {
    return VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      padding: const EdgeInsets.all(0),
      colors: VideoProgressColors(
        backgroundColor: Colors.transparent,
        bufferedColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        playedColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      ),
    );
  }
}
```

Then as last we need to update the `Video` widget make sure the `VideoPlayer` and `VideoControls` widgets are correctly stacked by using the `Stack` widget.

*video.dart*
```dart
const Video._(
…
static Widget blocProvider(
  …
  bool autoPlay = true,
  bool? controlsVisible,
}) {
  return BlocProvider(
    create: (_) {
      return VideoCubit(
        …
        autoPlay: autoPlay,
        controlsVisible: controlsVisible ?? !autoPlay,
      );
    },
  …
@override
Widget build(
  BuildContext context,
) {
  return AnimatedSwitcher(
    duration: Duration(milliseconds: 100),
    child: BlocBuilder<VideoCubit, VideoState>(
      builder: (_, state) {
        return AspectRatio(
          key: ValueKey(state.loaded),
          aspectRatio: aspectRatio,
          child: state.notLoaded
              ? Center(child: CircularProgressIndicator())
              : _buildVideo(state),
        );
      },
    ),
  );
}

Stack _buildVideo(
  VideoState state,
) {
  return Stack(
    alignment: Alignment.bottomCenter,
    children: [
      VideoPlayer(
        state.controller,
      ),
      VideoControls(
        state.controller,
      ),
    ],
  );
}
```

And this should be it! At this point you should’ve got a working `Video` widget with custom controls of which the state is managed by BLoC. 

![3  video with controls result](https://user-images.githubusercontent.com/1774351/120824302-e6024800-c58a-11eb-84dd-98024cceff37.gif)

So now you know my implementation of the `video_player` in combination with `flutter_bloc`. There are always improvements to be made so if you spot some, please share them with me down below! 

You can also find me on Twitter ([@jop_middelkamp](https://twitter.com/jop_middelkamp)) and [LinkedIn](https://www.linkedin.com/in/jopmiddelkamp/) or even by mail to [jop@baseflow.com](mailto:jop@baseflow.com). Please leave your feedback if you have some!