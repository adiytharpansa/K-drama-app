import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/drama.dart';
import '../services/drama_service.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<Drama> dramas;

  const SearchScreen({Key? key, required this.dramas}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Drama> filteredDramas = [];
  List<Drama> recentlyWatched = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredDramas = widget.dramas;
    loadRecentlyWatched();
  }

  Future<void> loadRecentlyWatched() async {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    final history = await dramaService.getWatchHistory();
    
    // Extract drama titles from history
    Set<String> watchedTitles = {};
    for (String historyItem in history.take(5)) {
      String dramaTitle = historyItem.split(' - ').first;
      watchedTitles.add(dramaTitle);
    }
    
    // Find corresponding drama objects
    List<Drama> watched = [];
    for (String title in watchedTitles) {
      Drama? drama = widget.dramas.firstWhere(
        (d) => d.judul == title,
        orElse: () => widget.dramas.first, // fallback
      );
      if (drama.judul == title) {
        watched.add(drama);
      }
    }
    
    setState(() {
      recentlyWatched = watched;
    });
  }

  void performSearch(String query) {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredDramas = widget.dramas;
      } else {
        filteredDramas = dramaService.searchDramas(widget.dramas, query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Cari drama...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      searchController.clear();
                      performSearch('');
                    },
                  )
                : Icon(Icons.search, color: Colors.white70),
          ),
          onChanged: performSearch,
        ),
      ),
      body: Column(
        children: [
          // Search suggestions or recent
          if (!isSearching && recentlyWatched.isNotEmpty)
            _buildRecentSection(),
          
          // Search results
          Expanded(
            child: isSearching
                ? _buildSearchResults()
                : _buildBrowseSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terakhir Ditonton',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentlyWatched.length,
              itemBuilder: (context, index) {
                final drama = recentlyWatched[index];
                return _buildRecentItem(drama);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(Drama drama) {
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
        width: 80,
        margin: EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: drama.cover,
                width: 80,
                height: 80,
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
            ),
            SizedBox(height: 8),
            Text(
              drama.judul,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (filteredDramas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white70,
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada hasil ditemukan',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coba kata kunci lain',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredDramas.length,
      itemBuilder: (context, index) {
        final drama = filteredDramas[index];
        return _buildSearchResultItem(drama);
      },
    );
  }

  Widget _buildSearchResultItem(Drama drama) {
    return Card(
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: drama.cover,
            width: 60,
            height: 80,
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
        ),
        title: Text(
          drama.judul,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              drama.genre.join(' • '),
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              drama.sinopsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Icon(
          Icons.play_circle_fill,
          color: Colors.red,
          size: 32,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(drama: drama),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrowseSection() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Popular searches
        _buildSectionTitle('Pencarian Populer'),
        SizedBox(height: 12),
        _buildPopularSearches(),
        SizedBox(height: 24),
        
        // All dramas
        _buildSectionTitle('Semua Drama'),
        SizedBox(height: 12),
        _buildAllDramas(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPopularSearches() {
    List<String> popularSearches = [
      'Goblin', 'True Beauty', 'Romance', 'School', 'Fantasy'
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: popularSearches.map((search) {
        return GestureDetector(
          onTap: () {
            searchController.text = search;
            performSearch(search);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              search,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllDramas() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.dramas.length,
      itemBuilder: (context, index) {
        final drama = widget.dramas[index];
        return _buildGridItem(drama);
      },
    );
  }

  Widget _buildGridItem(Drama drama) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(drama: drama),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: drama.cover,
              width: double.infinity,
              height: double.infinity,
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8),
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
                child: Text(
                  drama.judul,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
