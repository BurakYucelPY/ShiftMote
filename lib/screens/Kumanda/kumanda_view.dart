import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'kumanda.dart';

class KumandaView extends StatelessWidget {
  const KumandaView({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KumandaProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('kumanda'.tr())),
      body: Center(child: Text('${'kumanda'.tr()} #${p.kumandaId}')),
    );
  }
}
