import 'package:flutter/material.dart';

class ImageScaleScreen extends StatefulWidget {
  final String imageUrl;

  const ImageScaleScreen({
    super.key,
    this.imageUrl = 'https://picsum.photos/id/10/1200/800',
  });

  @override
  State<ImageScaleScreen> createState() => _ImageScaleScreenState();
}

class _ImageScaleScreenState extends State<ImageScaleScreen> {
  final TransformationController _transformationController =
      TransformationController();
  // Bumped by Retry: a new key makes Image.network request the URL again
  // (NetworkImage drops failed loads from the image cache).
  int _loadAttempt = 0;

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16, right: 4),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              const Icon(Icons.pinch, color: Colors.blue, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Use a pinch gesture with two fingers to zoom in or out. Drag to pan.',
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt),
                tooltip: 'Reset Zoom',
                onPressed: _resetZoom,
              ),
            ],
          ),
        ),
        Expanded(
          child: ClipRect(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 5.0,
              panEnabled: true,
              scaleEnabled: true,
              boundaryMargin: const EdgeInsets.all(40),
              child: Center(
                child: Image.network(
                  widget.imageUrl,
                  key: ValueKey(_loadAttempt),
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    final total = loadingProgress.expectedTotalBytes;
                    final loaded = loadingProgress.cumulativeBytesLoaded;
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            value: total != null ? loaded / total : null,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Loading image from internet...',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Failed to load image from internet.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.imageUrl,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() => _loadAttempt++);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
