import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';

class BureauLocalDataSource {
  final List<BureauEntity> _bureaus = [
    BureauEntity(
      name: "Bureau 1",
      description: "Description of Bureau 1",
      bureauId: "Bureau1",
    ),
    BureauEntity(
      name: "Bureau 2",
      description: "Description of Bureau 2",
      bureauId: "Bureau2",
    ),
  ];

  List<BureauEntity> getBureaus() => List.from(_bureaus);

  void addBureau(BureauEntity bureau) => _bureaus.add(bureau);

  void updateBureau(BureauEntity bureau) {
    final index = _bureaus.indexWhere((b) => b.bureauId == bureau.bureauId);
    if (index != -1) _bureaus[index] = bureau;
  }

  void deleteBureau(String bureauId) {
    _bureaus.removeWhere((b) => b.bureauId == bureauId);
  }
}
