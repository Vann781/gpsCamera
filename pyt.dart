import 'dart:io';

void main() {
  final paths = [
    // root
    'lib',

    // app
    'lib/app',
    'lib/app/app.dart',
    'lib/app/routes.dart',
    'lib/app/theme.dart',

    // core/constants
    'lib/core/constants',
    'lib/core/constants/app_strings.dart',
    'lib/core/constants/colors.dart',

    // core/utils
    'lib/core/utils',
    'lib/core/utils/date_time_util.dart',
    'lib/core/utils/location_util.dart',
    'lib/core/utils/permission_util.dart',

    // core/services
    'lib/core/services',
    'lib/core/services/location_service.dart',
    'lib/core/services/camera_service.dart',
    'lib/core/services/image_overlay_service.dart',
    'lib/core/services/storage_service.dart',

    // features/camera
    'lib/features',
    'lib/features/camera',
    'lib/features/camera/screens',
    'lib/features/camera/screens/camera_screen.dart',
    'lib/features/camera/screens/preview_screen.dart',

    'lib/features/camera/widgets',
    'lib/features/camera/widgets/capture_button.dart',
    'lib/features/camera/widgets/gps_overlay_widget.dart',

    'lib/features/camera/models',
    'lib/features/camera/models/capture_metadata.dart',

    // data
    'lib/data',
    'lib/data/models',
    'lib/data/models/location_model.dart',

    'lib/data/repositories',
    'lib/data/repositories/camera_repository.dart',

    // global widgets
    'lib/widgets',
    'lib/widgets/custom_button.dart',

    // main
    'lib/main.dart',
  ];

  for (final path in paths) {
    if (path.endsWith('.dart')) {
      _createFile(path);
    } else {
      _createDirectory(path);
    }
  }

  print('✅ Project structure generated successfully.');
}

void _createDirectory(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
    print('📁 Created directory: $path');
  }
}

void _createFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    file.createSync(recursive: true);
    file.writeAsStringSync('// $path\n');
    print('📄 Created file: $path');
  }
}
