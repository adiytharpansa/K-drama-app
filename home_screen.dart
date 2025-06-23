import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/drama.dart';
import '../services/drama_service.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Drama> dramas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDramas();
  }

  Future<void> loadDramas() async {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    final loadedDramas = await dramaService.loadDramas();
    
    setState(() {
      dramas = loadedDramas;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'K-drama',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(dramas: dramas),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadDramas,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner section
                      _buildBannerSection(),
                      SizedBox(height: 24),
                      
                      // Popular section
                      _buildSectionTitle('Drama Populer'),
                      SizedBox(height: 16),
                      _buildDramaGrid(dramas.take(4).toList(), isPopular: true),
                      SizedBox(height: 24),
                      
                      // All dramas section
                      _buildSectionTitle('Semua Drama'),
                      SizedBox(height: 16),
                      _buildDramaGrid(dramas),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBannerSection() {
    if (dramas.isEmpty) return SizedBox();
    
    final featuredDrama = dramas.first;
    
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: featuredDrama.cover,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[800],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: Icon(Icons.error, color: Colors.white),
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
            
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    featuredDrama.judul,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    featuredDrama.genre.join(' • '),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Tap to open
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(drama: featuredDrama),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (title == 'Drama Populer')
          TextButton(
            onPressed: () {
              // Implementasi lihat semua
            },
            child: Text(
              'Lihat Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildDramaGrid(List<Drama> dramaList, {bool isPopular = false}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: dramaList.length,
      itemBuilder: (context, index) {
        final drama = dramaList[index];
        return _buildDramaCard(drama, isPopular: isPopular);
      },
    );
  }

  Widget _buildDramaCard(Drama drama, {bool isPopular = false}) {
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
              
              // Status badge
              if (isPopular)
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
                      'POPULER',
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
            ],
          ),
        ),
      ),
    );
  }
}
