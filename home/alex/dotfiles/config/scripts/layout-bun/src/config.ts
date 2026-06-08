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

type ManagedAppDefinition = Omit<
  ManagedApp,
  "targetMonitor" | "order" | "group"
>;

type MonitorLayout = Record<
  number,
  readonly (readonly ManagedAppDefinition[])[]
>;

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
        groupApps.length > 1
          ? `monitor-${targetMonitor}-group-${groupIndex}`
          : undefined;

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

const code_nixos = app({
  id: "nixos-code",
  command: "code --use-angle=vulkan ~/nixos-config",
  match: {
    title: /.*nixos-config.*/,
  },
  // launchMatch: {
  //   initialTitle: "Visual Studio Code",
  // },
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
});

const kitty = app({
  id: "kitty",
  command: "kitty",
  match: {
    class: /^kitty$/,
  },
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
});

const firefoxDev = app({
  id: "firefox-dev",
  command: "firefox-devedition -P dev",
  match: {
    class: /^firefox-devedition$/,
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

const firefox = app({
  id: "firefox",
  command: "firefox",
  match: {
    class: /^firefox$/,
  },
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
    [firefoxDev, obsidian, noSqlWorkbench],
    // [firefox],
  ],
  1: [
    [
      code_nixos,
      // code_cmsCodex,
      kitty,
      code_cms,
    ],
  ],
});
