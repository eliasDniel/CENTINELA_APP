// RF-0304, RF-0305, RF-0307: Home screen
import 'package:flutter/material.dart';

import '../providers/sos_provider.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/home_location_card_widget.dart';
import '../widgets/home_sos_section_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeaderWidget(),
            HomeSosSectionWidget(
              onEmergencySent: () => handleSosSent(context),
            ),
            const HomeLocationCardWidget(),
          ],
        ),
      ),
    );
  }
}
