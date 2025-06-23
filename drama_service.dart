import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drama.dart';

class DramaService {
  static const String _favoriteKey = 'favorite_dramas';
  static const String _watchHistoryKey = 'watch_history';

  // Load drama data dari JSON
  Future<List<Drama>> loadDramas() async {
    try {
      final String response = await rootBundle.loadString('drama.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Drama.fromJson(json)).toList();
    } catch (e) {
      print('Error loading dramas: $e');
      return [];
    }
  }

  // Bookmark/Favorite functions
  Future<void> addToFavorites(String dramaTitle) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoriteKey) ?? [];
    if (!favorites.contains(dramaTitle)) {
      favorites.add(dramaTitle);
      await prefs.setStringList(_favoriteKey, favorites);
    }
  }

  Future<void> removeFromFavorites(String dramaTitle) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoriteKey) ?? [];
    favorites.remove(dramaTitle);
    await prefs.setStringList(_favoriteKey, favorites);
  }

  Future<bool> isFavorite(String dramaTitle) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoriteKey) ?? [];
    return favorites.contains(dramaTitle);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteKey) ?? [];
  }

  // Watch history functions
  Future<void> addToWatchHistory(String dramaTitle, String episodeTitle) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_watchHistoryKey) ?? [];
    String historyItem = '$dramaTitle - $episodeTitle';
    
    // Remove if already exists to put it at the top
    history.remove(historyItem);
    history.insert(0, historyItem);
    
    // Keep only last 50 items
    if (history.length > 50) {
      history = history.take(50).toList();
    }
    
    await prefs.setStringList(_watchHistoryKey, history);
  }

  Future<List<String>> getWatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_watchHistoryKey) ?? [];
  }

  // Filter functions
  List<Drama> filterByGenre(List<Drama> dramas, String genre) {
    if (genre.isEmpty || genre == 'Semua') {
      return dramas;
    }
    return dramas.where((drama) => drama.containsGenre(genre)).toList();
  }

  List<Drama> searchDramas(List<Drama> dramas, String query) {
    if (query.isEmpty) {
      return dramas;
    }
    return dramas.where((drama) => drama.matchesSearch(query)).toList();
  }

  List<String> getAllGenres(List<Drama> dramas) {
    Set<String> allGenres = {'Semua'};
    for (var drama in dramas) {
      allGenres.addAll(drama.genre);
    }
    return allGenres.toList();
  }
}
