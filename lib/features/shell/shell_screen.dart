import 'package:flutter/material.dart';

import '../assistant/assistant_screen.dart';
import '../case/case_controller.dart';
import '../certificate/certificate_screen.dart';
import '../documents/documents_screen.dart';
import '../home/home_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  ShellScreenState createState() => ShellScreenState();
}

class ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  void switchTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final hindi = SambalScope.of(context).isHindi;

    String t(String hi, String en) => hindi ? hi : en;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          CertificateScreen(),
          DocumentsScreen(),
          AssistantScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: t('होम', 'Home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.description_outlined),
            selectedIcon: const Icon(Icons.description_rounded),
            label: t('प्रमाणपत्र', 'Certificate'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder_rounded),
            label: t('दस्तावेज़', 'Documents'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble_rounded),
            label: t('सहायक', 'Assistant'),
          ),
        ],
      ),
    );
  }
}
