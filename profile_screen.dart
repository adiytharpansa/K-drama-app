import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/drama_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int totalDramas = 0;
  int totalFavorites = 0;
  int totalWatched = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    
    final dramas = await dramaService.loadDramas();
    final favorites = await dramaService.getFavorites();
    final history = await dramaService.getWatchHistory();
    
    setState(() {
      totalDramas = dramas.length;
      totalFavorites = favorites.length;
      totalWatched = history.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile header
              _buildProfileHeader(),
              SizedBox(height: 24),
              
              // Stats cards
              _buildStatsSection(),
              SizedBox(height: 24),
              
              // Menu items
              _buildMenuSection(),
              SizedBox(height: 24),
              
              // App info
              _buildAppInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          
          // User name
          Text(
            'K-drama User',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          
          Text(
            'Drama Korea Enthusiast',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Drama',
            totalDramas.toString(),
            Icons.movie,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Favorit',
            totalFavorites.toString(),
            Icons.favorite,
            Colors.red,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Ditonton',
            totalWatched.toString(),
            Icons.play_circle,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.history,
          title: 'Riwayat Tontonan',
          subtitle: 'Lihat semua drama yang pernah ditonton',
          onTap: () {
            _showWatchHistory();
          },
        ),
        _buildMenuItem(
          icon: Icons.download,
          title: 'Download',
          subtitle: 'Kelola drama yang didownload',
          onTap: () {
            _showComingSoon('Download');
          },
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Pengaturan',
          subtitle: 'Atur preferensi aplikasi',
          onTap: () {
            _showSettings();
          },
        ),
        _buildMenuItem(
          icon: Icons.help,
          title: 'Bantuan',
          subtitle: 'FAQ dan dukungan',
          onTap: () {
            _showHelp();
          },
        ),
        _buildMenuItem(
          icon: Icons.info,
          title: 'Tentang Aplikasi',
          subtitle: 'Informasi versi dan developer',
          onTap: () {
            _showAbout();
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'K-drama App',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Versi 1.0.0',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Aplikasi streaming drama Korea terbaik\ndengan koleksi drama populer',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showWatchHistory() async {
    final dramaService = Provider.of<DramaService>(context, listen: false);
    final history = await dramaService.getWatchHistory();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(
          'Riwayat Tontonan',
          style: TextStyle(color: Colors.white),
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: history.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada riwayat tontonan',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.play_circle, color: Colors.red),
                      title: Text(
                        history[index],
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.dark_mode, color: Colors.white70),
              title: Text(
                'Mode Gelap',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: Colors.red,
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.white70),
              title: Text(
                'Notifikasi',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: Colors.red,
              ),
            ),
            ListTile(
              leading: Icon(Icons.hd, color: Colors.white70),
              title: Text(
                'Kualitas Video HD',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(
          'Bantuan',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem('🎬', 'Cara menonton drama', 'Tap drama > Pilih episode > Mulai nonton'),
              _buildHelpItem('❤️', 'Cara tambah favorit', 'Tap ikon hati di halaman detail drama'),
              _buildHelpItem('🔍', 'Cara mencari drama', 'Gunakan ikon search di home atau menu pencarian'),
              _buildHelpItem('📂', 'Cara filter genre', 'Buka tab Genre > Pilih kategori yang diinginkan'),
              _buildHelpItem('📱', 'Masalah video', 'Pastikan koneksi internet stabil dan coba refresh'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String emoji, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
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
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'K-drama',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.play_circle_fill,
          size: 30,
          color: Colors.white,
        ),
      ),
      children: [
        Text(
          'Aplikasi streaming drama Korea terbaik dengan koleksi drama populer dan fitur lengkap.',
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 16),
        Text(
          'Dibuat dengan ❤️ oleh MiniMax Agent',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur $feature akan segera hadir!'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
