import 'package:blooddonation/widgets/hospital_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/hospital_service.dart';
import '../../services/location_service.dart';
import '../../theme/AppTheme_data.dart';

class EmergencyHospitalsMapScreen extends StatefulWidget {
  @override
  _EmergencyHospitalsMapScreenState createState() =>
      _EmergencyHospitalsMapScreenState();
}

class _EmergencyHospitalsMapScreenState
    extends State<EmergencyHospitalsMapScreen> {
  late MapController mapController;
  final locationService = LocationService();
  final hospitalService = HospitalService();

  LatLng? userLocation;
  List<Hospital> hospitals = [];
  bool isLoading = true;
  Hospital? selectedHospital;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      final position = await locationService.getCurrentLocation();

      if (position != null) {
        setState(() {
          userLocation = LatLng(position.latitude, position.longitude);
        });

        // Fetch nearby hospitals
        final nearbyHospitals = await hospitalService.getNearbyHospitals(
          userLat: position.latitude,
          userLng: position.longitude,
          radiusInKm: 10.0,
        );

        // If no hospitals found in Firestore, use mock data
        final hospitalsToShow = nearbyHospitals.isEmpty
            ? HospitalService.getMockHospitals(
          position.latitude,
          position.longitude,
        )
            : nearbyHospitals;

        setState(() {
          hospitals = hospitalsToShow;
          isLoading = false;
        });

        // Move camera to show all markers
        if (userLocation != null && hospitals.isNotEmpty) {
          _fitMapToMarkers();
        }
      } else {
        // Fallback to mock location if permission denied
        const fallbackLocation = LatLng(31.5204, 74.3587); // Lahore, Pakistan
        setState(() {
          userLocation = fallbackLocation;
        });

        final mockHospitals =
        HospitalService.getMockHospitals(31.5204, 74.3587);

        setState(() {
          hospitals = mockHospitals;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing map: $e');
      setState(() => isLoading = false);
    }
  }

  void _fitMapToMarkers() {
    if (hospitals.isEmpty || userLocation == null) return;

    double minLat = hospitals[0].latitude;
    double maxLat = hospitals[0].latitude;
    double minLng = hospitals[0].longitude;
    double maxLng = hospitals[0].longitude;

    for (var hospital in hospitals) {
      minLat = minLat > hospital.latitude ? hospital.latitude : minLat;
      maxLat = maxLat < hospital.latitude ? hospital.latitude : maxLat;
      minLng = minLng > hospital.longitude ? hospital.longitude : minLng;
      maxLng = maxLng < hospital.longitude ? hospital.longitude : maxLng;
    }

    minLat = minLat > userLocation!.latitude ? userLocation!.latitude : minLat;
    maxLat = maxLat < userLocation!.latitude ? userLocation!.latitude : maxLat;
    minLng = minLng > userLocation!.longitude ? userLocation!.longitude : minLng;
    maxLng = maxLng < userLocation!.longitude ? userLocation!.longitude : maxLng;

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(50),
      ),
    );
  }

  void _showHospitalDetails(Hospital hospital) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildHospitalDetailsSheet(hospital),
    );
  }

  Widget _buildHospitalDetailsSheet(Hospital hospital) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hospital name and blood bank status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (hospital.hasBloodBank)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bloodtype,
                                size: 14,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Blood Bank Available',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Distance and rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  Icons.location_on_rounded,
                  '${hospital.distance?.toStringAsFixed(1)} km',
                  'Distance',
                ),
                if (hospital.rating != null)
                  _buildInfoChip(
                    Icons.star_rounded,
                    '${hospital.rating}',
                    'Rating',
                  ),
              ],
            ),
            SizedBox(height: 20),

            // Address
            _buildDetailItem(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: hospital.address,
            ),
            SizedBox(height: 16),

            // Phone
            if (hospital.phone != null)
              _buildDetailItem(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: hospital.phone!,
              ),
            SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchMap(hospital),
                    icon: Icon(Icons.directions_rounded, color: Colors.white),
                    label: Text('Get Directions',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                if (hospital.phone != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callHospital(hospital.phone!),
                      icon: Icon(Icons.call_rounded, color: Colors.white),
                      label:
                      Text('Call', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightRed.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryRed, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryRed, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchMap(Hospital hospital) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${hospital.latitude},${hospital.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callHospital(String phone) async {
    final url = 'tel:$phone';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Hospitals', style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: AppTheme.primaryRed,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryRed,
        ),
      )
          : Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: userLocation ?? LatLng(31.5204, 74.3587),
              initialZoom: 14,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              // Tile Layer - OpenStreetMap (FREE!)
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.blooddonation',
                maxZoom: 19,
              ),

              // Hospital Markers
              MarkerLayer(
                markers: [
                  // User location marker
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),

                  // Hospital markers
                  ...hospitals.map((hospital) {
                    return Marker(
                      point: LatLng(hospital.latitude, hospital.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedHospital = hospital);
                          _showHospitalDetails(hospital);
                          // Move map to this hospital
                          mapController.move(
                            LatLng(hospital.latitude, hospital.longitude),
                            15,
                          );
                        },
                        child: Icon(
                          hospital.hasBloodBank
                              ? Icons.local_hospital
                              : Icons.local_hospital_outlined,
                          color: hospital.hasBloodBank
                              ? Colors.red
                              : Colors.orange,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),

          // Zoom controls
          Positioned(
            right: 16,
            bottom: 220,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    final currentZoom = mapController.camera.zoom;
                    mapController.move(
                      mapController.camera.center,
                      currentZoom + 1,
                    );
                  },
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add, color: AppTheme.primaryRed),
                ),
                SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    final currentZoom = mapController.camera.zoom;
                    mapController.move(
                      mapController.camera.center,
                      currentZoom - 1,
                    );
                  },
                  backgroundColor: Colors.white,
                  child: Icon(Icons.remove, color: AppTheme.primaryRed),
                ),
                SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'my_location',
                  onPressed: () {
                    if (userLocation != null) {
                      mapController.move(userLocation!, 15);
                    }
                  },
                  backgroundColor: Colors.white,
                  child: Icon(Icons.my_location, color: AppTheme.primaryRed),
                ),
              ],
            ),
          ),

          // Hospital list at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [AppTheme.elevatedShadow],
              ),
              child: hospitals.isEmpty
                  ? Center(
                child: Text(
                  'No hospitals found nearby',
                  style: TextStyle(color: AppTheme.textLight),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(16),
                scrollDirection: Axis.horizontal,
                itemCount: hospitals.length,
                itemBuilder: (context, index) {
                  final hospital = hospitals[index];
                  return _buildHospitalCard(hospital);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    return GestureDetector(
      onTap: () {
        _showHospitalDetails(hospital);
        // Move map to hospital
        mapController.move(
          LatLng(hospital.latitude, hospital.longitude),
          15,
        );
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hospital.hasBloodBank
                ? AppTheme.primaryRed
                : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [AppTheme.cardShadow],
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hospital.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hospital.hasBloodBank)
                  Icon(Icons.bloodtype, size: 16, color: Colors.red),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: AppTheme.textLight),
                SizedBox(width: 4),
                Text(
                  '${hospital.distance?.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              hospital.address,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textHint,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            Row(
              children: [
                if (hospital.rating != null)
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        hospital.rating.toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                Spacer(),
                TextButton(
                  onPressed: () => _showHospitalDetails(hospital),
                  child: Text('Details'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}