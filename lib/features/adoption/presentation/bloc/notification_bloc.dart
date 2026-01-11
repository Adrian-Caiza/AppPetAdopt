import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/get_current_user.dart'; // Necesitas saber quién eres
import '../../domain/entities/adoption_request_entity.dart';
import '../../domain/usecases/watch_adoption_notifications.dart';
import '../../../../core/usecase/usecase.dart';

// Eventos
abstract class NotificationEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class StartNotificationListening extends NotificationEvent {}
class _NotificationReceived extends NotificationEvent {
  final AdoptionRequestEntity request;
  _NotificationReceived(this.request);
}

// Estados
abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}
class NotificationInitial extends NotificationState {}
class NotificationTriggered extends NotificationState {
  final String message;
  final bool isSuccess; // verde o azul
  NotificationTriggered({required this.message, this.isSuccess = true});
  @override
  List<Object?> get props => [message, isSuccess, DateTime.now()]; // Hack para forzar rebuild
}

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final WatchAdoptionNotifications watchNotifications;
  final GetCurrentUser getCurrentUser;
  StreamSubscription? _subscription;

  NotificationBloc(this.watchNotifications, this.getCurrentUser) : super(NotificationInitial()) {
    
    on<StartNotificationListening>((event, emit) async {
      final userResult = await getCurrentUser(NoParams());
      
      userResult.fold((l) => null, (user) {
        if (user != null) {
          _subscription?.cancel();
          _subscription = watchNotifications().listen((request) {
            // Lógica de filtrado: ¿Esta notificación es para mí?
            _handleIncomingRequest(request, user);
          });
        }
      });
    });

    on<_NotificationReceived>((event, emit) {
      final status = event.request.status;

      if (status == 'pending') {
        // Caso: Nueva solicitud recibida (Para el Refugio)
        emit(NotificationTriggered(
          message: '¡Nueva solicitud de adopción recibida! 🐶',
          isSuccess: true,
        ));
      } else if (status == 'approved') {
        // Caso: Solicitud Aprobada (Para el Adoptante)
        emit(NotificationTriggered(
          message: '¡Felicidades! Tu solicitud de adopción fue APROBADA 🏠🎉',
          isSuccess: true, // Color Verde
        ));
      } else if (status == 'rejected') {
        // Caso: Solicitud Rechazada (Para el Adoptante)
        emit(NotificationTriggered(
          message: 'Lo sentimos, tu solicitud ha sido rechazada.',
          isSuccess: false, // Color Rojo/Naranja
        ));
      }
    });
  }

  void _handleIncomingRequest(AdoptionRequestEntity request, UserEntity user) {
    final myId = user.id;
    final role = user.userMetadata?['role'];

    if (role == 'shelter' && request.shelterId == myId) {
      // Es para mí (Refugio)
      add(_NotificationReceived(request));
    } else if (role == 'adopter' && request.adopterId == myId) {
      // Es para mí (Adoptante) - cambio de estado
      add(_NotificationReceived(request));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}