import type { ExactResize, WindowMatcher } from "./hyprland/types";

export interface ManagedApp {
  id: string;
  command: string;
  match: WindowMatcher;
  launchMatch?: WindowMatcher;
  targetMonitor: number;
  order: number;
  group?: string;
  resize?: ExactResize;
}

export interface LayoutConfig {
  apps: readonly ManagedApp[];
}

function app(config: ManagedApp): ManagedApp {
  return config;
}
// ---- monitor 0 ---- //
const code_nixos = app({
  id: "nixos-code",
  command: "code --use-angle=vulkan ~/nixos-config",
  match: {
    title: /.*nixos-config.*/,
  },
  // launchMatch: {
  //   initialTitle: "Visual Studio Code",
  // },
  targetMonitor: 0,
  order: 0,
  group: "dev",
});

const code_cmsCodex = app({
  id: "code_cmsCodex",
  command: "code --use-angle=vulkan ~/code/cms-codex",
  match: {
    title: /.*cms-codex.*/,
  },
  // launchMatch: {
  //   initialTitle: "Visual Studio Code",
  // },
  targetMonitor: 0,
  order: 1,
  group: "dev",
});

const kitty = app({
  id: "kitty",
  command: "kitty",
  match: {
    class: /^kitty$/,
  },
  targetMonitor: 0,
  order: 2,
  group: "dev",
});

const code_cms = app({
  id: "code_cms",
  command: "code --use-angle=vulkan ~/code/cmsWrapper/cms",
  match: {
    title: /^(?!.*codex).*cms.*/,
  },
  // launchMatch: {
  //   initialTitle: "Visual Studio Code",
  // },
  targetMonitor: 0,
  order: 3,
  group: "dev",
});

// ---- monitor 0 ---- //
const firefoxDev = app({
  id: "firefox-dev",
  command: "firefox-devedition -P dev",
  match: {
    class: /^firefox-devedition$/,
  },
  targetMonitor: 1,
  order: 0,
  group: "research",
  resize: {
    mode: "exact",
    width: "80%",
    height: "100%",
  },
});

const obsidian = app({
  id: "obsidian",
  command: "obsidian",
  match: {
    title: /.*Obsidian.*/,
  },
  targetMonitor: 1,
  order: 1,
  group: "research",
});

const noSqlWorkbench = app({
  id: "nosql-workbench",
  command: "nosql-workbench",
  match: {
    title: "NoSQL Workbench",
  },
  launchMatch: {
    initialTitle: "NoSQL Workbench",
  },
  targetMonitor: 1,
  order: 2,
  group: "research",
});

const firefox = app({
  id: "firefox",
  command: "firefox",
  match: {
    class: /^firefox$/,
  },
  targetMonitor: 1,
  order: 3,
  resize: {
    mode: "exact",
    width: "60%",
    height: "100%",
  },
});

const thunar = app({
  id: "thunar",
  command: "thunar",
  match: {
    class: /^thunar$/,
  },
  targetMonitor: 1,
  order: 4,
  group: "utilities",
});

const keepassxc = app({
  id: "keepassxc",
  command: "keepassxc",
  match: {
    class: /^org\.keepassxc\.KeePassXC$/,
  },
  targetMonitor: 1,
  order: 5,
  group: "utilities",
});

const tidalHifi = app({
  id: "tidal-hifi",
  command: "tidal-hifi",
  match: {
    class: /^tidal-hifi$/,
  },
  targetMonitor: 1,
  order: 6,
  group: "utilities",
});

export const layoutConfig: LayoutConfig = {
  apps: [
    code_nixos,
    kitty,
    code_cmsCodex,
    code_cms,
    firefoxDev,
    obsidian,
    noSqlWorkbench,
    firefox,
    thunar,
    keepassxc,
    tidalHifi,
  ],
};
