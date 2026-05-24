#!/usr/bin/env node
/*
 * Generate docs/api/*.md from the abapGit ABAP sources.
 *
 * This is the offline / CI counterpart of the in-system ABAP class
 * ZCL_AU_DOCGEN (which builds the same kind of API reference at runtime via
 * RTTI). Running it here lets CI auto-publish docs/api without a SAP system.
 *
 * It extracts the PUBLIC method declarations of each global class/interface and
 * the one-line ABAP Doc summary ("!) that precedes each. Output is deterministic
 * (sources are walked in sorted order) so it can gate a freshness check in CI.
 *
 * Usage: node tools/gen-api-docs.js
 */
'use strict';
const fs = require('fs');
const path = require('path');

const SRC = 'src';
const OUT = 'docs/api';

function walk(dir, acc = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true })
    .sort((a, b) => a.name.localeCompare(b.name));
  for (const e of entries) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p, acc);
    else if (/\.(clas|intf)\.abap$/.test(e.name) && !/\.testclasses\.abap$/.test(e.name)) acc.push(p);
  }
  return acc;
}

function descFromXml(abapFile) {
  const xml = abapFile.replace(/\.abap$/, '.xml');
  try {
    const m = fs.readFileSync(xml, 'utf8').match(/<DESCRIPT>([^<]*)<\/DESCRIPT>/);
    return m ? m[1].replace(/&amp;/g, '&') : '';
  } catch (_) { return ''; }
}

// Pull the public method declarations + their preceding "! summary.
function parse(file) {
  const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
  const isInterface = file.endsWith('.intf.abap');
  let inPublic = isInterface;     // interfaces are entirely public
  let doc = [];
  const methods = [];
  for (const raw of lines) {
    const line = raw.trim();
    if (/^public section\./i.test(line)) { inPublic = true; doc = []; continue; }
    if (/^(protected|private) section\./i.test(line)) { inPublic = false; doc = []; continue; }

    const decl = line.match(/^(?:class-methods|methods)\s+([a-z0-9_~]+)/i);
    if (decl && !/redefinition/i.test(line)) {
      const name = decl[1];
      const skip = /^(constructor|class_constructor)$/i.test(name) || name.includes('~');
      if (inPublic && !skip) {
        const summary = (doc.find((d) => d.length) || '').replace(/\|/g, '\\|');
        methods.push({ name, summary });
      }
      doc = [];
      continue;
    }

    if (line.startsWith('"!')) { doc.push(line.replace(/^"!\s?/, '').trim()); continue; }
    doc = [];   // only a comment block *immediately* before a method counts
  }
  return methods;
}

const objName = (f) => path.basename(f).replace(/\.(clas|intf)\.abap$/, '').toUpperCase();
const moduleOf = (f) => path.basename(path.dirname(f));

fs.mkdirSync(OUT, { recursive: true });
const files = walk(SRC);
const index = [];

for (const f of files) {
  const name = objName(f);
  const desc = descFromXml(f);
  const methods = parse(f);

  let md = `# ${name}\n\n`;
  if (desc) md += `${desc}\n\n`;
  md += `_Module: \`${moduleOf(f)}\` — generated from source by \`tools/gen-api-docs.js\`; do not edit by hand._\n\n`;
  if (methods.length) {
    md += '| Method | Description |\n|--------|-------------|\n';
    for (const m of methods) md += `| \`${m.name}\` | ${m.summary || ''} |\n`;
  } else {
    md += '_No public methods found._\n';
  }
  fs.writeFileSync(path.join(OUT, name.toLowerCase() + '.md'), md);
  index.push({ name, module: moduleOf(f), desc });
}

let idx = '# API reference (generated)\n\n';
idx += 'Generated from the ABAP sources by `tools/gen-api-docs.js` — the offline/CI '
     + 'counterpart of the in-system `ZCL_AU_DOCGEN`. Do not edit by hand; run `npm run docs`.\n\n';
idx += '| Object | Module | Description |\n|--------|--------|-------------|\n';
for (const o of index) idx += `| [${o.name}](${o.name.toLowerCase()}.md) | \`${o.module}\` | ${o.desc || ''} |\n`;
fs.writeFileSync(path.join(OUT, 'README.md'), idx);

console.log(`Generated ${files.length} API doc(s) in ${OUT}/`);
