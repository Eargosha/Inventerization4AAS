abstract class AppConstants {
  static const String baseAPIUrl = 'http://10.104.224.75/flutter_api/';

    // Значения по умолчанию для типов этикеток
  static const Map<String, Map<String, String>> labelTypeDefaults = {
    'Обычная': {
      'length': '34',
      'width': '54',
      'antennaX': '10',
      'antennaY': '4',
      'powerWrite': '14',
      'powerRead': '13',
      'offset': '0',
      'stepSize': '38.375',
      'selectedAntennaPlacement': 'false',
    },
    'Металлическая': {
      'length': '30',
      'width': '70',
      'antennaX': '14',
      'antennaY': '3',
      'powerWrite': '16',
      'powerRead': '14',
      'offset': '0',
      'stepSize': '38.25',
      'selectedAntennaPlacement': 'true',
    },
  };

}