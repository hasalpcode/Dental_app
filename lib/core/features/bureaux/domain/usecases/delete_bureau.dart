import 'package:dental_app/core/features/bureaux/domain/repositories/bureau_repository.dart';

class DeleteBureau {
  final BureauRepository repository;
  DeleteBureau(this.repository);

  void call(String bureauId) => repository.deleteBureau(bureauId);
}
