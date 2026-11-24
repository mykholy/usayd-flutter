import 'package:flutter/material.dart';
import '../../../../core/config/flavor_config.dart';
import '../../../../core/config/interface_mode.dart';

class HomeScreen extends StatelessWidget {
  final InterfaceMode currentMode;
  final ValueChanged<InterfaceMode> onModeChanged;

  const HomeScreen({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أكاديمية أُسَيْد',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (!FlavorConfig.isProd)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Chip(
                label: Text(
                  FlavorConfig.isDev ? 'DEV' : 'STG',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: FlavorConfig.isDev
                    ? Colors.orange
                    : Colors.blue,
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Brand mark canopy container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3B2B), // Forest Night
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 48,
                      color: Color(0xFFC49A45), // Lamp Gold
                    ),
                    SizedBox(height: 12),
                    Text(
                      'أكاديمية أُسَيْد',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '«اقرأ بصوتٍ تدنو له الملائكة»',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFD4AF37),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Mode switcher
              Card(
                elevation: 0,
                color: const Color(0xFFF0ECE1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'نمط الواجهة التكيفي:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<InterfaceMode>(
                        segments: [
                          ButtonSegment<InterfaceMode>(
                            value: InterfaceMode.kids,
                            label: Text(InterfaceMode.kids.displayNameArabic),
                            icon: const Icon(Icons.star_rounded),
                          ),
                          ButtonSegment<InterfaceMode>(
                            value: InterfaceMode.pro,
                            label: Text(InterfaceMode.pro.displayNameArabic),
                            icon: const Icon(Icons.workspace_premium_rounded),
                          ),
                          ButtonSegment<InterfaceMode>(
                            value: InterfaceMode.simple,
                            label: Text(InterfaceMode.simple.displayNameArabic),
                            icon: const Icon(Icons.accessibility_new_rounded),
                          ),
                        ],
                        selected: {currentMode},
                        onSelectionChanged: (selection) {
                          onModeChanged(selection.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Active mode details
              Expanded(
                child: Center(
                  child: Text(
                    'النمط النشط: ${currentMode.displayNameArabic}\n(${currentMode.displayNameEnglish})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1B3B2B),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
