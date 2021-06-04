import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import 'video_controls.dart';
import 'video_cubit.dart';
import 'video_state.dart';

class Video extends StatelessWidget {
  const Video._(
    this.url, {
    Key? key,
    required this.aspectRatio,
    required this.controlsVisible,
    required this.autoPlay,
  }) : super(key: key);

  static Widget blocProvider(
    String url, {
    required double aspectRatio,
    bool? controlsVisible,
    bool autoPlay = true,
  }) {
    return BlocProvider(
      create: (_) {
        return VideoCubit(
          url,
          autoPlay: autoPlay,
          controlsVisible: !autoPlay,
        );
      },
      child: Video._(
        url,
        aspectRatio: aspectRatio,
        controlsVisible: controlsVisible ?? !autoPlay,
        autoPlay: autoPlay,
      ),
    );
  }

  final String url;
  final double aspectRatio;
  final bool controlsVisible;
  final bool autoPlay;

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
        )
      ],
    );
  }
}
