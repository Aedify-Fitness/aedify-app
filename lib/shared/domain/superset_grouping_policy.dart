class SupersetGroupingPolicy {
  const SupersetGroupingPolicy();

  bool canCreateGroup(int selectedCount) => selectedCount >= 2;

  bool belongsToGroup(String? supersetGroupId) => supersetGroupId != null;

  bool isValidGroupMemberCount(int memberCount) => memberCount >= 2;

  bool canReorderWithinGroup(int memberCount) => memberCount >= 2;
}
