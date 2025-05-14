import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/data/model/count.dart';

void main() {
  test('Firestoreのデータ構造へ変換した際、過不足なくキーバリューが含まれること', () {
    final now = DateTime.now();
    const id = 'test-id';
    const countValue = 15;
    final count = Count(id: id, value: countValue, updatedAt: now);

    final result = count.toFirestore();

    expect(result.containsKey('id'), isFalse);
    expect(result['count'], equals(countValue));
    expect(result['createdAt'], equals(now));
  });
}
