import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_messenger/config/Paths.dart';
import 'package:flutter_messenger/repositories/StorageRepository.dart';
import 'package:flutter_messenger/repositories/UserDataRepository.dart';
import 'package:flutter_messenger/utils/SharedObjects.dart';
import 'Bloc.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  UserDataRepository userDataRepository;
  StorageRepository storageRepository;

  ConfigBloc({this.userDataRepository, this.storageRepository})
      : assert(userDataRepository != null),
        assert(storageRepository != null);

  @override
  ConfigState get initialState => UnConfigState();

  @override
  Stream<ConfigState> mapEventToState(
    ConfigEvent event,
  ) async* {
    if (event is ConfigValueChanged) {
      SharedObjects.prefs.setBool(event.key, event.value);
      yield ConfigChangeState(event.key, event.value);
    }
    if (event is UpdateProfilePicture) {
      yield* mapUpdateProfilePictureToState(event);
    }
  }

  Stream<ConfigState> mapUpdateProfilePictureToState(
      UpdateProfilePicture event) async* {
    yield UpdatingProfilePictureState();
    final  profilePictureUrl = await storageRepository.uploadFile(event.file, Paths.profilePicturePath);
    await userDataRepository.updateProfilePicture(profilePictureUrl);
    yield ProfilePictureChangedState(profilePictureUrl);
  }
}
