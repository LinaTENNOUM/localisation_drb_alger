import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'locations.dart';

void main() => runApp(const MyApp());

/// Une couleur par wilaya (8 couleurs, réutilisées en boucle si besoin)
const List<Color> wilayaColors = [
  Color(0xFF1565C0), // bleu
  Color(0xFF00897B), // turquoise
  Color(0xFFEF6C00), // orange
  Color(0xFF6A1B9A), // violet
  Color(0xFFC62828), // rouge
  Color(0xFF2E7D32), // vert
  Color(0xFF00838F), // cyan
  Color(0xFF4E342E), // marron
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Localisation DRBA',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0D47A1),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// ÉCRAN D'ACCUEIL : wilayas > DPSB + CF
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  /// Filtre : si le texte correspond au nom de la wilaya, on garde toute la
  /// wilaya ; sinon on garde seulement les lieux qui correspondent.
  Map<String, List<Location>> get _filtered {
    final all = groupByWilaya(locations);
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;

    final result = <String, List<Location>>{};
    all.forEach((wilaya, items) {
      if (wilaya.toLowerCase().contains(q)) {
        result[wilaya] = items;
      } else {
        final match =
            items.where((l) => l.name.toLowerCase().contains(q)).toList();
        if (match.isNotEmpty) result[wilaya] = match;
      }
    });
    return result;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allWilayas = groupByWilaya(locations).keys.toList();
    final data = _filtered;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ---------- En-tête ----------
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
              title: const Text(
                'Localisation DRBA',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(top: 50, right: 16),
                child: Icon(Icons.account_balance,
                    size: 70, color: Colors.white.withOpacity(0.15)),
              ),
            ),
          ),

          // ---------- Recherche ----------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Rechercher une wilaya, un DPSB, un CF…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ---------- Liste des wilayas ----------
          if (data.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 56, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Aucun résultat', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final wilaya = data.keys.elementAt(i);
                    final color = wilayaColors[
                        allWilayas.indexOf(wilaya) % wilayaColors.length];
                    return WilayaCard(
                      // la clé change quand on cherche => la carte s'ouvre toute seule
                      key: ValueKey('$wilaya-${_query.isNotEmpty}'),
                      wilaya: wilaya,
                      items: data[wilaya]!,
                      color: color,
                      expanded: _query.isNotEmpty,
                    );
                  },
                  childCount: data.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// CARTE D'UNE WILAYA
// ============================================================
class WilayaCard extends StatelessWidget {
  final String wilaya;
  final List<Location> items;
  final Color color;
  final bool expanded;

  const WilayaCard({
    super.key,
    required this.wilaya,
    required this.items,
    required this.color,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final dpsbs = items.where((l) => l.isDpsb).toList();
    final cfs = items.where((l) => !l.isDpsb).toList();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.25)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: color,
            child: const Icon(Icons.location_city, color: Colors.white),
          ),
          title: Text(
            wilaya,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          subtitle: Text('${dpsbs.length} DPSB  •  ${cfs.length} CF'),
          children: [
            ...dpsbs.map((l) => LocationTile(location: l, color: color)),
            if (dpsbs.isNotEmpty && cfs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: color.withOpacity(0.2)),
              ),
            ...cfs.map((l) => LocationTile(location: l, color: color)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  final Location location;
  final Color color;

  const LocationTile({super.key, required this.location, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDpsb = location.isDpsb;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(
        isDpsb ? Icons.account_balance : Icons.place,
        color: isDpsb ? color : Colors.grey.shade600,
      ),
      title: Text(
        location.name,
        style: TextStyle(
          fontWeight: isDpsb ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: isDpsb
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('DPSB',
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            )
          : const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapScreen(location: location, color: color),
        ),
      ),
    );
  }
}

// ============================================================
// ÉCRAN CARTE
// ============================================================
class MapScreen extends StatelessWidget {
  final Location location;
  final Color color;

  const MapScreen({super.key, required this.location, required this.color});

  Future<void> _openGoogleMaps(BuildContext context) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = LatLng(location.latitude, location.longitude);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: pos, zoom: 15),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: MarkerId(location.name),
                position: pos,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  location.isDpsb
                      ? BitmapDescriptor.hueAzure
                      : BitmapDescriptor.hueRed,
                ),
                infoWindow: InfoWindow(title: location.name),
              ),
            },
          ),

          // Bouton retour
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Carte d'information en bas
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color,
                            child: Icon(
                              location.isDpsb
                                  ? Icons.account_balance
                                  : Icons.place,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(location.name,
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(
                                  '${location.isDpsb ? "DPSB" : "CF"}  •  Wilaya de ${location.wilaya}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _openGoogleMaps(context),
                          icon: const Icon(Icons.directions),
                          label: const Text('Itinéraire'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
