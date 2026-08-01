import 'package:china_city_selector/map_china_areas.dart';

final class ChinaRegionNode {
  const ChinaRegionNode({
    required this.code,
    required this.name,
    required this.children,
  });

  final String code;
  final String name;
  final List<ChinaRegionNode> children;
}

abstract final class ChinaRegions {
  static final List<ChinaRegionNode> provinces = _build();

  static String? findBestPath(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), '');
    ChinaRegionNode? bestProvince;
    ChinaRegionNode? bestCity;
    ChinaRegionNode? bestDistrict;
    for (final province in provinces) {
      final provinceHit =
          normalized.contains(province.name) ||
          normalized.contains(_shortName(province.name));
      for (final city in province.children) {
        final cityHit =
            normalized.contains(city.name) ||
            normalized.contains(_shortName(city.name));
        for (final district in city.children) {
          final districtHit =
              normalized.contains(district.name) ||
              normalized.contains(_shortName(district.name));
          if (districtHit && (cityHit || provinceHit)) {
            bestProvince = province;
            bestCity = city;
            bestDistrict = district;
            break;
          }
        }
        if (bestDistrict != null) break;
        if (cityHit && bestCity == null) {
          bestProvince = province;
          bestCity = city;
        }
      }
      if (bestDistrict != null) break;
      if (provinceHit && bestProvince == null) bestProvince = province;
    }
    if (bestProvince == null) return null;
    return <String>[
      bestProvince.name,
      if (bestCity != null) bestCity.name,
      if (bestDistrict != null) bestDistrict.name,
    ].join(' / ');
  }

  static List<ChinaRegionNode> _build() {
    final provinceNames = <String, String>{};
    final cityNames = <String, String>{};
    final districtNames = <String, String>{};
    for (final entry in mapChinaAreas.entries) {
      final code = int.tryParse(entry.key);
      if (code == null || entry.key.length != 6) continue;
      if (code % 10000 == 0) {
        provinceNames[entry.key] = entry.value;
      } else if (code % 100 == 0) {
        cityNames[entry.key] = entry.value;
      } else {
        districtNames[entry.key] = entry.value;
      }
    }

    final result = <ChinaRegionNode>[];
    final sortedProvinces = provinceNames.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final province in sortedProvinces) {
      final provincePrefix = province.key.substring(0, 2);
      final localCities = <String, String>{
        for (final city in cityNames.entries)
          if (city.key.startsWith(provincePrefix)) city.key: city.value,
      };
      for (final district in districtNames.entries) {
        if (!district.key.startsWith(provincePrefix)) continue;
        final cityCode = '${district.key.substring(0, 4)}00';
        localCities.putIfAbsent(
          cityCode,
          () => _syntheticCityName(province.value, cityCode),
        );
      }

      final children = <ChinaRegionNode>[];
      final sortedCities = localCities.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      for (final city in sortedCities) {
        final districtPrefix = city.key.substring(0, 4);
        final districts = <ChinaRegionNode>[
          for (final district in districtNames.entries)
            if (district.key.startsWith(districtPrefix))
              ChinaRegionNode(
                code: district.key,
                name: district.value,
                children: const <ChinaRegionNode>[],
              ),
        ]..sort((a, b) => a.code.compareTo(b.code));
        if (districts.isEmpty) {
          districts.add(
            ChinaRegionNode(
              code: '${city.key.substring(0, 4)}99',
              name: '全市',
              children: const <ChinaRegionNode>[],
            ),
          );
        }
        children.add(
          ChinaRegionNode(
            code: city.key,
            name: city.value,
            children: districts,
          ),
        );
      }
      result.add(
        ChinaRegionNode(
          code: province.key,
          name: province.value,
          children: children,
        ),
      );
    }
    return List<ChinaRegionNode>.unmodifiable(result);
  }

  static String _syntheticCityName(String provinceName, String cityCode) {
    if (<String>{'11', '12', '31', '50'}.contains(cityCode.substring(0, 2))) {
      return provinceName;
    }
    return '省直辖县级行政区划';
  }

  static String _shortName(String value) => value.replaceAll(
    RegExp(r'(特别行政区|维吾尔自治区|壮族自治区|回族自治区|自治区|自治州|地区|省|市|区|县)$'),
    '',
  );
}
