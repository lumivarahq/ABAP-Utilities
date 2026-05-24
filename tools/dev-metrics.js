#!/usr/bin/env node
/*
 * dev-metrics.js — derive a Conventional-Commits changelog and rough delivery
 * metrics from git history. Addresses the "no changelog / no DORA data" gaps
 * (Worst Habits §9.15, §9.5, §5.3) with the cheap-but-useful version the guide
 * itself recommends ("even rough numbers are better than nothing").
 *
 * Usage:
 *   node tools/dev-metrics.js                      # print rough metrics
 *   node tools/dev-metrics.js --changelog [file]   # print/write the changelog
 *
 * Not a CI gate (git history changes every commit).
 */
'use strict';
const { execSync } = require('child_process');
const fs = require('fs');

const SEP = '\x1f';
const REC = '\x1e';
const git = (args) => execSync('git ' + args, { encoding: 'utf8' });

function commits() {
  const out = git(`log --no-merges --pretty=format:%H${SEP}%s${SEP}%cI${REC}`);
  return out.split(REC).map((s) => s.trim()).filter(Boolean).map((line) => {
    const [hash, subject, date] = line.split(SEP);
    const m = subject.match(/^(\w+)(\([^)]*\))?(!)?:\s*(.+)$/);
    return {
      hash,
      date,
      type: m ? m[1].toLowerCase() : 'other',
      scope: m && m[2] ? m[2].slice(1, -1) : '',
      desc: m ? m[4] : subject,
    };
  });
}

const TYPES = {
  feat: 'Features', fix: 'Fixes', perf: 'Performance', refactor: 'Refactoring',
  docs: 'Documentation', test: 'Tests', build: 'Build', ci: 'CI',
  chore: 'Chores', style: 'Style', other: 'Other',
};

function changelog(list) {
  const span = list.length ? `${list[list.length - 1].date.slice(0, 10)} → ${list[0].date.slice(0, 10)}` : '';
  let md = '# Changelog\n\n';
  md += '_Generated from Conventional Commits by `npm run changelog` '
      + '(`tools/dev-metrics.js`). Not a CI gate; regenerate as needed._\n\n';
  md += `${list.length} commits (${span}).\n\n`;
  for (const t of Object.keys(TYPES)) {
    const rows = list.filter((c) => c.type === t);
    if (!rows.length) continue;
    md += `## ${TYPES[t]}\n`;
    for (const c of rows) md += `- ${c.scope ? `**${c.scope}**: ` : ''}${c.desc} (\`${c.hash.slice(0, 7)}\`)\n`;
    md += '\n';
  }
  return md;
}

function metrics(list) {
  if (!list.length) return 'No commits.';
  const days = Math.max(1, (new Date(list[0].date) - new Date(list[list.length - 1].date)) / 86400000);
  const weeks = days / 7;
  const fixes = list.filter((c) => c.type === 'fix' || c.type === 'revert').length;
  const merges = git('log --merges --oneline').split('\n').filter(Boolean).length;
  return [
    'Delivery metrics (rough proxies — see docs/dev-metrics.md)',
    '',
    `  Commits ............................. ${list.length} over ~${days.toFixed(0)} days (${(list.length / weeks).toFixed(1)}/week)`,
    `  Merges (deployment-frequency proxy) . ${merges}`,
    `  Fix/revert share (CFR proxy) ........ ${(100 * fixes / list.length).toFixed(0)}%  (${fixes}/${list.length})`,
    '  Lead time & MTTR .................... need PR/incident data (not in git alone)',
  ].join('\n');
}

const list = commits();
if (process.argv[2] === '--changelog') {
  const md = changelog(list);
  const out = process.argv[3];
  if (out) { fs.writeFileSync(out, md); console.log(`Wrote ${out}`); } else process.stdout.write(md);
} else {
  process.stdout.write(metrics(list) + '\n');
}
