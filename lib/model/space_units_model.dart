class BookingOption {
  final int id;
  final String duration;
  final num price;
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
      id: json['id'],
      duration: json['duration'],
      price: json['price'],
      currency: json['currency'],
      spaceUnitId: json['spaceUnitId'],
    );
  }
}

class SpaceUnit {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final int spaceId;
  final int unitCategoryId;
  final String unitCategoryName;
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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      spaceId: json['spaceId'],
      unitCategoryId: json['unitCategoryId'],
      unitCategoryName: json['unitCategoryName'],
      bookingOptions: (json['bookingOptions'] as List)
          .map((e) => BookingOption.fromJson(e))
          .toList(),
    );
  }
}
