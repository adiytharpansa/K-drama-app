import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/drama.dart';
import '../services/drama_service.dart';
import 'video_player_screen.dart';

class DetailScreen extends StatefulWidget {
  final Drama drama;

  const DetailScreen({Key? key, required this.drama}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  Future<void> checkFavoriteStatus() async {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    final favorite = await dramaService.isFavorite(widget.drama.judul);
    
    setState(() {
      isFavorite = favorite;
    });
  }

  Future<void> toggleFavorite() async {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    
    if (isFavorite) {
      await dramaService.removeFromFavorites(widget.drama.judul);
    } else {
      await dramaService.addToFavorites(widget.drama.judul);
    }
    
    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite 
              ? 'Ditambahkan ke favorit' 
              : 'Dihapus dari favorit',
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar dengan cover image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Cover image
                  CachedNetworkImage(
                    imageUrl: widget.drama.cover,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    ),
                  ),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: toggleFavorite,
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul dan info
                  _buildHeaderInfo(),
                  SizedBox(height: 24),
                  
                  // Sinopsis
                  _buildSynopsis(),
                  SizedBox(height: 24),
                  
                  // Episode list
                  _buildEpisodeList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul
        Text(
          widget.drama.judul,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12),
        
        // Genre chips
        if (widget.drama.genre.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.drama.genre.map((genre) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Text(
                  genre,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        SizedBox(height: 16),
        
        // Stats
        Row(
          children: [
            _buildStatItem(Icons.play_circle_outline, '${widget.drama.episode.length} Episode'),
            SizedBox(width: 20),
            _buildStatItem(Icons.star, '9.2'),
            SizedBox(width: 20),
            _buildStatItem(Icons.calendar_today, '2024'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSynopsis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sinopsis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          widget.drama.sinopsis.isNotEmpty 
              ? widget.drama.sinopsis 
              : 'Tidak ada sinopsis tersedia.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Episode (${widget.drama.episode.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (widget.drama.episode.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  // Play first episode
                  _playEpisode(widget.drama.episode.first);
                },
                icon: Icon(Icons.play_arrow, color: Colors.red),
                label: Text(
                  'Mulai Nonton',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        
        if (widget.drama.episode.isEmpty)
          Center(
            child: Text(
              'Tidak ada episode tersedia',
              style: TextStyle(color: Colors.white70),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.drama.episode.length,
            itemBuilder: (context, index) {
              final episode = widget.drama.episode[index];
              return _buildEpisodeCard(episode, index + 1);
            },
          ),
      ],
    );
  }

  Widget _buildEpisodeCard(Episode episode, int episodeNumber) {
    return Card(
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.play_arrow,
            color: Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          episode.judul,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Episode $episodeNumber • 60 menit',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.download, color: Colors.white70),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fitur download belum tersedia'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        ),
        onTap: () => _playEpisode(episode),
      ),
    );
  }

  void _playEpisode(Episode episode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: episode.videoUrl,
          title: '${widget.drama.judul} - ${episode.judul}',
        ),
      ),
    );
    
    // Add to watch history
    final dramaService = Provider.of<DramaService>(context, listen: false);
    dramaService.addToWatchHistory(widget.drama.judul, episode.judul);
  }
}
