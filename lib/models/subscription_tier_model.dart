class SubscriptionTier {
  final int id;
  final String tierName;
  final String monthlyPrice;
  final String annualPrice;
  final String contentType;
  final bool isActive;

  SubscriptionTier({
    required this.id,
    required this.tierName,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.contentType,
    required this.isActive,
  });

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      id: json['id'],
      tierName: json['tier_name'],
      monthlyPrice: json['monthly_price'],
      annualPrice: json['annual_price'],
      contentType: json['content_type'],
      isActive: json['is_active'],
    );
  }
}
