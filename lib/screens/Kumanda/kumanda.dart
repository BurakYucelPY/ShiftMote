import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'kumanda_view.dart';

class KumandaProvider extends ChangeNotifier {
  final int kumandaId;
  KumandaProvider({required this.kumandaId});

  // Aşama 9'da entity yükleme + IR yayım eklenecek
}

class Kumanda extends StatefulWidget {
  final int kumandaId;
  const Kumanda({super.key, required this.kumandaId});

  @override
  State<Kumanda> createState() => _KumandaState();
}

class _KumandaState extends State<Kumanda> {
  late final KumandaProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = KumandaProvider(kumandaId: widget.kumandaId);
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
      child: const KumandaView(),
    );
  }
}
