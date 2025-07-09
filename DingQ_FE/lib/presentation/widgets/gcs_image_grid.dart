import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/gcs_image.dart';
import '../providers/gcs_image_provider.dart';
import '../../utils/download_utils.dart';

class GcsImageGrid extends ConsumerWidget {
  final GcsImageQueryParams params;
  const GcsImageGrid({super.key, this.params = const GcsImageQueryParams()});

  void _downloadImage(GcsImage image) {
    DownloadUtils.downloadPngFromUrl(image.url, image.filename);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(gcsImageListProvider(params));
    return imagesAsync.when(
      data: (images) {
        // 딩벳 찾기 grid와 유사한 크기/레이아웃 적용
        return LayoutBuilder(
          builder: (context, constraints) {
            const double iconSize = 80.0;
            const double spacing = 10.0;
            const double padding = 16.0;
            final isWideScreen = constraints.maxWidth > 800;
            final availableWidth = constraints.maxWidth - (padding * 2);
            final crossAxisCount = (availableWidth / (iconSize + spacing)).floor();
            final adjustedCrossAxisCount = crossAxisCount.clamp(3, 12);
            return GridView.builder(
              padding: EdgeInsets.fromLTRB(
                padding,
                8,
                isWideScreen ? 8 : padding,
                padding,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: adjustedCrossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, idx) {
                final img = images[idx];
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => GcsImageDetailModal(image: img),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            img.url,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Center(child: Text("불러오기 실패")),
                          ),
                        ),
                        // Download button (floating)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              onPressed: () => _downloadImage(img),
                              icon: const Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 20,
                              ),
                              style: IconButton.styleFrom(
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(32, 32),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('이미지 불러오기 실패: $e')),
    );
  }
}

class GcsImageDetailModal extends StatelessWidget {
  final GcsImage image;
  const GcsImageDetailModal({super.key, required this.image});

  void _downloadImage(GcsImage image) {
    DownloadUtils.downloadPngFromUrl(image.url, image.filename);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        image.url,
                        width: 240,
                        height: 240,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Text("불러오기 실패")),
                      ),
                    ),
                    // Download button (floating)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () => _downloadImage(image),
                          icon: const Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('파일명: ${image.filename}', style: TextStyle(fontFamily: 'LGEIHeadline')),
              Text('크기: ${image.size} bytes', style: TextStyle(fontFamily: 'LGEIHeadline')),
              Text('생성일: ${image.created}', style: TextStyle(fontFamily: 'LGEIHeadline')),
              Text('수정일: ${image.updated}', style: TextStyle(fontFamily: 'LGEIHeadline')),
              const SizedBox(height: 8),
              SelectableText('URL: ${image.url}', style: TextStyle(fontFamily: 'LGEIHeadline', fontSize: 12, color: Colors.blue)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 