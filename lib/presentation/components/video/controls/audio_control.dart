import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../video_cubit.dart';
import '../video_state.dart';

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
