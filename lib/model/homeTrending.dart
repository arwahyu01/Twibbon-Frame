import 'dart:convert';

HomeTrending homeTrendingFromJson(String str) => HomeTrending.fromJson(json.decode(str));

class HomeTrending {
  HomeTrending({
    required this.data,
    required this.total,
    required this.results,
  });

  String data;
  int total;
  List<Result> results;

  factory HomeTrending.fromJson(Map<String, dynamic> json) => HomeTrending(
        data: json["data"],
        total: json["total"],
        results:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
      );
}

class Result {
  Result({
    required this.uuid,
    required this.name,
    required this.url,
    required this.description,
    required this.thumbnail,
    required this.createdAt,
    required this.updatedAt,
  });

  String uuid;
  String name;
  String url;
  String description;
  String thumbnail;
  String createdAt;
  String updatedAt;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        uuid: json["uuid"],
        name: json["name"],
        url: json["url"],
        description: json["description"] ?? '',
        thumbnail: json["thumbnail"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"] ?? '',
      );
}
