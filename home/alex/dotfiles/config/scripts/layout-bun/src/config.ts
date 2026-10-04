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

type ManagedAppDefinition = Omit<ManagedApp, "targetMonitor" | "order" | "group">;

type MonitorLayout = Record<number, readonly (readonly ManagedAppDefinition[])[]>;

function app(config: ManagedAppDefinition): ManagedAppDefinition {
  return config;
}

function defineLayout(monitors: MonitorLayout): LayoutConfig {
  const apps: ManagedApp[] = [];

  for (const [monitorKey, groups] of Object.entries(monitors).sort(
    ([left], [right]) => Number(left) - Number(right),
  )) {
    const targetMonitor = Number(monitorKey);
    let order = 0;

    for (const [groupIndex, groupApps] of groups.entries()) {
      const groupId =
        groupApps.length > 1 ? `monitor-${targetMonitor}-group-${groupIndex}` : undefined;

      for (const groupApp of groupApps) {
        apps.push({
          ...groupApp,
          targetMonitor,
          order,
          ...(groupId ? { group: groupId } : {}),
        });
        order += 1;
      }
    }
  }

  return { apps };
}

const kitty_cms = app({
  id: "kitty-cms",
  command: "kitty --class kitty-cms --directory /home/alex/code/cms",
  match: {
    class: /^kitty-cms$/,
  },
});

const kitty_achdNz = app({
  id: "kitty-achdNz",
  command: "kitty --class kitty-achdNz --directory /home/alex/code/achdNz",
  match: {
    class: /^kitty-achdNz$/,
  },
});

const kitty_cmsWrapper = app({
  id: "kitty-cms-wrapper",
  command:
    "kitty --class kitty-cms-wrapper --directory /home/alex/code/cmsWrapper/cms",
  match: {
    class: /^kitty-cms-wrapper$/,
  },
});

const kitty_cmsCodex = app({
  id: "kitty-cms-codex",
  command: "kitty --class kitty-cms-codex --directory /home/alex/code/cms-codex",
  match: {
    class: /^kitty-cms-codex$/,
  },
});

const kitty_btop = app({
  id: "kitty-btop",
  command: "kitty --class kitty-btop -e btop",
  match: {
    class: /^kitty-btop$/,
  },
});

const firefox = app({
  id: "firefox",
  command: "firefox",
  match: {
    class: /^firefox$/,
  },
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
});

const thunar = app({
  id: "thunar",
  command: "thunar",
  match: {
    class: /^thunar$/,
  },
});

const keepassxc = app({
  id: "keepassxc",
  command: "keepassxc",
  match: {
    class: /^org\.keepassxc\.KeePassXC$/,
  },
});

const tidalHifi = app({
  id: "tidal-hifi",
  command: "tidal-hifi",
  match: {
    class: /^tidal-hifi$/,
  },
});

export const layoutConfig = defineLayout({
  0: [
    [
      thunar,
      keepassxc,
      // tidalHifi
    ],
    [
      firefox,
      kitty_btop,
      // obsidian,
      // noSqlWorkbench,
    ],
  ],
  1: [
    [
      kitty_cms,
      kitty_achdNz,
      kitty_cmsWrapper,
      kitty_cmsCodex,
    ],
  ],
});
