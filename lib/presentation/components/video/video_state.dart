import 'package:video_player/video_player.dart';

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
