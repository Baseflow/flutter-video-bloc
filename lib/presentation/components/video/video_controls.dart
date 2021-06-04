import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import 'controls/audio_control.dart';
import 'controls/play_control.dart';
import 'controls/progress_indicator_control.dart';
import 'video_cubit.dart';
import 'video_state.dart';

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
                    return TweenAnimationBuilder<Offset?>(
                      duration: Duration(milliseconds: 150),
                      tween: Tween<Offset>(
                        begin: state.controlsVisible
                            ? Offset(0.0, height * -1)
                            : Offset(0.0, 0.0),
                        end: state.controlsVisible
                            ? Offset(0.0, 0.0)
                            : Offset(0.0, height * -1),
                      ),
                      builder: (_, value, child) {
                        return Positioned(
                          height: height,
                          left: 0.0,
                          right: 0.0,
                          bottom: value?.dy ?? height * -1,
                          child: child!,
                        );
                      },
                      child: _buildBar(
                        context,
                        cubit: cubit,
                      ),
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
