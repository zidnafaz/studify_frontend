import 'dart:io';
import 'package:yaml/yaml.dart';

void main() {
  final pubspecFile = File('pubspec.yaml');
  final versionJsonFile = File('web/version.json');

  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final yaml = loadYaml(pubspecContent);

  final versionFull = yaml['version'] as String;
  final versionParts = versionFull.split('+');
  final version = versionParts[0];
  final buildNumber = versionParts.length > 1 ? versionParts[1] : '1';
  final appName = yaml['name'] as String;

  final jsonContent = '''
{
  "app_name": "$appName",
  "version": "$version",
  "build_number": "$buildNumber",
  "package_name": "$appName"
}
''';

  versionJsonFile.writeAsStringSync(jsonContent);
  print('web/version.json generated successfully: $versionFull');
}
