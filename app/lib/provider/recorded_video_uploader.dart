import 'dart:io';

import 'package:app/service_provider/shared_preferences_provider.dart';
import 'package:app/services/file_uploader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "recorded_video_uploader.g.dart";

const _notUploadedVideoPathsKey = "notUploadedVideoPaths";
const _recordingIdsKey = "recordingIds";

@riverpod
class RecordedVideoUploader extends _$RecordedVideoUploader {
  @override
  Future<int> build() async {
    final videos = ref
        .read(sharedPreferencesProvider)
        .getStringList(_notUploadedVideoPathsKey);
    return videos?.length ?? 0;
  }

  Future<void> addVideo(File videoFile, String recordingId) async {
    final videos = ref
            .read(sharedPreferencesProvider)
            .getStringList(_notUploadedVideoPathsKey) ??
        [];
    final recordingIds =
        ref.read(sharedPreferencesProvider).getStringList(_recordingIdsKey) ??
            [];
    videos.add(videoFile.path);
    recordingIds.add(recordingId);
    assert(videos.length == recordingIds.length);
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_notUploadedVideoPathsKey, videos);
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_recordingIdsKey, recordingIds);
    state = AsyncData(videos.length);
  }

  Future<void> uploadAllNotUploadedVideos() async {
    final videos = ref
        .read(sharedPreferencesProvider)
        .getStringList(_notUploadedVideoPathsKey);
    final recordingIds =
        ref.read(sharedPreferencesProvider).getStringList(_recordingIdsKey);
    if (videos == null || recordingIds == null) {
      return;
    }
    final originalVideos = [...videos];
    final originalRecordingIds = [...recordingIds];
    state = const AsyncData(0);
    for (var i = 0; i < videos.length; i++) {
      final file = File(videos[i]);
      final recordingId = recordingIds[i];
      try {
        await uploadFileToService(file, recordingId);
      } catch (e) {
        print("Failed to upload file: $recordingId");
        continue;
      }
      videos[i] = "";
      recordingIds[i] = "";
    }
    videos.removeWhere((element) => element.isEmpty);
    recordingIds.removeWhere((element) => element.isEmpty);
    final currentVideos = ref
            .read(sharedPreferencesProvider)
            .getStringList(_notUploadedVideoPathsKey) ??
        [];
    final currentRecordingIds =
        ref.read(sharedPreferencesProvider).getStringList(_recordingIdsKey) ??
            [];
    currentVideos.removeWhere((element) => originalVideos.contains(element));
    currentRecordingIds
        .removeWhere((element) => originalRecordingIds.contains(element));
    assert(videos.length == recordingIds.length);
    await ref.read(sharedPreferencesProvider).setStringList(
        _notUploadedVideoPathsKey, [...videos, ...currentVideos]);
    await ref.read(sharedPreferencesProvider).setStringList(
        _recordingIdsKey, [...recordingIds, ...currentRecordingIds]);
    state = AsyncData(videos.length);
  }
}
