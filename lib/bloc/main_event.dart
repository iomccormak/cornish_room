part of 'main_bloc.dart';

@immutable
abstract class MainEvent {
  const MainEvent();
}

class UpdateCamera extends MainEvent {
  final Camera camera;
  const UpdateCamera(this.camera);
}

class ShowMessageEvent extends MainEvent{
  final String message;
  const ShowMessageEvent(this.message);
}
