#!/usr/bin/env node
// Check the translation files and, optionally, the actual packaged application.
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const app = process.argv[2];
const resources = app ? path.join(app, 'Contents/Resources') : path.join(root, 'Tinycast/Resources');
function table(language, name = 'Localizable') {
  return JSON.parse(execFileSync('plutil', ['-convert', 'json', '-o', '-', path.join(resources, `${language}.lproj`, `${name}.strings`)], { encoding: 'utf8' }));
}
const en = table('en');
const zh = table('zh-Hans');
assert.deepEqual(Object.keys(en).sort(), Object.keys(zh).sort(), 'English and Chinese keys differ');
for (const [key, value] of Object.entries(zh)) {
  assert.ok(value.trim(), `Empty translation: ${key}`);
  const placeholders = text => (text.match(/%(?:\d+\$)?(?:@|lld|ld|d|f)/g) || []).sort();
  assert.deepEqual(placeholders(value), placeholders(key), `Format mismatch: ${key}`);
}
for (const key of ['General', 'Clipboard', 'Window Management', 'Enable Clipboard History', 'Search for apps and commands…', 'Lock Screen', 'Search Files', 'Left Half', 'Welcome to Tinycast']) {
  assert.ok(zh[key] && zh[key] !== key, `Missing core translation: ${key}`);
}
for (const [key, value] of Object.entries(table('zh-Hans', 'InfoPlist'))) {
  assert.ok(value.trim(), `Empty permission description: ${key}`);
}
if (app) {
  const plist = JSON.parse(execFileSync('plutil', ['-convert', 'json', '-o', '-', path.join(app, 'Contents/Info.plist')], { encoding: 'utf8' }));
  assert.equal(plist.CFBundleIdentifier, 'io.github.houxiaozhao.tinycast.zh');
  assert.equal(plist.LSMinimumSystemVersion, '26.0');
  assert.ok(fs.existsSync(path.join(app, 'Contents/Helpers/ClipboardTextHelper')));
}
console.log(`PASS: ${Object.keys(zh).length} translation keys, matching English fallback, permission strings${app ? ', packaged bundle identity and helper' : ''}.`);
