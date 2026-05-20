import 'dart:math';
import 'package:args/args.dart';

const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _lower = 'abcdefghijklmnopqrstuvwxyz';
const _digits = '0123456789';
const _symbols = r'!@#$%^&*()_+-=[]{}|;:,.<>?';

String generatePassword({
  required int length,
  bool useUpper = true,
  bool useLower = true,
  bool useDigits = true,
  bool useSymbols = true,
}) {
  final charset = StringBuffer();
  final required = <String>[];
  if (useUpper) { charset.write(_upper); required.add(_upper); }
  if (useLower) { charset.write(_lower); required.add(_lower); }
  if (useDigits) { charset.write(_digits); required.add(_digits); }
  if (useSymbols) { charset.write(_symbols); required.add(_symbols); }
  if (charset.isEmpty) throw ArgumentError('At least one character set required');
  final chars = charset.toString();
  final rng = Random.secure();
  final password = List.generate(length, (_) => chars[rng.nextInt(chars.length)]);
  for (var i = 0; i < required.length && i < length; i++) {
    final set = required[i];
    final pos = rng.nextInt(length);
    if (!set.contains(password[pos])) {
      password[i % length] = set[rng.nextInt(set.length)];
    }
  }
  return password.join();
}

double scoreStrength(String password) {
  final len = password.length;
  final pool = <String>{};
  if (password.contains(RegExp(r'[a-z]'))) pool.addAll(_lower.split(''));
  if (password.contains(RegExp(r'[A-Z]'))) pool.addAll(_upper.split(''));
  if (password.contains(RegExp(r'[0-9]'))) pool.addAll(_digits.split(''));
  if (password.contains(RegExp(r'[!@#$%^&*()_\+\-=\[\]{}|;:,.<>?]'))) {
    pool.addAll(_symbols.split(''));
  }
  if (pool.isEmpty) return 0.0;
  final entropy = len * log(pool.length) / ln2;
  return (entropy / 128.0).clamp(0.0, 1.0);
}

String strengthLabel(double score) =>
    switch (score) { < 0.3 => 'WEAK', < 0.6 => 'FAIR', < 0.85 => 'STRONG', _ => 'VERY STRONG' };

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('length', abbr: 'l', defaultsTo: '16', help: 'Password length')
    ..addOption('count', abbr: 'n', defaultsTo: '1', help: 'Number of passwords')
    ..addFlag('no-upper', negatable: false, help: 'Exclude uppercase')
    ..addFlag('no-lower', negatable: false, help: 'Exclude lowercase')
    ..addFlag('no-digits', negatable: false, help: 'Exclude digits')
    ..addFlag('no-symbols', negatable: false, help: 'Exclude symbols')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage');
  final result = parser.parse(args);
  if (result['help'] as bool) {
    print('Usage: dart pwd_gen.dart [options]\n${parser.usage}');
    return;
  }
  final length = int.parse(result['length'] as String);
  final count = int.parse(result['count'] as String);
  for (var i = 0; i < count; i++) {
    final pw = generatePassword(
      length: length,
      useUpper: !(result['no-upper'] as bool),
      useLower: !(result['no-lower'] as bool),
      useDigits: !(result['no-digits'] as bool),
      useSymbols: !(result['no-symbols'] as bool),
    );
    final score = scoreStrength(pw);
    print('$pw  [$score ${strengthLabel(score)}]');
  }
}
