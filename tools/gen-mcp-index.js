#!/usr/bin/env node
/*
 * Generate index/abap-utilities.json — a machine-readable index of this repo's
 * ABAP utilities, extracted from the abapGit sources and their ABAPDoc.
 *
 * The intent is that a documentation MCP server (e.g. marianfoo/mcp-sap-docs,
 * see docs/MCP-INTEGRATION.md) could serve these utilities as a first-class
 * source. It reuses the same source parsing as tools/gen-api-docs.js.
 *
 * Output is deterministic (sources walked in sorted order, no timestamps) so it
 * diffs cleanly and could gate a freshness check in CI.
 *
 * Usage: node tools/gen-mcp-index.js
 */
'use strict';
const fs = require('fs');
const path = require('path');

const SRC = 'src';
const OUT_DIR = 'index';
const OUT_FILE = path.join(OUT_DIR, 'abap-utilities.json');

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
function parseMethods(file) {
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
        const summary = (doc.find((d) => d.length) || '');
        methods.push({ name: name.toUpperCase(), summary });
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

let repoVersion = '';
try { repoVersion = JSON.parse(fs.readFileSync('package.json', 'utf8')).version || ''; } catch (_) {}

const objects = walk(SRC).map((f) => {
  const module = moduleOf(f);
  return {
    object: objName(f),
    kind: f.endsWith('.intf.abap') ? 'interface' : 'class',
    module,
    subpackage: 'ZAU_' + module.toUpperCase(),  // abapGit FOLDER_LOGIC=PREFIX convention
    description: descFromXml(f),
    source: f.split(path.sep).join('/'),
    methods: parseMethods(f),
  };
});

const index = {
  generator: 'tools/gen-mcp-index.js',
  repository: 'abap-utilities',
  version: repoVersion,
  count: objects.length,
  objects,
};

fs.mkdirSync(OUT_DIR, { recursive: true });
fs.writeFileSync(OUT_FILE, JSON.stringify(index, null, 2) + '\n');
console.log(`Wrote ${objects.length} object(s) to ${OUT_FILE}`);
