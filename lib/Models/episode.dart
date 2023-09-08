// "id": 51,
// "title": null,
// "slug": null,
// "sequence": 1,
// "profile_pic": "http://test.niri9.com/doc/default/file-upload.png",
// "episode_code": "S01E01",
// "note": "",
// "duration": 0,
// "video_player": "",
// "status": 1,
// "readable_time": "0 hour 0 minute",
// "last_viewed_duration": 0,
// "last_viewed_percent": 0
class Episode {
  int? id,
      sequence,
      duration,
      status,
      last_viewed_duration,
      last_viewed_percent;
  String? title,
      slug,
      profile_pic,
      episode_code,
      note,
      video_player,
      readable_time;

  Episode.fromJson(json) {
    id = json['id'] ?? 0;
    sequence = json['sequence'] ?? 1;
    duration = json['duration'] ?? 0;
    status = json['status'] ?? 0;
    last_viewed_duration = json['last_viewed_duration'] ?? 0;
    last_viewed_percent = json['last_viewed_percent'] ?? 0;
    //
    title = json['title']??"";
  }
}
