import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies/models/user.dart';

class UserCubit extends Cubit<User?> {
  UserCubit() : super(null);

  void setUser(User user) {
    emit(user);
  }

  void unsetUser() {
    emit(null);
  }
}
