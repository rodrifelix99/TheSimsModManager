// Keeps the retired GitHub Pages copy of the advisory feed in step with the
// real one.
//
// Every app up to v1.2.x fetches the list from
// rodrifelix99.github.io/TheSimsModManager/data/advisories.json, and Pages
// cannot redirect a JSON file, so that path has to keep answering for as long
// as those installs exist. web/public/data/advisories.json is the file to edit;
// this copies it back into docs/ after a build, and test/site_test.dart fails
// if the copy was never committed.
import { copyFileSync, mkdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const repo = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const source = join(repo, 'web', 'public', 'data', 'advisories.json');
const mirror = join(repo, 'docs', 'data', 'advisories.json');

// A malformed feed would ship to every installed app, so parse before copying.
JSON.parse(readFileSync(source, 'utf8'));

mkdirSync(dirname(mirror), { recursive: true });
copyFileSync(source, mirror);
