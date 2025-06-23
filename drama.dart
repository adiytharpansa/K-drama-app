class Episode {
  final String judul;
  final String videoUrl;

  Episode({
    required this.judul,
    required this.videoUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      judul: json['judul'] ?? '',
      videoUrl: json['video_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'video_url': videoUrl,
    };
  }
}

class Drama {
  final String judul;
  final String cover;
  final List<String> genre;
  final String sinopsis;
  final List<Episode> episode;

  Drama({
    required this.judul,
    required this.cover,
    required this.genre,
    required this.sinopsis,
    required this.episode,
  });

  factory Drama.fromJson(Map<String, dynamic> json) {
    return Drama(
      judul: json['judul'] ?? '',
      cover: json['cover'] ?? '',
      genre: List<String>.from(json['genre'] ?? []),
      sinopsis: json['sinopsis'] ?? '',
      episode: (json['episode'] as List?)
          ?.map((e) => Episode.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'cover': cover,
      'genre': genre,
      'sinopsis': sinopsis,
      'episode': episode.map((e) => e.toJson()).toList(),
    };
  }

  bool containsGenre(String genreFilter) {
    return genre.any((g) => g.toLowerCase().contains(genreFilter.toLowerCase()));
  }

  bool matchesSearch(String query) {
    return judul.toLowerCase().contains(query.toLowerCase()) ||
           sinopsis.toLowerCase().contains(query.toLowerCase());
  }
}
