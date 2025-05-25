#!/usr/bin/env node

import fs from "fs";
import prettier from "prettier";
import { spawn } from "node:child_process";

export function formatWithPrettierd(filepath: string, source: string, parser: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const proc = spawn("prettierd", [filepath, `--parser=${parser}`  ]);

    let output = "";
    let errorOutput = "";

    proc.stdout.on("data", (chunk) => {
      output += chunk.toString();
    });

    proc.stderr.on("data", (chunk) => {
      errorOutput += chunk.toString();
    });

    proc.on("error", reject);

    proc.on("close", (code) => {
      if (code === 0) {
        resolve(output);
      } else {
        reject(new Error(`prettierd failed with code ${code}:\n${errorOutput}`));
      }
    });

    proc.stdin.write(source);
    proc.stdin.end();
  });
}

const filepath = process.argv[2];

const options = await prettier.resolveConfig(filepath ?? process.cwd());

// Read from stdin
const stdin = await new Promise<string>((resolve, reject) => {
  let data = "";
  process.stdin.setEncoding("utf-8");
  process.stdin.on("data", chunk => (data += chunk));
  process.stdin.on("end", () => resolve(data));
  process.stdin.on("error", reject);
});

// Format entire file as MDX
let formatted = await formatWithPrettierd(filepath, stdin, 'mdx');

// Regex to match all tags, including self-closing and opening/closing
const tagRegex =
  /<(\/?)([a-zA-Z][\w-]*)([^>]*)\/?>|<\/([a-zA-Z][\w-]*)>/g;

function findTagBlocks(text: string) {
  const blocks: {start:number, end:number}[] = [];
  const stack: { tag: string; start: number }[] = [];
  let match: RegExpExecArray | null;

  while ((match = tagRegex.exec(text))) {
    const [full, slash, tagName, attrs, closingName] = match;
    const isClosing = !!slash || !!closingName;
    const tag = tagName || closingName;
    const index = match.index;

    const isSelfClosing = /\/\s*>$/.test(full) || (!slash && full.endsWith("/>"));

    if (!isClosing && !isSelfClosing) {
      // opening tag
      stack.push({ tag, start: index });
    } else if (isSelfClosing) {
      // self-closing tag — treat as standalone block
    if (stack.length === 0) {
      blocks.push({
        start: index,
        end: index + full.length,
      });

    }
    } else {
      // closing tag
      const last = stack.pop();
      if (last && last.tag === tag && stack.length === 0) {
        blocks.push({
          start: last.start,
          end: index + full.length,
        });
      }
    }
  }

  return blocks.sort((a, b) => a.start - b.start);
}

// Find all blocks and format each with Svelte parser
const blocks = findTagBlocks(formatted);

// Merge adjacent blocks if there is only whitespace or nothing between them
type Block = { start: number; end: number };
function mergeAdjacentBlocks(blocks: Block[], text: string): Block[] {
  if (blocks.length === 0) return [];
  const merged: Block[] = [];
  let current = { ...blocks[0] };
  for (let i = 1; i < blocks.length; i++) {
    const prev = current;
    const next = blocks[i];
    const between = text.slice(prev.end, next.start);
    if (/^\s*$/.test(between)) {
      // Merge blocks
      current.end = next.end;
    } else {
      merged.push(current);
      current = { ...next };
    }
  }
  merged.push(current);
  return merged;
}

const mergedBlocks = mergeAdjacentBlocks(blocks, formatted);

let result = "";
let lastIndex = 0;
const promises: (Promise<string> | string)[] = [];

for (const { start, end } of mergedBlocks) {
  promises.push(formatted.slice(lastIndex, start));
  const block = formatted.slice(start, end);
  try {
    promises.push(formatWithPrettierd(filepath, block, 'svelte'));
  } catch (e) {
    console.log(e.message);
    throw new Error(e);
  }
  lastIndex = end;
}

const results = await Promise.all(promises)
results.forEach((res) => {
    result += res
})

result += formatted.slice(lastIndex);

process.stdout.write(result);

// For testing
// time for i in {1..100}; do node ~/.config/nvim/scripts/format_md_svelte.ts < preview.md.svelte > /dev/null; done
