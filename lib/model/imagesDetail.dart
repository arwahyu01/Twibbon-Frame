import 'dart:convert';

ImagesDetail imagesDetailFromJson(String str) => ImagesDetail.fromJson(json.decode(str));

class ImagesDetail {
    ImagesDetail({
        required this.data,
        required this.total,
        required this.results,
    });

    String data;
    int total;
    Results results;

    factory ImagesDetail.fromJson(Map<String, dynamic> json) => ImagesDetail(
        data: json["data"],
        total: json["total"],
        results: Results.fromJson(json["results"]),
    );

}

class Results {
    Results({
        required this.name,
        required this.description,
        required this.thumbnail,
        required this.frames,
        required this.createdAt,
        required this.updatedAt,
    });

    String name;
    String description;
    String thumbnail;
    List<String> frames;
    String createdAt;
    String updatedAt;

    factory Results.fromJson(Map<String, dynamic> json) => Results(
        name: json["name"],
        description: json["description"],
        thumbnail: json["thumbnail"],
        frames: List<String>.from(json["frames"].map((x) => x)),
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
    );

}
