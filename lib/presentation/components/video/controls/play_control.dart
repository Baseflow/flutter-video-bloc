import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../video_cubit.dart';
import '../video_state.dart';

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
    return BlocBuilder<VideoCubit, VideoState>(
      buildWhen: (previous, current) {
        return previous.playing != current.playing;
      },
      builder: (_, state) {
        return GestureDetector(
          onTap: BlocProvider.of<VideoCubit>(context).togglePlay,
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
