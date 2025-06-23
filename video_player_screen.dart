import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.title,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Check if URL is valid
      if (widget.videoUrl.isEmpty || 
          (!widget.videoUrl.startsWith('http') && !widget.videoUrl.startsWith('https'))) {
        throw Exception('URL video tidak valid');
      }

      // Initialize video player controller
      if (widget.videoUrl.contains('.m3u8')) {
        // HLS stream
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          httpHeaders: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        );
      } else {
        // Regular video file
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      }

      await _videoPlayerController.initialize();

      // Initialize Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        ),
        autoInitialize: true,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isLoading || _hasError 
          ? AppBar(
              backgroundColor: Colors.black,
              title: Text(
                widget.title,
                style: TextStyle(color: Colors.white),
              ),
              iconTheme: IconThemeData(color: Colors.white),
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_hasError) {
      return _buildErrorView();
    }

    if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      return _buildVideoPlayer();
    }

    return _buildLoadingView();
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat video...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Gagal memuat video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage.contains('URL video tidak valid')
                  ? 'URL video tidak valid atau tidak dapat diakses'
                  : 'Terjadi kesalahan saat memuat video. Periksa koneksi internet Anda.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _initializePlayer();
              },
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Kembali',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
        ),
        
        // Custom back button overlay (only visible when controls are shown)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        
        // Title overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 60,
          right: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
