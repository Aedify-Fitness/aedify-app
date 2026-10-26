class SupersetGroupSummary {
  const SupersetGroupSummary({
    required this.groupId,
    required this.memberIds,
    required this.memberCount,
  });

  final String groupId;
  final List<String> memberIds;
  final int memberCount;
}
