import 'package:flutter/material.dart';
import 'package:rela/Service/location.dart';
import 'package:rela/model/userdto.dart';

class LocateProvider with ChangeNotifier {
  final LocationService locationService = LocationService();

  List<UserNear> nearbyUsers = [];
  bool isLoading = false;
  bool isFindme = false;
  bool isUpdating = false;

  Future<void> fetchNearbyUsers(int userId) async {
    try {
      isLoading = true;
      notifyListeners();

      nearbyUsers = await locationService.getNearbyUsers(userId);
    } catch (e) {
      debugPrint("❌ fetchNearbyUsers: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFindMe(int userId) async {
    if (isUpdating) return;
    isUpdating = true;

    isFindme = !isFindme;
    notifyListeners();

    if (isFindme) {
      try {
        final locate = await LocationService.getCurrentLocation();
        if (locate != null) {
          await locationService.changeStatusProfileVisibility(
            userId,
            locate.latitude,
            locate.longitude,
          );
        }
      } catch (e) {
        debugPrint("❌ toggleFindMe: $e");
      }
    }

    isUpdating = false;
    notifyListeners();
  }
}
