class News {
  List<Article> articles;
}

class Article {
  String city;
  String date;
  String river;
  String level;
  String urlToImage;

  Article(
      {this.city,
      this.date,
      this.river,
      this.level,
      this.urlToImage});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
        city: json["city"],
        date: json["date"],
        river: json["river"],
        level: json["level"],
        urlToImage: json["urlToImage"]);
  }

  Map<String, dynamic> toJson() => {
        "city": city,
        "date": date,
        "river": river,
        "level": level,
        "urlToImage": urlToImage,
    };
}