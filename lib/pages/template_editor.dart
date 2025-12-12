import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sv_timestamp/models/template_model.dart';

class TemplateEditor extends StatelessWidget {
  static const routeName = '/template-editor';
  const TemplateEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<TemplateModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit template'),
        backgroundColor: Colors.black87,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Timestamp'),
            value: t.showTimestamp,
            onChanged: (_) => t.toggleTimestamp(),
          ),
          SwitchListTile(
            title: const Text('Address'),
            value: t.showAddress,
            onChanged: (_) => t.toggleAddress(),
          ),
          SwitchListTile(
            title: const Text('Coordinates (lat/lng)'),
            value: t.showCoords,
            onChanged: (_) => t.toggleCoords(),
          ),
          SwitchListTile(
            title: const Text('Altitude'),
            value: t.showAltitude,
            onChanged: (_) => t.toggleAltitude(),
          ),
          SwitchListTile(
            title: const Text('Map thumbnail'),
            value: t.showMap,
            onChanged: (_) => t.toggleMap(),
          ),
          SwitchListTile(
            title: const Text('Logo'),
            value: t.showLogo,
            onChanged: (_) => t.toggleLogo(),
          ),
        ],
      ),
    );
  }
}
