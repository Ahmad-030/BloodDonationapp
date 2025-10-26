import 'package:blooddonation/widgets/hospital_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_service.dart';

class HospitalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get nearby hospitals from Firestore
  Future<List<Hospital>> getNearbyHospitals({
    required double userLat,
    required double userLng,
    double radiusInKm = 5.0,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('hospitals')
          .get();

      List<Hospital> hospitals = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final hospital = Hospital.fromJson({
          'id': doc.id,
          ...data,
        });

        final distance = LocationService.calculateDistance(
          userLat,
          userLng,
          hospital.latitude,
          hospital.longitude,
        );

        final distanceInKm = distance / 1000;

        if (distanceInKm <= radiusInKm) {
          hospitals.add(Hospital(
            id: hospital.id,
            name: hospital.name,
            latitude: hospital.latitude,
            longitude: hospital.longitude,
            address: hospital.address,
            phone: hospital.phone,
            rating: hospital.rating,
            hasBloodBank: hospital.hasBloodBank,
            distance: distanceInKm,
          ));
        }
      }

      // Sort by distance
      hospitals.sort((a, b) =>
          (a.distance ?? 0).compareTo(b.distance ?? 0));

      return hospitals;
    } catch (e) {
      print('Error fetching hospitals: $e');
      return [];
    }
  }

  // Get mock hospitals (for testing without Firestore setup)
  static List<Hospital> getMockHospitals(
      double userLat,
      double userLng,
      ) {
    final mockHospitals = [
      Hospital(
        id: '1',
        name: 'City General Hospital',
        latitude: userLat + 0.01,
        longitude: userLng + 0.01,
        address: '123 Main Street',
        phone: '+92-300-1234567',
        rating: 4.5,
        hasBloodBank: true,
      ),
      Hospital(
        id: '2',
        name: 'Medical Care Center',
        latitude: userLat - 0.02,
        longitude: userLng + 0.015,
        address: '456 Oak Avenue',
        phone: '+92-300-2345678',
        rating: 4.2,
        hasBloodBank: true,
      ),
      Hospital(
        id: '3',
        name: 'Emergency Medical Clinic',
        latitude: userLat + 0.025,
        longitude: userLng - 0.01,
        address: '789 Emergency Lane',
        phone: '+92-300-3456789',
        rating: 4.8,
        hasBloodBank: true,
      ),
      Hospital(
        id: '4',
        name: 'St. Medical Institute',
        latitude: userLat - 0.015,
        longitude: userLng - 0.02,
        address: '321 Health Boulevard',
        phone: '+92-300-4567890',
        rating: 4.3,
        hasBloodBank: false,
      ),
    ];

    // Calculate distances
    return mockHospitals.map((h) {
      final distance = LocationService.calculateDistance(
        userLat,
        userLng,
        h.latitude,
        h.longitude,
      ) / 1000;
      return Hospital(
        id: h.id,
        name: h.name,
        latitude: h.latitude,
        longitude: h.longitude,
        address: h.address,
        phone: h.phone,
        rating: h.rating,
        hasBloodBank: h.hasBloodBank,
        distance: distance,
      );
    }).toList()
      ..sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
  }
}
