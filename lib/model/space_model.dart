class Space {
  final int id;
  final String name;
  final String governorate;
  final String location;
  final String bio;
  final String contactNumber;
  final double rating;
  final DateTime createdAt;
  final List<SpaceImage> images;
  final List<SocialLink> socialLinks;
  final List<SpaceUnit> spaceUnits;

  Space({
    required this.id,
    required this.name,
    required this.governorate,
    required this.location,
    required this.bio,
    required this.contactNumber,
    required this.rating,
    required this.createdAt,
    required this.images,
    required this.socialLinks,
    required this.spaceUnits,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      governorate: json['governorate'] ?? '',
      location: json['location'] ?? '',
      bio: json['bio'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      images: (json['images'] as List<dynamic>?)?.map((img) => SpaceImage.fromJson(img)).toList() ?? [],
      socialLinks: (json['socialLinks'] as List<dynamic>?)?.map((s) => SocialLink.fromJson(s)).toList() ?? [],
      spaceUnits: (json['spaceUnits'] as List<dynamic>?)?.map((u) => SpaceUnit.fromJson(u)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'governorate': governorate,
    'location': location,
    'bio': bio,
    'contactNumber': contactNumber,
    'rating': rating,
    'createdAt': createdAt.toIso8601String(),
    'images': images.map((e) => e.toJson()).toList(),
    'socialLinks': socialLinks.map((e) => e.toJson()).toList(),
    'spaceUnits': spaceUnits.map((e) => e.toJson()).toList(),
  };
}

class SpaceImage {
  final int id;
  final String imageUrl;
  final bool isCover;
  final int spaceId;

  SpaceImage({
    required this.id,
    required this.imageUrl,
    required this.isCover,
    required this.spaceId,
  });

  factory SpaceImage.fromJson(Map<String, dynamic> json) {
    return SpaceImage(
      id: json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      isCover: json['isCover'] ?? false,
      spaceId: json['spaceId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'isCover': isCover,
    'spaceId': spaceId,
  };
}

class SocialLink {
  final int id;
  final String platform;
  final String url;

  SocialLink({
    required this.id,
    required this.platform,
    required this.url,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      id: json['id'] ?? 0,
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'platform': platform,
    'url': url,
  };
}

class SpaceUnit {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int spaceId;
  final int unitCategoryId;
  final dynamic unitCategoryName;
  final List<BookingOption> bookingOptions;

  SpaceUnit({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.spaceId,
    required this.unitCategoryId,
    required this.unitCategoryName,
    required this.bookingOptions,
  });

  factory SpaceUnit.fromJson(Map<String, dynamic> json) {
    return SpaceUnit(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      spaceId: json['spaceId'] ?? 0,
      unitCategoryId: json['unitCategoryId'] ?? 0,
      unitCategoryName: json['unitCategoryName'] ?? '',
      bookingOptions: (json['bookingOptions'] as List<dynamic>?)?.map((b) => BookingOption.fromJson(b)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'spaceId': spaceId,
    'unitCategoryId': unitCategoryId,
    'unitCategoryName': unitCategoryName,
    'bookingOptions': bookingOptions.map((e) => e.toJson()).toList(),
  };
}

class BookingOption {
  final int id;
  final String duration;
  final double price;
  final String currency;
  final int spaceUnitId;

  BookingOption({
    required this.id,
    required this.duration,
    required this.price,
    required this.currency,
    required this.spaceUnitId,
  });

  factory BookingOption.fromJson(Map<String, dynamic> json) {
    return BookingOption(
      id: json['id'] ?? 0,
      duration: json['duration'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      spaceUnitId: json['spaceUnitId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'duration': duration,
    'price': price,
    'currency': currency,
    'spaceUnitId': spaceUnitId,
  };
}