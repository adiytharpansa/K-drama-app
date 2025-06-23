import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/drama.dart';
import '../services/drama_service.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Drama> allDramas = [];
  List<Drama> favoriteDramas = [];
  List<String> watchHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    
    // Load all dramas
    final dramas = await dramaService.loadDramas();
    
    // Load favorites
    final favoriteList = await dramaService.getFavorites();
    
    // Load watch history
    final history = await dramaService.getWatchHistory();
    
    // Filter favorite dramas
    List<Drama> favorites = [];
    for (String title in favoriteList) {
      try {
        Drama drama = dramas.firstWhere((d) => d.judul == title);
        favorites.add(drama);
      } catch (e) {
        // Drama not found, skip
      }
    }
    
    setState(() {
      allDramas = dramas;
      favoriteDramas = favorites;
      watchHistory = history;
      isLoading = false;
    });
  }

  Future<void> removeFromFavorites(Drama drama) async {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    await dramaService.removeFromFavorites(drama.judul);
    
    setState(() {
      favoriteDramas.removeWhere((d) => d.judul == drama.judul);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drama.judul} dihapus dari favorit'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Batal',
          textColor: Colors.white,
          onPressed: () async {
            await dramaService.addToFavorites(drama.judul);
            setState(() {
              favoriteDramas.add(drama);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Watch history section
                      if (watchHistory.isNotEmpty) ...[
                        _buildSectionTitle('Terakhir Ditonton'),
                        SizedBox(height: 16),
                        _buildWatchHistory(),
                        SizedBox(height: 32),
                      ],
                      
                      // Favorites section
                      _buildSectionTitle('Drama Favorit (${favoriteDramas.length})'),
                      SizedBox(height: 16),
                      _buildFavoritesList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildWatchHistory() {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: watchHistory.take(10).length,
        itemBuilder: (context, index) {
          final historyItem = watchHistory[index];
          final parts = historyItem.split(' - ');
          final dramaTitle = parts.first;
          final episodeTitle = parts.length > 1 ? parts.last : '';
          
          // Find corresponding drama
          Drama? drama;
          try {
            drama = allDramas.firstWhere((d) => d.judul == dramaTitle);
          } catch (e) {
            return SizedBox();
          }
          
          return _buildHistoryItem(drama, episodeTitle);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Drama drama, String episodeTitle) {
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
        width: 120,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drama cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: drama.cover,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: Icon(Icons.movie, color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: Icon(Icons.movie, color: Colors.white),
                    ),
                  ),
                  
                  // Continue watching indicator
                  Positioned(
                    bottom: 4,
                    left: 4,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Lanjutkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            
            // Drama title
            Text(
              drama.judul,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            
            // Episode info
            if (episodeTitle.isNotEmpty)
              Text(
                episodeTitle,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    if (favoriteDramas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.white70,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada drama favorit',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tambahkan drama ke favorit dengan menekan ♥',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: favoriteDramas.length,
      itemBuilder: (context, index) {
        final drama = favoriteDramas[index];
        return _buildFavoriteCard(drama);
      },
    );
  }

  Widget _buildFavoriteCard(Drama drama) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(drama: drama),
          ),
        );
      },
      onLongPress: () {
        _showRemoveDialog(drama);
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
              
              // Favorite indicator
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
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
                    Text(
                      drama.genre.isNotEmpty ? drama.genre.first : 'Drama',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Remove button (visible on long press)
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: () => _showRemoveDialog(drama),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
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

  void _showRemoveDialog(Drama drama) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          title: Text(
            'Hapus dari Favorit',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Hapus "${drama.judul}" dari daftar favorit?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                removeFromFavorites(drama);
              },
              child: Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
