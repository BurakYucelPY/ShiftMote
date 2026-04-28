import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../app_drawer.dart';

class HakkindaView extends StatelessWidget {
  const HakkindaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => AppDrawer.open(),
        ),
        title: Text('hakkinda'.tr()),
      ),
      body: Center(child: Text('hakkinda'.tr())),
    );
  }
}
