import 'package:dental_app/core/features/baptemes/domain/repository/baptem_repository.dart';

class DeleteBaptism {
  final BaptismRepository repository;

  DeleteBaptism(this.repository);

  void call(String id) => repository.deleteBaptism(id);
}
