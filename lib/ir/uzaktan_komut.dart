/// Kullanici arayuzunden gelen "buton tikla" eventlerini, IRDB CSV'sindeki
/// function adlarina (alias listesi ile) eslestirir.
///
/// Tek bir buton birden fazla CSV adina karsilik gelebilir cunku farkli
/// markalar farkli isimlendirme kullanir. Eslestirme onceligi listenin
/// sirasi: ilk eslesen kazanir.
enum TvKomut {
  power,
  volumeUp, volumeDown, mute,
  channelUp, channelDown,
  source, menu, back, ok,
  up, down, left, right,
  num0, num1, num2, num3, num4, num5, num6, num7, num8, num9,
}

enum KlimaKomut {
  power,
  tempUp, tempDown,
  modeCool, modeHeat, modeFan, modeAuto,
  fanLow, fanMedium, fanHigh, fanAuto,
  swingToggle, timerSet,
}

enum ProjektorKomut {
  power,
  volumeUp, volumeDown, mute,
  sourceHdmi, sourceVga, sourceUsb,
  menu, back, ok,
  up, down, left, right,
  zoomIn, zoomOut,
}

class KomutEslestirme {
  static const Map<TvKomut, List<String>> _tv = {
    TvKomut.power: ['KEY_POWER', 'KEY_POWERTOGGLE', 'POWER', 'POWER_ON', 'KEY_POWERON', 'KEY_POWEROFF'],
    TvKomut.volumeUp: ['KEY_VOLUMEUP', 'VOLUME_UP', 'VOL+', 'VOL_UP', 'VOLUMEUP', 'VolumeUp', 'KEY_VOL_UP'],
    TvKomut.volumeDown: ['KEY_VOLUMEDOWN', 'VOLUME_DOWN', 'VOL-', 'VOL_DOWN', 'VOLUMEDOWN', 'VolumeDown', 'KEY_VOL_DOWN'],
    TvKomut.mute: ['KEY_MUTE', 'MUTE', 'KEY_VOLMUTE', 'Mute'],
    TvKomut.channelUp: ['KEY_CHANNELUP', 'CHANNEL_UP', 'CH+', 'CHUP', 'ChannelUp', 'KEY_PROGRAMUP', 'PR+'],
    TvKomut.channelDown: ['KEY_CHANNELDOWN', 'CHANNEL_DOWN', 'CH-', 'CHDOWN', 'ChannelDown', 'KEY_PROGRAMDOWN', 'PR-'],
    TvKomut.source: ['KEY_SOURCE', 'KEY_INPUT', 'SOURCE', 'INPUT', 'AV', 'KEY_AV', 'KEY_TV_INPUT'],
    TvKomut.menu: ['KEY_MENU', 'MENU', 'KEY_HOME', 'HOME'],
    TvKomut.back: ['KEY_BACK', 'KEY_EXIT', 'KEY_RETURN', 'EXIT', 'BACK', 'RETURN'],
    TvKomut.ok: ['KEY_OK', 'OK', 'KEY_ENTER', 'ENTER', 'KEY_SELECT', 'SELECT'],
    TvKomut.up: ['KEY_UP', 'UP', 'KEY_NAVIGATEUP', 'ARROW_UP', 'CursorUp'],
    TvKomut.down: ['KEY_DOWN', 'DOWN', 'KEY_NAVIGATEDOWN', 'ARROW_DOWN', 'CursorDown'],
    TvKomut.left: ['KEY_LEFT', 'LEFT', 'KEY_NAVIGATELEFT', 'ARROW_LEFT', 'CursorLeft'],
    TvKomut.right: ['KEY_RIGHT', 'RIGHT', 'KEY_NAVIGATERIGHT', 'ARROW_RIGHT', 'CursorRight'],
    TvKomut.num0: ['KEY_0', 'KEY_NUMERIC_0', '0', 'Number_0'],
    TvKomut.num1: ['KEY_1', 'KEY_NUMERIC_1', '1', 'Number_1'],
    TvKomut.num2: ['KEY_2', 'KEY_NUMERIC_2', '2', 'Number_2'],
    TvKomut.num3: ['KEY_3', 'KEY_NUMERIC_3', '3', 'Number_3'],
    TvKomut.num4: ['KEY_4', 'KEY_NUMERIC_4', '4', 'Number_4'],
    TvKomut.num5: ['KEY_5', 'KEY_NUMERIC_5', '5', 'Number_5'],
    TvKomut.num6: ['KEY_6', 'KEY_NUMERIC_6', '6', 'Number_6'],
    TvKomut.num7: ['KEY_7', 'KEY_NUMERIC_7', '7', 'Number_7'],
    TvKomut.num8: ['KEY_8', 'KEY_NUMERIC_8', '8', 'Number_8'],
    TvKomut.num9: ['KEY_9', 'KEY_NUMERIC_9', '9', 'Number_9'],
  };

  static const Map<KlimaKomut, List<String>> _klima = {
    KlimaKomut.power: ['KEY_POWER', 'POWER', 'KEY_POWERON', 'KEY_POWEROFF', 'KEY_POWERTOGGLE'],
    KlimaKomut.tempUp: ['KEY_TEMPUP', 'TEMP_UP', 'TEMP+', 'TEMPERATUREUP', 'KEY_TEMPERATUREUP'],
    KlimaKomut.tempDown: ['KEY_TEMPDOWN', 'TEMP_DOWN', 'TEMP-', 'TEMPERATUREDOWN', 'KEY_TEMPERATUREDOWN'],
    KlimaKomut.modeCool: ['KEY_MODE_COOL', 'COOL', 'COOLING', 'KEY_COOL'],
    KlimaKomut.modeHeat: ['KEY_MODE_HEAT', 'HEAT', 'HEATING', 'KEY_HEAT'],
    KlimaKomut.modeFan: ['KEY_MODE_FAN', 'FAN', 'KEY_FAN', 'FANONLY'],
    KlimaKomut.modeAuto: ['KEY_MODE_AUTO', 'AUTO', 'KEY_AUTO', 'AUTOMODE'],
    KlimaKomut.fanLow: ['KEY_FAN_LOW', 'FAN_LOW', 'FAN1', 'LOW'],
    KlimaKomut.fanMedium: ['KEY_FAN_MEDIUM', 'FAN_MEDIUM', 'FAN2', 'MED', 'MEDIUM'],
    KlimaKomut.fanHigh: ['KEY_FAN_HIGH', 'FAN_HIGH', 'FAN3', 'HIGH'],
    KlimaKomut.fanAuto: ['KEY_FAN_AUTO', 'FAN_AUTO', 'FANAUTO'],
    KlimaKomut.swingToggle: ['KEY_SWING', 'SWING', 'KEY_SWING_VERTICAL', 'OSCILLATE'],
    KlimaKomut.timerSet: ['KEY_TIMER', 'TIMER', 'KEY_SLEEP', 'SLEEP'],
  };

  static const Map<ProjektorKomut, List<String>> _projektor = {
    ProjektorKomut.power: [
      'KEY_POWER', 'POWER', 'KEY_POWERON', 'KEY_POWEROFF', 'KEY_POWERTOGGLE',
      'ON', 'OFF', 'POWER ON', 'POWER OFF',
    ],
    ProjektorKomut.volumeUp: [
      'KEY_VOLUMEUP', 'VOLUME_UP', 'VOL+', 'VOL_UP', 'VOLUMEUP',
      'VOLUME +', 'VOLUME+', 'VOL +', 'VOLUME UP',
    ],
    ProjektorKomut.volumeDown: [
      'KEY_VOLUMEDOWN', 'VOLUME_DOWN', 'VOL-', 'VOL_DOWN', 'VOLUMEDOWN',
      'VOLUME -', 'VOLUME-', 'VOL -', 'VOLUME DOWN',
    ],
    ProjektorKomut.mute: [
      'KEY_MUTE', 'MUTE', 'KEY_VOLMUTE',
      'A/V MUTE', 'A/V_MUTE', 'AV MUTE', 'AVMUTE', 'BLANK',
      'PIC MUTE', 'PICTURE MUTE', 'VIDEO MUTE', 'MUTING',
      'PIC_MUTE', 'AV_MUTE', 'A.V.MUTE',
    ],
    ProjektorKomut.sourceHdmi: [
      'KEY_SOURCE_HDMI', 'HDMI', 'KEY_HDMI', 'INPUT_HDMI',
      'HDMI 1', 'HDMI1', 'HDMI 2', 'HDMI2', 'INPUT HDMI',
    ],
    ProjektorKomut.sourceVga: [
      'KEY_SOURCE_VGA', 'VGA', 'KEY_VGA', 'KEY_COMPUTER', 'COMPUTER',
      'INPUT_VGA', 'PC', 'SOURCE INPUT B', 'INPUT B', 'SOURCE INPUT A', 'INPUT A',
    ],
    ProjektorKomut.sourceUsb: [
      'KEY_SOURCE_USB', 'USB', 'KEY_USB', 'INPUT_USB', 'INPUT USB',
    ],
    ProjektorKomut.menu: ['KEY_MENU', 'MENU'],
    ProjektorKomut.back: [
      'KEY_BACK', 'KEY_EXIT', 'KEY_RETURN', 'BACK', 'EXIT', 'RETURN',
      'ESC', 'ESCAPE', 'KEY_ESC',
    ],
    ProjektorKomut.ok: [
      'KEY_OK', 'OK', 'KEY_ENTER', 'ENTER', 'SELECT', 'CURSOR ENTER',
    ],
    ProjektorKomut.up: [
      'KEY_UP', 'UP', 'CursorUp', 'CURSOR UP', 'CURSOR_UP', 'ARROW_UP',
    ],
    ProjektorKomut.down: [
      'KEY_DOWN', 'DOWN', 'CursorDown', 'CURSOR DOWN', 'CURSOR_DOWN', 'ARROW_DOWN',
    ],
    ProjektorKomut.left: [
      'KEY_LEFT', 'LEFT', 'CursorLeft', 'CURSOR LEFT', 'CURSOR_LEFT', 'ARROW_LEFT',
    ],
    ProjektorKomut.right: [
      'KEY_RIGHT', 'RIGHT', 'CursorRight', 'CURSOR RIGHT', 'CURSOR_RIGHT',
      'CURSER RIGHT', 'CURSER_RIGHT', 'ARROW_RIGHT', '>',
    ],
    ProjektorKomut.zoomIn: [
      'KEY_ZOOMIN', 'ZOOM_IN', 'ZOOMIN', 'KEY_ZOOM_IN',
      'ZOOM', 'KEY_ZOOM', // Epson projektorlerinde tek ZOOM butonu var
      'ZOOM +', 'ZOOM+', 'TELE', 'KEY_TELE',
      'PICTURE_SIZE', 'PIC_SIZE', 'WIDE_ZOOM',
    ],
    ProjektorKomut.zoomOut: [
      'KEY_ZOOMOUT', 'ZOOM_OUT', 'ZOOMOUT', 'KEY_ZOOM_OUT',
      'FOCUS', 'KEY_FOCUS', // Epson'da zoom out yok, focus daha yakin
      'ZOOM -', 'ZOOM-', 'WIDE', 'KEY_WIDE',
      'D.ZOOM', 'D ZOOM', 'DIGITAL_ZOOM',
    ],
  };

  static List<String> tvAlias(TvKomut k) => _tv[k] ?? const [];
  static List<String> klimaAlias(KlimaKomut k) => _klima[k] ?? const [];
  static List<String> projektorAlias(ProjektorKomut k) => _projektor[k] ?? const [];
}
