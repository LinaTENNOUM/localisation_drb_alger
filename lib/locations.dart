// locations.dart
// ------------------------------------------------------------
// Tu n'as qu'à ajouter des lignes dans la liste `locations`.
// L'appli regroupe automatiquement par wilaya :
// pas besoin de toucher au reste du code.
// ------------------------------------------------------------

enum LocationType { dpsb, cf }

class Location {
  final String name;
  final String wilaya;
  final LocationType type;
  final double latitude;
  final double longitude;

  const Location({
    required this.name,
    required this.wilaya,
    required this.type,
    required this.latitude,
    required this.longitude,
  });

  bool get isDpsb => type == LocationType.dpsb;
}

/// Raccourcis pour écrire les données plus vite
Location dpsb(String wilaya, String name, double lat, double lng) => Location(
      name: name,
      wilaya: wilaya,
      type: LocationType.dpsb,
      latitude: lat,
      longitude: lng,
    );

Location cf(String wilaya, String name, double lat, double lng) => Location(
      name: name,
      wilaya: wilaya,
      type: LocationType.cf,
      latitude: lat,
      longitude: lng,
    );

/// Regroupe la liste par wilaya (l'ordre d'apparition est conservé)
Map<String, List<Location>> groupByWilaya(List<Location> items) {
  final map = <String, List<Location>>{};
  for (final l in items) {
    map.putIfAbsent(l.wilaya, () => []).add(l);
  }
  return map;
}

// ------------------------------------------------------------
// DONNÉES : remplace les exemples ci-dessous par tes vraies
// directions (8 wilayas, chacune avec son DPSB et ses CF).
// ------------------------------------------------------------
final List<Location> locations = [
  // ---- Alger ----
  dpsb('Alger', 'DPSB Alger', 36.7538, 3.0588),
  // cf('Alger', 'Nom du CF', latitude, longitude),

  // ---- Blida ----
  dpsb('Blida', 'DPSB Blida', 36.4700, 2.8300),
  // cf('Blida', 'Nom du CF', latitude, longitude),

  // ---- Boumerdès ----
  dpsb('Boumerdès', 'DPSB Boumerdès', 36.7664, 3.4772),
  // cf('Boumerdès', 'Nom du CF', latitude, longitude),

  // ---- Bouira ----
  dpsb('Bouira', 'DPSB Bouira', 36.3749, 3.9020),
  // cf('Bouira', 'Nom du CF', latitude, longitude),

  // ---- Tizi Ouzou ----
  dpsb('Tizi Ouzou', 'DPSB Tizi Ouzou', 36.7118, 4.0459),
  // cf('Tizi Ouzou', 'Nom du CF', latitude, longitude),

  // ---- Laghouat ----
  dpsb('Laghouat', 'DPSB Laghouat', 33.8000, 2.8650),
  // cf('Laghouat', 'Nom du CF', latitude, longitude),

  // ---- Djelfa ----
  dpsb('Djelfa', 'DPSB Djelfa', 34.6704, 3.2630),
  // cf('Djelfa', 'Nom du CF', latitude, longitude),

  // ---- Médéa ----
  dpsb('Médéa', 'DPSB Médéa', 36.2640, 2.7539),
  // cf('Médéa', 'Nom du CF', latitude, longitude),
];
