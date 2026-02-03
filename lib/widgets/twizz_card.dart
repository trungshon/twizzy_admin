import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/twizz_model.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

class TwizzCard extends StatelessWidget {
  final Twizz twizz;
  final VoidCallback onDelete;
  final bool showDelete;

  const TwizzCard({
    super.key,
    required this.twizz,
    required this.onDelete,
    this.showDelete = true,
  });

  Color get _typeColor {
    switch (twizz.type) {
      case 0:
        return AppTheme.primaryColor;
      case 1:
        return AppTheme.successColor;
      case 2:
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getMediaUrl(String? url, {bool isVideo = false}) {
    if (url == null || url.isEmpty) return '';
    String finalUrl = url;
    // Replace emulator IP with localhost for web
    if (finalUrl.contains('10.0.2.2')) {
      finalUrl = finalUrl.replaceAll('10.0.2.2', 'localhost');
    }
    if (finalUrl.startsWith('http')) return finalUrl;
    if (finalUrl.startsWith('/')) {
      return '${AppConstants.baseUrl}$finalUrl';
    }
    final String path = isVideo ? 'video-stream' : 'image';
    return '${AppConstants.baseUrl}/static/$path/$finalUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryColor.withValues(
            alpha: 0.1,
          ),
          backgroundImage:
              twizz.user?.avatar != null &&
                      twizz.user!.avatar!.isNotEmpty
                  ? NetworkImage(
                    _getMediaUrl(twizz.user!.avatar!),
                  )
                  : null,
          child:
              twizz.user?.avatar == null ||
                      twizz.user!.avatar!.isEmpty
                  ? Text(
                    twizz.user?.name.isNotEmpty == true
                        ? twizz.user!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : null,
        ),
        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info & Type
              Row(
                children: [
                  if (twizz.user != null) ...[
                    Text(
                      twizz.user!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@${twizz.user!.username}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      twizz.typeText,
                      style: TextStyle(
                        color: _typeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content
              Text(
                twizz.content,
                maxLines: 10, // Increased for reports
                overflow: TextOverflow.ellipsis,
              ),

              // Media (Images/Videos)
              if (twizz.medias.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: twizz.medias.length,
                    separatorBuilder:
                        (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final media = twizz.medias[index];
                      // type 0 = image, type 1 = video
                      if (media.type == 0) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _getMediaUrl(media.url),
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    color:
                                        AppTheme.textSecondary,
                                  ),
                                ),
                          ),
                        );
                      } else {
                        // Web Video Player
                        return Container(
                          height: 150,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                            child: _WebVideoPlayer(
                              url: _getMediaUrl(
                                media.url,
                                isVideo: true,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Stats & Actions
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat(
                      'MMM d, yyyy • HH:mm',
                    ).format(twizz.createdAt.toLocal()),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (showDelete)
                    TextButton.icon(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppTheme.errorColor,
                      ),
                      label: const Text(
                        'Xóa',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                        ),
                      ),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WebVideoPlayer extends StatelessWidget {
  final String url;
  const _WebVideoPlayer({required this.url});

  @override
  Widget build(BuildContext context) {
    // Unique view type for each video to prevent recycling issues
    final String viewType = 'video-${url.hashCode}';

    try {
      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) =>
            (web.document.createElement('video')
                  as web.HTMLVideoElement)
              ..src = url
              ..controls = true
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%'
              ..style.backgroundColor = 'black',
      );
    } catch (e) {
      // Factory might already be registered
    }

    return HtmlElementView(viewType: viewType);
  }
}
