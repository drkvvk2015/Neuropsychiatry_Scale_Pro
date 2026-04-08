import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<void> exportCsv(String csv, String fileName, {String? shareSubject}) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], subject: shareSubject);
  }
}
