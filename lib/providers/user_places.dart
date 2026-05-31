import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart'as sql;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:sqflite/sqlite_api.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favourite_places/models/place.dart';



// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:favourite_places/models/place.dart';

// Notifier بدل StateNotifier

Future<Database> _getDatabase() async {

  final dbPath = await sql.getDatabasesPath();
final db = await sql.openDatabase(
  path.join(dbPath, 'places.db'),
  onCreate: (db, version) {
    return db.execute(
      'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)'
    );
  },
  version: 1,
);
return db;
}

class UserPlacesNotifier extends Notifier<List<Place>> {
  
  @override
  List<Place> build() {
    return []; // هنا تحدد القيمة الأولية
  }

  Future<void> loadPlaces() async {
  final db = await _getDatabase();
  final data = await db.query('user_places');
  final places = data.map(
    (row) => Place(
      id: row['id'] as String,
      title: row['title'] as String,
      image: File(row['image'] as String),
      location: PlaceLocation(
        latitude: row['lat'] as double,
        longitude: row['lng'] as double,
        address: row['address'] as String,
      ), // PlaceLocation
    ), // Place
  ).toList();
  state = places;
}

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$fileName');


    final newPlace = Place(title: title, image: copiedImage, location: location);
final db = await _getDatabase();
db.insert('user_places', {
  'id': newPlace.id,
  'title': newPlace.title,
  'image': newPlace.image.path,
  'lat': newPlace.location.latitude,
  'lng': newPlace.location.longitude,
  'address': newPlace.location.address,
});

    state = [newPlace, ...state];
  }
}

// NotifierProvider بدل StateNotifierProvider
final userPlacesProvider = NotifierProvider<UserPlacesNotifier, List<Place>>(
  () => UserPlacesNotifier(),
);

// class UserPlacesNotifier extends StateNotifier<List<Place>> {
//   UserPlacesNotifier() : super(const []);

//   void addPlace(String title) {
//     final newPlace = Place(title: title);
//     state = [newPlace, ...state];
//   }
// }

// final userPlacesProvider =
//     StateNotifierProvider<UserPlacesNotifier, List<Place>>(
//   (ref) => UserPlacesNotifier(),
// );
