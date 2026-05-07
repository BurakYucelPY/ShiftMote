import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ir/ir_servis.dart';
import '../theme/app_theme.dart';

/// Kumanda ekranlarinin AppBar'inda gorunen IR durum cipi.
/// - Hazir (gri): donanim var, bekleniyor
/// - Yayinlandi (altin): basarili yayim — 1.5 sn sonra hazira doner
/// - Hata (kirmizi): yayim basarisiz — tikla detay
/// - IR yok (turuncu): donanim algilanmadi — tikla detay
class IrGosterge extends StatefulWidget {
  const IrGosterge({super.key});

  @override
  State<IrGosterge> createState() => _IrGostergeState();
}

class _IrGostergeState extends State<IrGosterge> {
  Timer? _resetTimer;
  IrDurumu _gorunenDurum = IrDurumu.bos;
  String? _gorunenMesaj;

  @override
  void initState() {
    super.initState();
    IrServis.irVarMi();
    _gorunenDurum = IrServis.durum.value.durum;
    _gorunenMesaj = IrServis.durum.value.mesaj;
    IrServis.durum.addListener(_durumDegisti);
  }

  @override
  void dispose() {
    IrServis.durum.removeListener(_durumDegisti);
    _resetTimer?.cancel();
    super.dispose();
  }

  void _durumDegisti() {
    final yeni = IrServis.durum.value;
    if (!mounted) return;
    setState(() {
      _gorunenDurum = yeni.durum;
      _gorunenMesaj = yeni.mesaj;
    });

    _resetTimer?.cancel();
    if (yeni.durum == IrDurumu.yayinlandi) {
      _resetTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _gorunenDurum = IrDurumu.bos;
          _gorunenMesaj = null;
        });
      });
    }
    // Hata durumu kalici — kullanici tiklayip detayini gorebilsin diye
    // otomatik resetlenmez. Sonraki basarili yayim oldugunda silinir.
  }

  Future<void> _detayAc(BuildContext context) async {
    final manuf = Platform.isAndroid ? 'Android' : 'iOS';
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(children: [
          Icon(_gorsel(_gorunenDurum).$1,
              color: _gorsel(_gorunenDurum).$2, size: 20),
          const SizedBox(width: 8),
          const Text('IR Tanı'),
        ]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _satir('Durum', _gorsel(_gorunenDurum).$3),
              _satir('Platform', manuf),
              if (_gorunenMesaj != null && _gorunenMesaj!.isNotEmpty)
                _satir('Mesaj', _gorunenMesaj!),
              const SizedBox(height: 16),
              if (_gorunenDurum == IrDurumu.hata) ...[
                const Text(
                  'Olası nedenler:',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Text(
                  '• Xiaomi/HyperOS bazı sürümlerinde 3rd-party IR\'i sınırlandırıyor\n'
                  '• Sinyal pattern uzunluğu çok büyük olabilir\n'
                  '• Frekans cihaz tarafından desteklenmiyor olabilir',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                ),
              ],
              if (_gorunenDurum == IrDurumu.irYok) ...[
                const Text(
                  'IR donanımı algılanamadı.',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Text(
                  '• Telefonunuzda IR LED olmayabilir\n'
                  '• MIUI/HyperOS izin yönetimi engelliyor olabilir\n'
                  '• Mi Remote çalışıyorsa donanım var, izin sorunu vardır',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Clipboard.setData(
                ClipboardData(text: _gorunenMesaj ?? 'IR durum: $_gorunenDurum')),
            child: const Text('Kopyala'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _satir(String etiket, String deger) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: '$etiket: ',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              TextSpan(
                  text: deger,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontFamily: 'monospace')),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final (ikon, renk, etiket) = _gorsel(_gorunenDurum);
    final hata = _gorunenDurum == IrDurumu.hata ||
        _gorunenDurum == IrDurumu.irYok;
    return GestureDetector(
      onTap: hata ? () => _detayAc(context) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: renk.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: renk.withValues(alpha: 0.35), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, color: renk, size: 14),
            const SizedBox(width: 5),
            Text(
              etiket,
              style: TextStyle(
                color: renk,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            if (hata) ...[
              const SizedBox(width: 4),
              Icon(Icons.info_outline, color: renk, size: 12),
            ],
          ],
        ),
      ),
    );
  }

  (IconData, Color, String) _gorsel(IrDurumu d) {
    switch (d) {
      case IrDurumu.bos:
        return (Icons.sensors_rounded, AppColors.textSecondary, 'IR Hazır');
      case IrDurumu.yayinlandi:
        return (Icons.wifi_tethering_rounded, AppColors.accent, 'Yayınlandı');
      case IrDurumu.hata:
        return (Icons.error_outline_rounded, AppColors.error, 'Hata');
      case IrDurumu.irYok:
        return (Icons.sensors_off_rounded, AppColors.warning, 'IR Yok');
    }
  }
}
