import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_worker/data/model/app_session.dart';
import 'package:house_worker/data/model/count.dart';
import 'package:house_worker/data/model/no_counter_id_error.dart';
import 'package:house_worker/ui/root_presenter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_service.g.dart';

@riverpod
DatabaseService databaseService(Ref ref) {
  final appSession = ref.watch(unwrappedCurrentAppSessionProvider);

  switch (appSession) {
    case AppSessionSignedIn(counterId: final counterId):
      return DatabaseService(counterId: counterId);
    case AppSessionNotSignedIn():
      throw NoCounterIdError();
  }
}

class DatabaseService {
  DatabaseService({required String counterId}) : _counterId = counterId;

  final String _counterId;

  Stream<Count> getAll() {
    return _getAllCollectionReference().snapshots().map(
      (snapshot) => snapshot.docs.map(Count.fromFirestore).first,
    );
  }

  Future<void> save(Count count) async {
    final houseWorksCollection = _getAllCollectionReference();

    await houseWorksCollection.doc(_counterId).update(count.toFirestore());
  }

  CollectionReference _getAllCollectionReference() {
    return FirebaseFirestore.instance
        .collection('houses')
        // TODO(ide): 開発中の仮の値
        .doc('default-house-id')
        .collection('houseWorks');
  }
}
