import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'kumanda_ekle_view.dart';

class KumandaEkleProvider extends ChangeNotifier {
  // Aşama 8'de cihaz tipi/marka/model akışı eklenecek
}

class KumandaEkle extends StatefulWidget {
  const KumandaEkle({super.key});

  @override
  State<KumandaEkle> createState() => _KumandaEkleState();
}

class _KumandaEkleState extends State<KumandaEkle> {
  late final KumandaEkleProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = KumandaEkleProvider();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: const KumandaEkleView(),
    );
  }
}
