import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/watermark_template.dart';

class ElementControls extends StatefulWidget {
  final WatermarkElement element;
  final ValueChanged<WatermarkElement> onUpdate;
  final VoidCallback onDelete;

  const ElementControls({
    super.key,
    required this.element,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ElementControls> createState() => _ElementControlsState();
}

class _ElementControlsState extends State<ElementControls> {
  late WatermarkElement _currentElement;

  @override
  void initState() {
    super.initState();
    _currentElement = widget.element;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getElementTypeName(_currentElement.type),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Visibility toggle
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.visible),
            value: _currentElement.isVisible,
            onChanged: (value) => _updateElement(isVisible: value),
          ),

          // Opacity slider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opacity: ${(_currentElement.opacity * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: _currentElement.opacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  onChanged: (value) => _updateElement(opacity: value),
                ),
              ],
            ),
          ),

          // Scale slider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scale: ${_currentElement.scale.toStringAsFixed(2)}x',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: _currentElement.scale,
                  min: 0.1,
                  max: 3.0,
                  divisions: 29,
                  onChanged: (value) => _updateElement(scale: value),
                ),
              ],
            ),
          ),

          // Text input for text-based elements
          if (_currentElement.type != WatermarkElementType.logo &&
              _currentElement.type != WatermarkElementType.border &&
              _currentElement.type != WatermarkElementType.qrCode)
            _buildTextInput(),

          // Background color picker
          if (_currentElement.type != WatermarkElementType.logo)
            _buildColorPicker(),

          // Text style controls
          if (_currentElement.type != WatermarkElementType.logo &&
              _currentElement.type != WatermarkElementType.border &&
              _currentElement.type != WatermarkElementType.qrCode)
            _buildTextStyleControls(),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: TextEditingController(text: _currentElement.text),
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.addCustomText,
          border: const OutlineInputBorder(),
          hintText: 'Enter text...',
        ),
        onChanged: (value) => _updateElement(text: value),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.backgroundColor),
          const SizedBox(height: 8),
          Row(
            children: [
              _ColorOption(
                color: Colors.transparent,
                isSelected:
                    _currentElement.backgroundColor == Colors.transparent,
                onTap: () =>
                    _updateElement(backgroundColor: Colors.transparent),
              ),
              _ColorOption(
                color: Colors.black.withOpacity(0.5),
                isSelected:
                    _currentElement.backgroundColor ==
                    Colors.black.withOpacity(0.5),
                onTap: () => _updateElement(
                  backgroundColor: Colors.black.withOpacity(0.5),
                ),
              ),
              _ColorOption(
                color: Colors.white.withOpacity(0.5),
                isSelected:
                    _currentElement.backgroundColor ==
                    Colors.white.withOpacity(0.5),
                onTap: () => _updateElement(
                  backgroundColor: Colors.white.withOpacity(0.5),
                ),
              ),
              _ColorOption(
                color: Colors.blue.withOpacity(0.5),
                isSelected:
                    _currentElement.backgroundColor ==
                    Colors.blue.withOpacity(0.5),
                onTap: () => _updateElement(
                  backgroundColor: Colors.blue.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: _currentElement.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextStyleControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.textStyle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<double>(
                value: _currentElement.style.fontSize,
                decoration: InputDecoration(
                  labelText: 'Font Size',
                  border: const OutlineInputBorder(),
                ),
                items: [10, 12, 14, 16, 18, 20, 24, 28, 32]
                    .map(
                      (size) => DropdownMenuItem(
                        value: size.toDouble(),
                        child: Text('$size'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => _updateElement(
                  style: _currentElement.style.copyWith(fontSize: value),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<FontWeight>(
                value: _currentElement.style.fontWeight,
                decoration: InputDecoration(
                  labelText: 'Weight',
                  border: const OutlineInputBorder(),
                ),
                items: FontWeight.values
                    .where((w) => w.index % 100 == 0)
                    .map(
                      (weight) => DropdownMenuItem(
                        value: weight,
                        child: Text(_getFontWeightName(weight)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => _updateElement(
                  style: _currentElement.style.copyWith(fontWeight: value),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Color>(
                value: _currentElement.style.color,
                decoration: InputDecoration(
                  labelText: 'Color',
                  border: const OutlineInputBorder(),
                ),
                items:
                    [
                          Colors.white,
                          Colors.black,
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.yellow,
                        ]
                        .map(
                          (color) => DropdownMenuItem(
                            value: color,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: color,
                                  margin: const EdgeInsets.only(right: 8),
                                ),
                                Text(_getColorName(color)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) => _updateElement(
                  style: _currentElement.style.copyWith(color: value),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getElementTypeName(WatermarkElementType type) {
    switch (type) {
      case WatermarkElementType.logo:
        return AppLocalizations.of(context)!.logo;
      case WatermarkElementType.timestamp:
        return AppLocalizations.of(context)!.timestampLabel;
      case WatermarkElementType.location:
        return AppLocalizations.of(context)!.locationLabelShort;
      case WatermarkElementType.address:
        return AppLocalizations.of(context)!.addressLabelShort;
      case WatermarkElementType.customText:
        return AppLocalizations.of(context)!.customTextLabel;
      case WatermarkElementType.gpsCoordinates:
        return AppLocalizations.of(context)!.gpsCoordinatesLabel;
      case WatermarkElementType.deviceInfo:
        return AppLocalizations.of(context)!.deviceInfoLabel;
      case WatermarkElementType.border:
        return AppLocalizations.of(context)!.borderLabel;
      case WatermarkElementType.qrCode:
        return AppLocalizations.of(context)!.qrCodeLabel;
    }
  }

  String _getFontWeightName(FontWeight weight) {
    switch (weight) {
      case FontWeight.w100:
        return 'Thin';
      case FontWeight.w200:
        return 'Extra Light';
      case FontWeight.w300:
        return 'Light';
      case FontWeight.w400:
        return 'Regular';
      case FontWeight.w500:
        return 'Medium';
      case FontWeight.w600:
        return 'Semi Bold';
      case FontWeight.w700:
        return 'Bold';
      case FontWeight.w800:
        return 'Extra Bold';
      case FontWeight.w900:
        return 'Black';
      default:
        return 'Normal';
    }
  }

  String _getColorName(Color color) {
    if (color == Colors.white) return 'White';
    if (color == Colors.black) return 'Black';
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.yellow) return 'Yellow';
    return 'Custom';
  }

  void _updateElement({
    String? text,
    double? opacity,
    double? scale,
    bool? isVisible,
    Color? backgroundColor,
    TextStyle? style,
  }) {
    setState(() {
      _currentElement = _currentElement.copyWith(
        text: text ?? _currentElement.text,
        opacity: opacity ?? _currentElement.opacity,
        scale: scale ?? _currentElement.scale,
        isVisible: isVisible ?? _currentElement.isVisible,
        backgroundColor: backgroundColor ?? _currentElement.backgroundColor,
        style: style ?? _currentElement.style,
      );
    });
    widget.onUpdate(_currentElement);
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }
}
