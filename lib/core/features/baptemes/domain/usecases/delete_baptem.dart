import 'package:dental_app/core/features/baptemes/domain/repository/baptem_repository.dart';

class DeleteBaptism {
  final BaptismRepository repository;

  DeleteBaptism(this.repository);

  Future<void> call(String id) async => await repository.deleteBaptism(id);
}
