import 'package:video_player/video_player.dart';

class VideoState {
  VideoState._({
    required this.controller,
    required this.loaded,
    required this.controlsVisible,
    required this.playing,
    required this.volume,
    required this.volumeBeforeMute,
  });

  factory VideoState.initialize({
    required String url,
    required bool autoPlay,
  }) {
    final controller = VideoPlayerController.network(
      url,
    );
    return VideoState._(
      controller: controller,
      loaded: false,
      controlsVisible: false,
      playing: autoPlay,
      volume: controller.value.volume,
      volumeBeforeMute: controller.value.volume,
    );
  }

  final VideoPlayerController controller;
  final bool loaded;
  final bool controlsVisible;
  final bool playing;
  final double volume;
  final double volumeBeforeMute;

  bool get notLoaded => !loaded;
  bool get notPlaying => !playing;
  bool get controlsNotVisible => !controlsVisible;
  bool get mute => volume <= 0;
  bool get notMute => volume > 0;

  VideoState copyWith({
    VideoPlayerController? controller,
    bool? loaded,
    bool? controlsVisible,
    bool? playing,
    double? volume,
    double? volumeBeforeMute,
  }) {
    return VideoState._(
      controller: controller ?? this.controller,
      loaded: loaded ?? this.loaded,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      playing: playing ?? this.playing,
      volume: volume ?? this.volume,
      volumeBeforeMute: volumeBeforeMute ?? this.volumeBeforeMute,
    );
  }

  Future<void> dispose() async {
    controller.dispose();
  }
}
