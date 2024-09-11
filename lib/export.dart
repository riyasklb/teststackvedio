import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> exportVideoWithOverlay({
  required File videoFile,
  required File watermarkImage,
  required String reporterName,
  required String channelName,
  required String breakingNewsText,
}) async {
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String outputPath = '${directory.path}/2output_video.mp4';

    // Simple FFmpeg command to scale the video to 320x240
String ffmpegCommand = '-loglevel debug -i ${videoFile.path} -c copy $outputPath';




    // Execute the FFmpeg command
    var session = await FFmpegKit.execute(ffmpegCommand);

    final returnCode = await session.getReturnCode();
    final output = await session.getOutput();

    print('FFmpeg Output: $output');

    if (ReturnCode.isSuccess(returnCode)) {
      print('FFmpeg command executed successfully.');
      return outputPath;
    } else {
      print('FFmpeg command failed with return code: $returnCode');
      return null;
    }
  } catch (e) {
    print('Error exporting video: $e');
    return null;
  }
}
