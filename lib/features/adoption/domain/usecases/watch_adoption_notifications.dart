import 'package:injectable/injectable.dart';
import '../entities/adoption_request_entity.dart';
import '../repositories/adoption_repository.dart';

@lazySingleton
class WatchAdoptionNotifications {
  final AdoptionRepository repository;

  WatchAdoptionNotifications(this.repository);

  Stream<AdoptionRequestEntity> call() {
    return repository.adoptionStream;
  }
}