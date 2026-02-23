import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/twizz_model.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/media_utils.dart';
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

class TwizzCard extends StatelessWidget {
  final Twizz twizz;
  final VoidCallback onDelete;
  final bool showDelete;
  final bool isEmbedded;

  const TwizzCard({
    super.key,
    required this.twizz,
    required this.onDelete,
    this.showDelete = true,
    this.isEmbedded = false,
  });

  Color get _typeColor {
    switch (twizz.type) {
      case 0:
        return AppTheme.primaryColor;
      case 1:
        return AppTheme.successColor;
      case 2:
        return AppTheme.warningColor;
      case 3:
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          isEmbedded
              ? BoxDecoration(
                border: Border.all(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.cardColor.withValues(alpha: 0.5),
              )
              : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          CircleAvatar(
            radius: isEmbedded ? 16 : 24,
            backgroundColor: AppTheme.primaryColor.withValues(
              alpha: 0.1,
            ),
            backgroundImage:
                twizz.user?.avatar != null &&
                        twizz.user!.avatar!.isNotEmpty
                    ? NetworkImage(
                      MediaUtils.getMediaUrl(
                        twizz.user!.avatar!,
                      ),
                    )
                    : null,
            child:
                twizz.user?.avatar == null ||
                        twizz.user!.avatar!.isEmpty
                    ? Text(
                      twizz.user?.name.isNotEmpty == true
                          ? twizz.user!.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isEmbedded ? 14 : 16,
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
                    if (!isEmbedded)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _typeColor.withValues(
                            alpha: 0.1,
                          ),
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
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                            child: Image.network(
                              MediaUtils.getMediaUrl(media.url),
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardColor,
                                      borderRadius:
                                          BorderRadius.circular(
                                            8,
                                          ),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .broken_image_outlined,
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
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8),
                              child: _WebVideoPlayer(
                                url: MediaUtils.getMediaUrl(
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

                // Parent Twizz (if exists) - Only for Quotes (2) and Comments (1)
                if (twizz.parentTwizz != null &&
                    twizz.type != 0) ...[
                  const SizedBox(height: 12),
                  if (twizz.type == 1) // Comment
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Đang bình luận:',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  TwizzCard(
                    twizz: twizz.parentTwizz!,
                    onDelete:
                        () {}, // No delete callback for embedded
                    showDelete: false,
                    isEmbedded: true,
                  ),
                ],

                const SizedBox(height: 12),

                // Stats & Actions
                if (!isEmbedded)
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
      ),
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
