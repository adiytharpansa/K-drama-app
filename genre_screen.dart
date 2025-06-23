import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/drama.dart';
import '../services/drama_service.dart';
import 'detail_screen.dart';

class GenreScreen extends StatefulWidget {
  @override
  _GenreScreenState createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  List<Drama> dramas = [];
  List<Drama> filteredDramas = [];
  List<String> genres = [];
  String selectedGenre = 'Semua';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDramas();
  }

  Future<void> loadDramas() async {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    final loadedDramas = await dramaService.loadDramas();
    final allGenres = dramaService.getAllGenres(loadedDramas);
    
    setState(() {
      dramas = loadedDramas;
      filteredDramas = loadedDramas;
      genres = allGenres;
      isLoading = false;
    });
  }

  void filterByGenre(String genre) {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    
    setState(() {
      selectedGenre = genre;
      filteredDramas = dramaService.filterByGenre(dramas, genre);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Genre',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Genre filter chips
                _buildGenreFilter(),
                
                // Drama grid
                Expanded(
                  child: _buildDramaGrid(),
                ),
              ],
            ),
    );
  }

  Widget _buildGenreFilter() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selectedGenre;
          
          return GestureDetector(
            onTap: () => filterByGenre(genre),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  genre,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDramaGrid() {
    if (filteredDramas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_filter,
              size: 64,
              color: Colors.white70,
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada drama untuk genre ini',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coba pilih genre lain',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedGenre == 'Semua' 
                      ? 'Semua Drama (${filteredDramas.length})'
                      : '$selectedGenre (${filteredDramas.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (selectedGenre != 'Semua')
                  TextButton(
                    onPressed: () => filterByGenre('Semua'),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            
            // Drama grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredDramas.length,
              itemBuilder: (context, index) {
                final drama = filteredDramas[index];
                return _buildDramaCard(drama);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDramaCard(Drama drama) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(drama: drama),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Drama poster
              CachedNetworkImage(
                imageUrl: drama.cover,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.movie, color: Colors.white, size: 40),
                      SizedBox(height: 8),
                      Text(
                        drama.judul,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Genre badge (showing primary genre)
              if (drama.genre.isNotEmpty && selectedGenre == 'Semua')
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      drama.genre.first,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              // Gradient overlay di bagian bawah
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Drama info
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drama.judul,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    
                    // Genre tags
                    if (drama.genre.isNotEmpty)
                      Text(
                        drama.genre.take(2).join(' • '),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 4),
                    
                    // Episode count
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: Colors.white70,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${drama.episode.length} Episode',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Play button overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
