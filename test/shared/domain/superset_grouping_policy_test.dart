import 'package:aedify/shared/domain/superset_grouping_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupersetGroupingPolicy', () {
    final policy = const SupersetGroupingPolicy();

    test('canCreateGroup returns true for 2+ selections', () {
      expect(policy.canCreateGroup(0), isFalse);
      expect(policy.canCreateGroup(1), isFalse);
      expect(policy.canCreateGroup(2), isTrue);
      expect(policy.canCreateGroup(3), isTrue);
      expect(policy.canCreateGroup(5), isTrue);
    });

    test('belongsToGroup returns true when supersetGroupId is not null', () {
      expect(policy.belongsToGroup('group-1'), isTrue);
      expect(policy.belongsToGroup(null), isFalse);
      expect(policy.belongsToGroup(''), isTrue);
    });

    test('isValidGroupMemberCount returns true for 2+ members', () {
      expect(policy.isValidGroupMemberCount(0), isFalse);
      expect(policy.isValidGroupMemberCount(1), isFalse);
      expect(policy.isValidGroupMemberCount(2), isTrue);
      expect(policy.isValidGroupMemberCount(10), isTrue);
    });

    test('canReorderWithinGroup returns true for 2+ members', () {
      expect(policy.canReorderWithinGroup(0), isFalse);
      expect(policy.canReorderWithinGroup(1), isFalse);
      expect(policy.canReorderWithinGroup(2), isTrue);
      expect(policy.canReorderWithinGroup(3), isTrue);
    });
  });
}
