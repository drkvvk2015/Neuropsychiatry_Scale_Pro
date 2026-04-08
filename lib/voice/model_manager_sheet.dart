import 'package:flutter/material.dart';

import '../l10n/app_localizations_ext.dart';
import '../services/model_storage_service.dart';

Future<void> showModelManagerSheet(BuildContext context) async {
  final l10n = AppLocalizationsExt.of(context);
  final messenger = ScaffoldMessenger.of(context);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> refresh() async {
            setState(() {});
          }

          return FutureBuilder<List<ModelInfo>>(
            future: ModelStorageService.instance.listModels(),
            builder: (context, snapshot) {
              final models = snapshot.data ?? const <ModelInfo>[];
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.modelManager,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.modelManagerHint,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (models.isEmpty) ...[
                        const SizedBox(height: 16),
                        const Center(child: CircularProgressIndicator()),
                      ] else ...[
                        const SizedBox(height: 16),
                        ...models.map(
                          (model) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text('${l10n.bundledModel}: ${model.bundledPath}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    model.hasImportedModel
                                        ? '${l10n.importedModel}: ${model.importedPath}'
                                        : '${l10n.importedModel}: -',
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          if (Theme.of(context).platform == TargetPlatform.android ||
                                              Theme.of(context).platform == TargetPlatform.iOS ||
                                              Theme.of(context).platform == TargetPlatform.macOS ||
                                              Theme.of(context).platform == TargetPlatform.windows ||
                                              Theme.of(context).platform == TargetPlatform.linux) {
                                            try {
                                              final importedPath = await ModelStorageService.instance.importModel(model.code);
                                              if (importedPath == null) {
                                                return;
                                              }
                                              await refresh();
                                              messenger.showSnackBar(
                                                SnackBar(content: Text(l10n.modelImportSuccess(model.name))),
                                              );
                                            } catch (error) {
                                              messenger.showSnackBar(
                                                SnackBar(content: Text(l10n.modelImportFailed('$error'))),
                                              );
                                            }
                                          } else {
                                            messenger.showSnackBar(
                                              SnackBar(content: Text(l10n.importNotSupportedWeb)),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.upload_file),
                                        label: Text(l10n.importModel),
                                      ),
                                      if (model.hasImportedModel)
                                        OutlinedButton.icon(
                                          onPressed: () async {
                                            await ModelStorageService.instance.clearImportedModel(model.code);
                                            await refresh();
                                          },
                                          icon: const Icon(Icons.delete_outline),
                                          label: Text(l10n.clearModel),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
