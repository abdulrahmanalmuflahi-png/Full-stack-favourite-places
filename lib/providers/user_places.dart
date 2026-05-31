import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favourite_places/models/place.dart';
 
class UserPlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() {
    return [];
  }
 
  String get _userId => FirebaseAuth.instance.currentUser!.uid;
 
  CollectionReference get _placesRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_userId)
      .collection('places');
 
  Future<void> loadPlaces() async {
    final snapshot =
        await _placesRef.orderBy('createdAt', descending: true).get();
 
    final places = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Place(
        id: doc.id,
        title: data['title'] as String,
        imageBase64: data['imageBase64'] as String,
        location: PlaceLocation(
          latitude: (data['lat'] as num).toDouble(),
          longitude: (data['lng'] as num).toDouble(),
          address: data['address'] as String?,
        ),
      );
    }).toList();
 
    state = places;
  }
 
  Future<void> addPlace(
      String title, String imageBase64, PlaceLocation location) async {
    final docRef = await _placesRef.add({
      'title': title,
      'imageBase64': imageBase64,
      'lat': location.latitude,
      'lng': location.longitude,
      'address': location.address ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
 
    final newPlace = Place(
      id: docRef.id,
      title: title,
      imageBase64: imageBase64,
      location: location,
    );
 
    state = [newPlace, ...state];
  }
 
  Future<void> removePlace(String id) async {
    await _placesRef.doc(id).delete();
    state = state.where((place) => place.id != id).toList();
  }
}
 
final userPlacesProvider = NotifierProvider<UserPlacesNotifier, List<Place>>(
  () => UserPlacesNotifier(),
);