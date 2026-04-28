import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DilView extends StatelessWidget {
  const DilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('dil'.tr())),
      body: Center(child: Text('dil'.tr())),
    );
  }
}
