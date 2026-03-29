import { MatchPattern } from "../hyprland/types";

export function patternMatches(pattern: MatchPattern, value: string): boolean {
  return typeof pattern === "string" ? value === pattern : pattern.test(value);
}

export function logStep(message: string): void {
  console.log(message);
}
