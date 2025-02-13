class Location {
  final String name;
  final double latitude;
  final double longitude;

  Location({required this.name, required this.latitude, required this.longitude});
}

List<Location> locations = [
  Location(name: "DRB Alger", latitude: 36.7528, longitude: 3.0422),
  Location(name: "DPSB Alger", latitude: 36.7531, longitude: 3.0415),
  Location(name: "CBW Alger", latitude: 36.7540, longitude: 3.0405),
  Location(name: "CBC 1 Alger", latitude: 36.7550, longitude: 3.0380),
  // Ajoute d'autres directions ici...
];
