
class Video {
  final String churchDocID;
  final String videoDocID;
  final bool isLive;
  final String link;
  final String title;
  final bool isConference;
  final String churchName;
  
  const Video({required this.churchDocID, required this.videoDocID, required this.isLive, required this.link, required this.title, required this.isConference, required this.churchName});

  factory Video.fromMap(Map<String,dynamic> data) {
    return Video(churchDocID: data["churchDocID"], videoDocID: data["videoDocID"], isLive: data["isLive"], link: data["link"], title: data["title"], isConference: data["isConference"], churchName: data["churchName"]);
  }

}