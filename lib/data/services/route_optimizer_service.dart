import 'dart:math';
import 'package:smc/data/models/task.dart';

/// Route Optimizer Service
/// Optimizes the daily route for field workers based on location proximity
class RouteOptimizerService {
  /// Sort tasks by proximity to the current location (Nearest Neighbor)
  List<Task> optimizeRoute(
      List<Task> tasks, double currentLat, double currentLng) {
    if (tasks.isEmpty) return [];

    List<Task> pendingTasks = List.from(tasks);
    List<Task> optimizedRoute = [];

    double currentLatRad = _toRadians(currentLat);
    double currentLngRad = _toRadians(currentLng);

    // Initial point is current location
    double lastLatRad = currentLatRad;
    double lastLngRad = currentLngRad;

    while (pendingTasks.isNotEmpty) {
      // Find nearest task to the last point
      int nearestIndex = -1;
      double minDistance = double.infinity;

      for (int i = 0; i < pendingTasks.length; i++) {
        final task = pendingTasks[i];
        if (task.latitude == 0 && task.longitude == 0)
          continue; // Skip if no location

        double taskLatRad = _toRadians(task.latitude);
        double taskLngRad = _toRadians(task.longitude);

        double distance =
            _calculateDistance(lastLatRad, lastLngRad, taskLatRad, taskLngRad);

        // Weight by priority (Higher priority tasks appear closer logically)
        // distance = distance / _getPriorityWeight(task.priority);

        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = i;
        }
      }

      if (nearestIndex != -1) {
        final nearestTask = pendingTasks[nearestIndex];
        optimizedRoute.add(nearestTask);

        // Update last point
        lastLatRad = _toRadians(nearestTask.latitude);
        lastLngRad = _toRadians(nearestTask.longitude);

        pendingTasks.removeAt(nearestIndex);
      } else {
        // If remaining tasks have no location, add them at the end
        optimizedRoute.addAll(pendingTasks);
        break;
      }
    }

    return optimizedRoute;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula
    const R = 6371; // Radius of the earth in km
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}


