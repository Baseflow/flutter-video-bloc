import 'package:flutter_bloc/flutter_bloc.dart';

import 'video_state.dart';

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
