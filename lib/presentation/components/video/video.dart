import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import 'video_cubit.dart';
import 'video_state.dart';

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
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      child: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) {
          Widget? child;
          if (state.notLoaded) {
            child = Center(
              child: CircularProgressIndicator(),
            );
          } else {
            child = VideoPlayer(
              state.controller,
            );
          }
          return AspectRatio(
            key: ValueKey(state.loaded),
            aspectRatio: aspectRatio,
            child: child,
          );
        },
      ),
    );
  }
}
