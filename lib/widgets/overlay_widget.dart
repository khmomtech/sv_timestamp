import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sv_timestamp/models/template_model.dart';
import 'package:sv_timestamp/services/time_service.dart';
import 'package:sv_timestamp/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class OverlayWidget extends StatelessWidget {
  final Position? position;
  final String? address; // optional; placeholder
  final double? altitude;

  const OverlayWidget({super.key, this.position, this.address, this.altitude});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<TemplateModel>(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            // Top left: logo & small info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (t.showLogo)
                  Container(
                    height: 42,
                    width: 42,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset('assets/logo.png'),
                  ),
                const SizedBox(width: 10),
                // time and address block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (t.showTimestamp)
                        Text(
                          TimeService.prettyNow(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (t.showAddress && address != null)
                        Text(
                          address!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      if (t.showCoords && position != null)
                        Text(
                          LocationService.coordsToString(position!),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      if (t.showAltitude && altitude != null)
                        Text(
                          'Alt: ${altitude!.toStringAsFixed(0)} ft',
                          style: const TextStyle(color: Colors.white70),
                        ),
                    ],
                  ),
                ),
                // small map placeholder right
                if (t.showMap)
                  Container(
                    height: 60,
                    width: 60,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.map, color: Colors.black54),
                    ),
                  ),
              ],
            ),

            // Spacer to push footer to bottom
            const Spacer(),
            // bottom-left big timestamp style
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (t.showTimestamp)
                      Text(
                        TimeService.shortTime(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateTime.now().toLocal().toString().split(' ').first,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (t.showAddress && address != null)
                          SizedBox(
                            width: 200,
                            child: Text(
                              address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
