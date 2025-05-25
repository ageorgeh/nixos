#!/usr/bin/env bun

import { spawn } from "bun";

export async function formatWithPrettierd(
  filepath: string,
  source: string,
  parser: string,
): Promise<string> {
  const proc = spawn(["prettierd", filepath, `--parser=${parser}`], {
    stdin: "pipe",
    stdout: "pipe",
    stderr: "pipe",
  });

  const output = new Response(proc.stdout).text();
  const errorOutput = new Response(proc.stderr).text();

  proc.stdin.write(source);
  proc.stdin.end();

  await proc.exited;
  if (proc.exitCode === 0) {
    return output;
  } else {
    throw new Error(
      `prettierd failed with code ${proc.exitCode}:\n${errorOutput}`,
    );
  }
}

const filepath = process.argv[2];

// Read from stdin
const stdin = await new Promise<string>((resolve, reject) => {
  let data = "";
  process.stdin.setEncoding("utf-8");
  process.stdin.on("data", (chunk) => (data += chunk));
  process.stdin.on("end", () => resolve(data));
  process.stdin.on("error", reject);
});

// Format entire file as MDX
let formatted = await formatWithPrettierd(filepath, stdin, "mdx");

// Regex to match all tags, including self-closing and opening/closing
const tagRegex = /<(\/?)([a-zA-Z][\w-]*)([^>]*)\/?>|<\/([a-zA-Z][\w-]*)>/g;

function findTagBlocks(text: string) {
  const blocks: { start: number; end: number }[] = [];
  const stack: { tag: string; start: number }[] = [];
  let match: RegExpExecArray | null;

  while ((match = tagRegex.exec(text))) {
    const [full, slash, tagName, attrs, closingName] = match;
    const isClosing = !!slash || !!closingName;
    const tag = tagName || closingName;
    const index = match.index;

    const isSelfClosing =
      /\/\s*>$/.test(full) || (!slash && full.endsWith("/>"));

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

let lastIndex = 0;
const chunks: (string | Promise<string>)[] = [];

for (const { start, end } of mergedBlocks) {
  chunks.push(formatted.slice(lastIndex, start));
  const block = formatted.slice(start, end);
  chunks.push(formatWithPrettierd(filepath, block, "svelte"));
  lastIndex = end;
}
chunks.push(formatted.slice(lastIndex));

const results = await Promise.all(chunks);
process.stdout.write(results.join(""));

// For testing
// time for i in {1..100}; do node ~/.config/nvim/scripts/format_md_svelte.ts < preview.md.svelte > /dev/null; done
// time for i in {1..100}; do bun ~/.config/nvim/scripts/format_md_svelte.ts < preview.md.svelte > /dev/null; done
