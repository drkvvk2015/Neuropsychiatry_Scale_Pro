import 'package:flutter_test/flutter_test.dart';

import 'package:neuroscale_pro/core/models/scale_model.dart';
import 'package:neuroscale_pro/core/services/scale_definitions.dart';

void main() {
  test('new psychiatric scales are registered in definitions', () {
    final scales = ScaleDefinitions.allScales;

    expect(scales[ScaleType.hads]?.items.length, 14);
    expect(scales[ScaleType.mdq]?.items.length, 15);
    expect(scales[ScaleType.cows]?.items.length, 11);
    expect(scales[ScaleType.epds]?.items.length, 10);
    expect(scales[ScaleType.gds]?.items.length, 15);
  });
}
