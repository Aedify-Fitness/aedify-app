enum ImportReviewStatus {
  pendingReview,
  resolved,
  saved;

  String get dbValue {
    return switch (this) {
      ImportReviewStatus.pendingReview => 'pending_review',
      _ => name,
    };
  }

  static ImportReviewStatus? fromDb(String? value) {
    if (value == null) return null;
    return ImportReviewStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => ImportReviewStatus.pendingReview,
    );
  }
}
