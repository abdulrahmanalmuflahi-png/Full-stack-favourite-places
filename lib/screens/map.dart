

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/screens/places_detail.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
    ),
    this.isSelecting = true, // 1. إضافة المتغير إلى Constructor
  });

  final PlaceLocation location;
  final bool isSelecting; // 2. تعريف المتغير كـ Property

  @override
  State<StatefulWidget> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelecting ? 'Pick Your Location' : 'Your Location',
        ),
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
                // Handle location selection
              },
            ),
        ],
      ),
      body: GoogleMap(
        onTap: !widget.isSelecting ? null :// 3. استخدام المتغير لتحديد ما إذا كان المستخدم يمكنه اختيار الموقع أم لا
         (position) {
          setState(() {
            _pickedLocation = position;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.location.latitude, widget.location.longitude),
          zoom: 16,
        ),
        markers: (_pickedLocation == null && widget.isSelecting)? {}: {
                Marker(
                  markerId: const MarkerId('m1'),
                  position:
                      _pickedLocation ??
                      LatLng(
                        widget.location.latitude,
                        widget.location.longitude,
                      ),
                ),
              },
      ),
    );
  }
}
