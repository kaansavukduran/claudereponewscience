// Deterministic calendar-date arithmetic on ISO dates (YYYY-MM-DD), timezone-free.

const DAY_MS = 86_400_000;

export function toDayNumber(iso: string): number {
  const [y, m, d] = iso.slice(0, 10).split('-').map(Number) as [number, number, number];
  return Math.floor(Date.UTC(y, m - 1, d) / DAY_MS);
}

export function fromDayNumber(n: number): string {
  return new Date(n * DAY_MS).toISOString().slice(0, 10);
}

export function addDays(iso: string, days: number): string {
  return fromDayNumber(toDayNumber(iso) + days);
}

export function daysBetween(a: string, b: string): number {
  return toDayNumber(b) - toDayNumber(a);
}
