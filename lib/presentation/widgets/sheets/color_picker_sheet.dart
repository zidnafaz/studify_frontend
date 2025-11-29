import 'package:flutter/material.dart';

class ColorPickerSheet extends StatelessWidget {
  final Color? selectedColor;

  const ColorPickerSheet({super.key, this.selectedColor});

  static const List<Color> _scheduleColors = [
    Color(0xFFFF6B6B), // scheduleRed
    Color(0xFFFF9F43), // scheduleOrange
    Color(0xFFFECA57), // scheduleYellow
    Color(0xFF5CD9C1), // scheduleGreen
    Color(0xFF4A90E2), // scheduleBlue
    Color(0xFFB085CC), // schedulePurple
    Color(0xFFFF6B9D), // schedulePink
    Color(0xFF00D2D3), // scheduleTeal
    Color(0xFF5F27CD), // scheduleIndigo
    Color(0xFF48DBFB), // scheduleCyan
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Warna',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),

              // Color Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _scheduleColors.length,
                itemBuilder: (context, index) {
                  final color = _scheduleColors[index];
                  final isSelected = selectedColor == color;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, color);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: colorScheme.primary, width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
