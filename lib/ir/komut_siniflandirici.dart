import 'irdb_parser.dart';

/// IRDB CSV'sindeki function isimlerini anlamli gruplara ayirir.
/// Marka basina farkli isimlendirme oldugu icin alias listeleri kullanilir.
class SiniflandirilmisKomutlar {
  final IrKomut? power, mute;
  final IrKomut? volumeUp, volumeDown;
  final IrKomut? channelUp, channelDown;
  final IrKomut? up, down, left, right, ok;
  final IrKomut? menu, home, back, exit, info;
  final IrKomut? play, pause, stop, record, rewind, forward, next, prev, eject;
  final IrKomut? red, green, yellow, blue;
  final IrKomut? source;
  // Fan / klima / aydinlatma extralar
  final IrKomut? oscillation, timer, light, speed, fanMode, sleep;
  final List<IrKomut> sayilar; // 0..9 (yalnizca CSV'de varsa)
  final List<KaynakDugmesi> kaynaklar; // HDMI/VGA/AV vs.
  final List<IrKomut> kalan; // siniflandirilmamis

  const SiniflandirilmisKomutlar({
    this.power,
    this.mute,
    this.volumeUp,
    this.volumeDown,
    this.channelUp,
    this.channelDown,
    this.up,
    this.down,
    this.left,
    this.right,
    this.ok,
    this.menu,
    this.home,
    this.back,
    this.exit,
    this.info,
    this.play,
    this.pause,
    this.stop,
    this.record,
    this.rewind,
    this.forward,
    this.next,
    this.prev,
    this.eject,
    this.red,
    this.green,
    this.yellow,
    this.blue,
    this.source,
    this.oscillation,
    this.timer,
    this.light,
    this.speed,
    this.fanMode,
    this.sleep,
    this.sayilar = const [],
    this.kaynaklar = const [],
    this.kalan = const [],
  });

  bool get fanEkstraVar =>
      oscillation != null ||
      timer != null ||
      light != null ||
      speed != null ||
      fanMode != null ||
      sleep != null;

  bool get sesVar => mute != null || volumeUp != null || volumeDown != null;
  bool get kanalVar => channelUp != null || channelDown != null;
  bool get dpadVar =>
      up != null ||
      down != null ||
      left != null ||
      right != null ||
      ok != null;
  bool get sayiVar => sayilar.isNotEmpty;
  bool get oynatmaVar =>
      play != null ||
      pause != null ||
      stop != null ||
      record != null ||
      rewind != null ||
      forward != null ||
      next != null ||
      prev != null;
  bool get renkVar =>
      red != null || green != null || yellow != null || blue != null;
  bool get menuVar =>
      menu != null ||
      home != null ||
      back != null ||
      exit != null ||
      info != null;
  bool get kaynakVar => kaynaklar.isNotEmpty || source != null;

  static SiniflandirilmisKomutlar olustur(List<IrKomut> komutlar) {
    IrKomut? bul(List<String> aliaslar) {
      for (final a in aliaslar) {
        final hedef = a.toLowerCase();
        for (final k in komutlar) {
          if (k.ad.toLowerCase() == hedef) return k;
        }
      }
      return null;
    }

    // Sayilar: KEY_0..KEY_9, KEY_NUMERIC_0..9, Number_0..9, ya da duz '0'..'9'
    final sayilar = <IrKomut>[];
    for (var i = 0; i <= 9; i++) {
      final n = bul([
        'KEY_$i',
        'KEY_NUMERIC_$i',
        '$i',
        'Number_$i',
        'KEY_$i'.toUpperCase(),
      ]);
      if (n != null) sayilar.add(n);
    }

    // Kaynaklar
    final kaynaklarRegex = RegExp(
        r'^(KEY_)?(SOURCE_)?(HDMI|VGA|AV|USB|COMPONENT|COMPOSITE|TV|DVD|DTV|ANALOG|DIGITAL|VIDEO[0-9]?|HDMI[0-9]|AUX|YPBPR|RGB|SCART|BLUETOOTH|BT|PHONO|TUNER|CD|TAPE|RADIO|FM|AM|LINE)([0-9]+)?$',
        caseSensitive: false);
    final kaynaklar = <KaynakDugmesi>[];

    final tumKomutAdlari = komutlar.map((k) => k.ad).toSet();

    for (final k in komutlar) {
      final m = kaynaklarRegex.firstMatch(k.ad);
      if (m != null) {
        // Power/SourceUp gibi aksiyonlari haricinde tut
        final ad = k.ad.toUpperCase();
        if (!ad.contains('UP') &&
            !ad.contains('DOWN') &&
            !ad.contains('TOGGLE')) {
          final etiket = k.ad
              .replaceAll(RegExp(r'^KEY_', caseSensitive: false), '')
              .replaceAll(RegExp(r'^SOURCE_', caseSensitive: false), '')
              .replaceAll('_', ' ');
          kaynaklar.add(KaynakDugmesi(etiket: etiket, komut: k));
        }
      }
    }

    final power = bul([
      'KEY_POWER',
      'POWER',
      'KEY_POWERTOGGLE',
      'KEY_POWERON',
      'KEY_POWEROFF',
      'POWER_ON',
      'POWER_OFF',
      'SHUTDOWN',
      'ON_OFF',
      'ONOFF',
      'STANDBY',
      'KEY_STANDBY',
      'PWR'
    ]);
    final oscillation = bul([
      'OSCILLATION',
      'OSCILLATE',
      'KEY_SWING',
      'SWING',
      'SWING_TOGGLE',
      'KEY_SWING_VERTICAL'
    ]);
    final timer =
        bul(['TIMER', 'KEY_TIMER', 'TIMER_SET', 'KEY_SLEEP_TIMER']);
    final light = bul(
        ['LIGHT', 'KEY_LIGHT', 'LAMP', 'KEY_LAMP', 'BACKLIGHT', 'LED']);
    final speed = bul([
      'SPEED',
      'KEY_SPEED',
      'FAN_SPEED',
      'KEY_FAN_SPEED',
      'FAN'
    ]);
    final fanMode = bul([
      'FAN MODE',
      'FAN_MODE',
      'KEY_MODE',
      'MODE',
      'PRESET',
      'PRESETS'
    ]);
    final sleep = bul(['SLEEP', 'KEY_SLEEP', 'NIGHT', 'KEY_NIGHT']);
    final mute = bul(['KEY_MUTE', 'MUTE', 'KEY_VOLMUTE', 'Mute']);
    final volumeUp = bul([
      'KEY_VOLUMEUP',
      'VOLUME_UP',
      'VOL+',
      'VOL_UP',
      'VOLUMEUP',
      'VolumeUp',
      'KEY_VOL_UP'
    ]);
    final volumeDown = bul([
      'KEY_VOLUMEDOWN',
      'VOLUME_DOWN',
      'VOL-',
      'VOL_DOWN',
      'VOLUMEDOWN',
      'VolumeDown',
      'KEY_VOL_DOWN'
    ]);
    final channelUp = bul([
      'KEY_CHANNELUP',
      'CHANNEL_UP',
      'CH+',
      'CHUP',
      'ChannelUp',
      'KEY_PROGRAMUP',
      'PR+'
    ]);
    final channelDown = bul([
      'KEY_CHANNELDOWN',
      'CHANNEL_DOWN',
      'CH-',
      'CHDOWN',
      'ChannelDown',
      'KEY_PROGRAMDOWN',
      'PR-'
    ]);
    final up = bul(
        ['KEY_UP', 'UP', 'KEY_NAVIGATEUP', 'ARROW_UP', 'CursorUp', 'NAV_UP']);
    final down = bul([
      'KEY_DOWN',
      'DOWN',
      'KEY_NAVIGATEDOWN',
      'ARROW_DOWN',
      'CursorDown',
      'NAV_DOWN'
    ]);
    final left = bul([
      'KEY_LEFT',
      'LEFT',
      'KEY_NAVIGATELEFT',
      'ARROW_LEFT',
      'CursorLeft',
      'NAV_LEFT'
    ]);
    final right = bul([
      'KEY_RIGHT',
      'RIGHT',
      'KEY_NAVIGATERIGHT',
      'ARROW_RIGHT',
      'CursorRight',
      'NAV_RIGHT'
    ]);
    final ok = bul([
      'KEY_OK',
      'OK',
      'KEY_ENTER',
      'ENTER',
      'KEY_SELECT',
      'SELECT',
      'KEY_NAVIGATEENTER'
    ]);
    final menu = bul(['KEY_MENU', 'MENU', 'KEY_SYSTEM_MENU']);
    final home = bul(['KEY_HOME', 'HOME', 'KEY_HOMEPAGE']);
    final back = bul(
        ['KEY_BACK', 'BACK', 'KEY_RETURN', 'RETURN', 'KEY_PREVIOUSMENU']);
    final exit = bul(['KEY_EXIT', 'EXIT', 'KEY_CANCEL', 'CANCEL']);
    final info = bul([
      'KEY_INFO',
      'INFO',
      'KEY_DISPLAY',
      'DISPLAY',
      'KEY_GUIDE',
      'GUIDE'
    ]);
    final play = bul(['KEY_PLAY', 'PLAY']);
    final pause = bul(['KEY_PAUSE', 'PAUSE', 'KEY_PLAYPAUSE']);
    final stop = bul(['KEY_STOP', 'STOP']);
    final record = bul(['KEY_RECORD', 'RECORD', 'REC']);
    final rewind = bul(
        ['KEY_REWIND', 'REWIND', 'REW', 'KEY_PREVIOUSSONG_REWIND']);
    final forward = bul([
      'KEY_FASTFORWARD',
      'KEY_FORWARD',
      'FFWD',
      'FF',
      'FAST_FORWARD',
      'FASTFORWARD',
      'FORWARD'
    ]);
    final next = bul(
        ['KEY_NEXT', 'NEXT', 'KEY_NEXTSONG', 'KEY_SKIPNEXT', 'SKIP_NEXT']);
    final prev = bul([
      'KEY_PREVIOUS',
      'PREV',
      'PREVIOUS',
      'KEY_PREVIOUSSONG',
      'KEY_SKIPPREVIOUS',
      'SKIP_PREVIOUS'
    ]);
    final eject = bul(['KEY_EJECT', 'EJECT', 'KEY_OPEN', 'OPEN', 'OPEN_CLOSE']);
    final red = bul(['KEY_RED', 'RED', 'F_RED']);
    final green = bul(['KEY_GREEN', 'GREEN', 'F_GREEN']);
    final yellow = bul(['KEY_YELLOW', 'YELLOW', 'F_YELLOW']);
    final blue = bul(['KEY_BLUE', 'BLUE', 'F_BLUE']);
    final source = bul([
      'KEY_SOURCE',
      'KEY_INPUT',
      'SOURCE',
      'INPUT',
      'KEY_TV_INPUT',
      'KEY_TUNER'
    ]);

    // Kalan: yukaridaki hicbir slota girmeyenler
    final kullanilan = <String>{};
    for (final k in [
      power,
      mute,
      volumeUp,
      volumeDown,
      channelUp,
      channelDown,
      up,
      down,
      left,
      right,
      ok,
      menu,
      home,
      back,
      exit,
      info,
      play,
      pause,
      stop,
      record,
      rewind,
      forward,
      next,
      prev,
      eject,
      red,
      green,
      yellow,
      blue,
      source,
      oscillation,
      timer,
      light,
      speed,
      fanMode,
      sleep,
      ...sayilar,
      ...kaynaklar.map((k) => k.komut),
    ]) {
      if (k != null) kullanilan.add(k.ad);
    }

    final kalan =
        komutlar.where((k) => !kullanilan.contains(k.ad)).toList();

    // Cok uzun command isimleri varsa bile minimum filtrele
    // (yine de hepsi 'Diger' gridinde gorunsun)
    tumKomutAdlari.length; // unused warning bastir

    return SiniflandirilmisKomutlar(
      power: power,
      mute: mute,
      volumeUp: volumeUp,
      volumeDown: volumeDown,
      channelUp: channelUp,
      channelDown: channelDown,
      up: up,
      down: down,
      left: left,
      right: right,
      ok: ok,
      menu: menu,
      home: home,
      back: back,
      exit: exit,
      info: info,
      play: play,
      pause: pause,
      stop: stop,
      record: record,
      rewind: rewind,
      forward: forward,
      next: next,
      prev: prev,
      eject: eject,
      red: red,
      green: green,
      yellow: yellow,
      blue: blue,
      source: source,
      oscillation: oscillation,
      timer: timer,
      light: light,
      speed: speed,
      fanMode: fanMode,
      sleep: sleep,
      sayilar: sayilar,
      kaynaklar: kaynaklar,
      kalan: kalan,
    );
  }
}

class KaynakDugmesi {
  final String etiket;
  final IrKomut komut;
  const KaynakDugmesi({required this.etiket, required this.komut});
}
