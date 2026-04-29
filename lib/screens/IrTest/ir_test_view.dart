import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ir_test.dart';

class IrTestView extends StatelessWidget {
  const IrTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IR Test')),
      body: Consumer<IrTestProvider>(
        builder: (context, p, _) {
          if (p.yukleniyor) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(
                      p.irVar ? Icons.check_circle : Icons.cancel,
                      color: p.irVar ? Colors.green : Colors.red,
                    ),
                    title: Text(p.irVar ? 'IR Var' : 'IR Yok'),
                    subtitle: Text(p.sonMesaj),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: p.irVar ? () => p.samsungPowerYay() : null,
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('Samsung TV Power (sabit)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: p.irVar ? () => p.parserYoluylaYay() : null,
                  icon: const Icon(Icons.dataset),
                  label: const Text('Samsung TV Power (irdb parser)'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Telefonu TV\'ye dogrult. Iki buton da TV\'yi acmali/kapamalidir.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
