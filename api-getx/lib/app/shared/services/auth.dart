import 'package:get/get.dart';

import '../../../helpers/helpers.dart';
import '../../models/user_model.dart';
import '../../modules/modules.dart';
import '../shared.dart';

/// Manages authentication states and logics
class Auth extends GetxService {
  /// Static Getter for [Auth]
  static Auth get instance {
    if (!Get.isRegistered<Auth>()) Get.put(Auth());
    return Get.find<Auth>();
  }

  /// Get [AuthService] instance
  final AuthSessionService _AuthSessionService = AuthSessionService.instance;

  /// Observables
  final _user = UserModel().obs;

  /// Getters
  UserModel get user => _user.value;

  @override
  void onInit() {
    super.onInit();
    getUser();
  }

  /// Refreshes User data on every launch of the application
  Future<void> getUser() async {
    if (storage.read("token") != null) {
      ApiResponse response = await _AuthSessionService.getUser();

      if (response.hasError()) {
        Toastr.show(message: "${response.message}");
        return;
      }

      if (response.hasData()) {
        setUserData(response.data);
      }
    }
  }

  /// Logout the user + Server
  Future<void> logout() async {
    ApiResponse response = await _AuthSessionService.logout();
    if (response.hasError()) {
      Toastr.show(message: "${response.message}");
      return;
    }
    Toastr.show(message: "${response.message}");
    await storage.remove('token');
    await storage.remove('user');
    Get.offAllNamed(AuthRoutes.login);
  }

  /// Logout the user
  Future<void> logoutSilently() async {
    await storage.remove('token');
    await storage.remove('user');
    Get.offAllNamed(AuthRoutes.login);
  }

  /// Setter for user data [setUserData(String)]
  Future<void> setUserData(Map<String, dynamic> userData) async {
    await storage.write("user", userData);
    _user(UserModel.fromJson(userData));
  }

  /// Setter for user auth token [setUserToken(String)]
  Future<void> setUserToken(String token) async {
    await storage.write("token", token);
  }

  /// Checks if user is logged in by validating the token
  Future<bool> check() async {
    if (storage.read('token') != null) {
      /// TODO: Add api call here to validate token
      return true;
    }

    return false;
  }

  Future<bool> isLoggedIn() => check();
}
