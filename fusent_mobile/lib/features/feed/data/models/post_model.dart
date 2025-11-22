import 'package:equatable/equatable.dart';

enum PostType {
  SHOWCASE, // Product showcase
  STORY,    // Regular story/post
  AD,       // Advertisement
  REVIEW    // Product review
}

enum PostVisibility {
  PUBLIC,
  FOLLOWERS_ONLY,
  PRIVATE
}

enum PostStatus {
  ACTIVE,
  HIDDEN,
  DELETED,
  FLAGGED
}

enum OwnerType {
  USER,
  MERCHANT
}

enum MediaType {
  IMAGE,
  VIDEO,
  AUDIO
}

class PostMediaModel extends Equatable {
  final String id;
  final MediaType mediaType;
  final String url;
  final String? thumbUrl;
  final int? sortOrder;
  final int? durationSeconds;
  final int? width;
  final int? height;

  const PostMediaModel({
    required this.id,
    required this.mediaType,
    required this.url,
    this.thumbUrl,
    this.sortOrder,
    this.durationSeconds,
    this.width,
    this.height,
  });

  factory PostMediaModel.fromJson(Map<String, dynamic> json) {
    return PostMediaModel(
      id: json['id'] as String,
      mediaType: MediaType.values.firstWhere(
        (e) => e.name == json['mediaType'],
        orElse: () => MediaType.IMAGE,
      ),
      url: json['url'] as String,
      thumbUrl: json['thumbUrl'] as String?,
      sortOrder: json['sortOrder'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaType': mediaType.name,
      'url': url,
      if (thumbUrl != null) 'thumbUrl': thumbUrl,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    };
  }

  @override
  List<Object?> get props => [
        id,
        mediaType,
        url,
        thumbUrl,
        sortOrder,
        durationSeconds,
        width,
        height,
      ];
}

class PostModel extends Equatable {
  final String id;
  final OwnerType ownerType;
  final String? ownerId;
  final String ownerName;
  final String? text;
  final PostType postType;
  final String? linkedProductId; // ID привязанного товара
  final double? geoLat;
  final double? geoLon;
  final PostVisibility visibility;
  final PostStatus status;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final double trendingScore;
  final List<PostMediaModel> media;
  final List<String> tags;
  final bool isLikedByCurrentUser;
  final bool isSavedByCurrentUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel({
    required this.id,
    required this.ownerType,
    this.ownerId,
    required this.ownerName,
    this.text,
    required this.postType,
    this.linkedProductId,
    this.geoLat,
    this.geoLon,
    required this.visibility,
    required this.status,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    required this.trendingScore,
    required this.media,
    required this.tags,
    required this.isLikedByCurrentUser,
    required this.isSavedByCurrentUser,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter for productId (alias for linkedProductId)
  String? get productId => linkedProductId;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      ownerType: OwnerType.values.firstWhere(
        (e) => e.name == json['ownerType'],
        orElse: () => OwnerType.USER,
      ),
      ownerId: json['ownerId'] as String?,
      ownerName: (json['ownerName'] as String?) ?? '',
      text: json['text'] as String?,
      postType: PostType.values.firstWhere(
        (e) => e.name == json['postType'],
        orElse: () => PostType.STORY,
      ),
      linkedProductId: json['linkedProductId'] as String?,
      geoLat: json['geoLat'] != null
          ? double.parse(json['geoLat'].toString())
          : null,
      geoLon: json['geoLon'] != null
          ? double.parse(json['geoLon'].toString())
          : null,
      visibility: PostVisibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => PostVisibility.PUBLIC,
      ),
      status: PostStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PostStatus.ACTIVE,
      ),
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      sharesCount: json['sharesCount'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? 0,
      trendingScore: (json['trendingScore'] as num?)?.toDouble() ?? 0.0,
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => PostMediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool? ?? false,
      isSavedByCurrentUser: json['isSavedByCurrentUser'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerType': ownerType.name,
      'ownerId': ownerId,
      'ownerName': ownerName,
      if (text != null) 'text': text,
      'postType': postType.name,
      if (linkedProductId != null) 'linkedProductId': linkedProductId,
      if (geoLat != null) 'geoLat': geoLat,
      if (geoLon != null) 'geoLon': geoLon,
      'visibility': visibility.name,
      'status': status.name,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewsCount': viewsCount,
      'trendingScore': trendingScore,
      'media': media.map((e) => e.toJson()).toList(),
      'tags': tags,
      'isLikedByCurrentUser': isLikedByCurrentUser,
      'isSavedByCurrentUser': isSavedByCurrentUser,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PostModel copyWith({
    String? id,
    OwnerType? ownerType,
    String? ownerId,
    String? ownerName,
    String? text,
    PostType? postType,
    String? linkedProductId,
    double? geoLat,
    double? geoLon,
    PostVisibility? visibility,
    PostStatus? status,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    double? trendingScore,
    List<PostMediaModel>? media,
    List<String>? tags,
    bool? isLikedByCurrentUser,
    bool? isSavedByCurrentUser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      text: text ?? this.text,
      postType: postType ?? this.postType,
      linkedProductId: linkedProductId ?? this.linkedProductId,
      geoLat: geoLat ?? this.geoLat,
      geoLon: geoLon ?? this.geoLon,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      trendingScore: trendingScore ?? this.trendingScore,
      media: media ?? this.media,
      tags: tags ?? this.tags,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isSavedByCurrentUser: isSavedByCurrentUser ?? this.isSavedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerType,
        ownerId,
        ownerName,
        text,
        postType,
        linkedProductId,
        geoLat,
        geoLon,
        visibility,
        status,
        likesCount,
        commentsCount,
        sharesCount,
        viewsCount,
        trendingScore,
        media,
        tags,
        isLikedByCurrentUser,
        isSavedByCurrentUser,
        createdAt,
        updatedAt,
      ];
}
