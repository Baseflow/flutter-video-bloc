import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

import 'controls/audio_control.dart';
import 'controls/play_control.dart';
import 'controls/progress_indicator_control.dart';
import 'video_cubit.dart';
import 'video_state.dart';

class VideoControls extends HookWidget {
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
    double _getOffsetY(bool visible) => visible ? 0 : height * -1;
    Offset _getOffset(bool visible) => Offset(0.0, _getOffsetY(visible));

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
                    final child = _buildBar(
                      context,
                      cubit: cubit,
                    );
                    // No animation if visibility not changed yet
                    if (state.visibilityNotChanged) {
                      return Positioned(
                        height: height,
                        left: 0.0,
                        right: 0.0,
                        bottom: _getOffsetY(state.controlsVisible),
                        child: child,
                      );
                    }
                    return TweenAnimationBuilder<Offset>(
                      duration: Duration(milliseconds: 150),
                      tween: Tween<Offset>(
                        begin: _getOffset(state.controlsNotVisible),
                        end: _getOffset(state.controlsVisible),
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
                      child: child,
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
