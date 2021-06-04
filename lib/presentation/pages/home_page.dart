import 'package:flutter/material.dart';

import '../components/video/video.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home page',
        ),
      ),
      body: Column(
        children: [
          Video.blocProvider(
            // Normally you'll get both the url and the aspect ratio from your video meta data
            'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
            aspectRatio: 1.77,
            autoPlay: false,
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Hello world!',
            ),
          ),
        ],
      ),
    );
  }
}
