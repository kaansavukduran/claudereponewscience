/// How times are shown (U013). Display only: the time a person types still
/// follows the entry rules (YYYY-MM-DD HH:MM), and stored times are UTC.
library;

/// Year-month-day (2026-11-08), day.month.year (08.11.2026) or
/// month/day/year (11/08/2026).
enum DateOrder { iso, dayMonth, monthDay }

enum ClockStyle { h24, h12 }

/// [local] in the chosen order and clock.
String formatWhen(DateTime local, DateOrder order, ClockStyle clock) {
  String two(int n) => n.toString().padLeft(2, '0');
  final date = switch (order) {
    DateOrder.iso => '${local.year}-${two(local.month)}-${two(local.day)}',
    DateOrder.dayMonth => '${two(local.day)}.${two(local.month)}.${local.year}',
    DateOrder.monthDay => '${two(local.month)}/${two(local.day)}/${local.year}',
  };
  final time = switch (clock) {
    ClockStyle.h24 => '${two(local.hour)}:${two(local.minute)}',
    ClockStyle.h12 =>
      '${local.hour % 12 == 0 ? 12 : local.hour % 12}:${two(local.minute)} '
          '${local.hour < 12 ? 'AM' : 'PM'}',
  };
  return '$date $time';
}

/// A calendar day alone in [order] (no clock).
String formatDay(int year, int month, int day, DateOrder order) {
  String two(int n) => n.toString().padLeft(2, '0');
  return switch (order) {
    DateOrder.iso => '$year-${two(month)}-${two(day)}',
    DateOrder.dayMonth => '${two(day)}.${two(month)}.$year',
    DateOrder.monthDay => '${two(month)}/${two(day)}/$year',
  };
}

/// The style every displayed time uses; set by the app from Settings.
/// A plain value (not per-widget) because times are formatted in many
/// places that have no BuildContext; it only changes how text looks.
DateOrder displayDateOrder = DateOrder.iso;
ClockStyle displayClock = ClockStyle.h24;
