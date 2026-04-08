import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelInfo {
  final String code;
  final String name;
  final String bundledPath;
  final String? importedPath;

  const ModelInfo({
    required this.code,
    required this.name,
    required this.bundledPath,
    this.importedPath,
  });

  bool get hasImportedModel => importedPath != null && importedPath!.isNotEmpty;
}

class ModelStorageService {
  ModelStorageService._();
  static final ModelStorageService instance = ModelStorageService._();

  static const _modelPathPrefix = 'speech_model_path_';

  static const supportedLanguages = [
    {'code': 'en', 'name': 'English', 'path': 'assets/models/en'},
    {'code': 'ta', 'name': 'Tamil', 'path': 'assets/models/ta'},
  ];

  Future<List<ModelInfo>> listModels() async {
    final prefs = await SharedPreferences.getInstance();
    return supportedLanguages
        .map(
          (lang) => ModelInfo(
            code: lang['code']!,
            name: lang['name']!,
            bundledPath: lang['path']!,
            importedPath: prefs.getString('$_modelPathPrefix${lang['code']}'),
          ),
        )
        .toList();
  }

  Future<void> clearImportedModel(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPath = prefs.getString('$_modelPathPrefix$languageCode');
    if (!kIsWeb && currentPath != null && currentPath.isNotEmpty) {
      final file = File(currentPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await prefs.remove('$_modelPathPrefix$languageCode');
  }

  Future<String?> importModel(String languageCode) async {
    if (kIsWeb) {
      return null;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['gguf'],
      allowMultiple: false,
    );

    final file = result?.files.single;
    if (file == null || file.path == null) {
      return null;
    }

    final supportDir = await getApplicationSupportDirectory();
    final modelDir = Directory(p.join(supportDir.path, 'speech_models'));
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }

    final targetPath = p.join(modelDir.path, '${languageCode}_${file.name}');
    await File(file.path!).copy(targetPath);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_modelPathPrefix$languageCode', targetPath);
    return targetPath;
  }
}
