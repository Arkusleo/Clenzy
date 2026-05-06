import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late WebSocketChannel _channel;
  LatLng _expertLocation = const LatLng(12.9716, 77.5946); // Default location
  final LatLng _userLocation = const LatLng(12.9720, 77.5950);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Connect to the Python backend WebSocket
    // Note: use 10.0.2.2 for Android Emulator connecting to local host
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8000/api/ws/user_123'), 
    );

    _channel.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        if (data['type'] == 'location_update') {
          setState(() {
            _expertLocation = LatLng(data['lat'], data['lng']);
            _mapController.move(_expertLocation, 16.0);
          });
        }
      } catch (e) {
        debugPrint("Error parsing message: $e");
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void _simulateExpertMovement() {
    // Send a message to the WebSocket to simulate the expert sending their location
    // The server will route this back to target_user_id (which is us: user_123)
    final testData = jsonEncode({
      "type": "location_update",
      "target_user_id": "user_123",
      "lat": _expertLocation.latitude + 0.0001,
      "lng": _expertLocation.longitude + 0.0001,
    });
    _channel.sink.add(testData);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.black),
            onPressed: _simulateExpertMovement,
            tooltip: 'Simulate Movement',
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1) Real Map Background
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _expertLocation,
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.clenzy.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.home, color: Colors.green, size: 40),
                    ),
                    Marker(
                      point: _expertLocation,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            )
                          ]
                        ),
                        child: const Icon(Icons.directions_car, color: Color(0xFFE91E63), size: 30),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2) Content overlay
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Titles
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Track your',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Expert, Live',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Expert Status Indicator & Bottom Card overlay
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main White Card
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 60,
                          ), // Space for overlapping Pink Banner
                          // Expert Profile Row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: const NetworkImage(
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop',
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lata Patil',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '4.8',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.phone_outlined),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // OTP Section mock underneath
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check-in OTP',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(
                                  4,
                                  (index) => Container(
                                    width: 45,
                                    height: 45,
                                    margin: const EdgeInsets.only(right: 12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '•',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Pink Tracking Banner Overlay
                    Positioned(
                      top: -10, // Slightly overlap top for effect
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 100, // Reduced from 120 to fix stretch
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63), // Pinkish red
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Expert on the way',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Lata will arrive on time',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ETA Circle floating over banner
                    Positioned(
                      top: -40, // higher up relative to the card
                      right: 40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 6),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ARRIVING IN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '10',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'MIN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Footer text
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No guessing. ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'No follow-ups.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
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
    );
  }
}
