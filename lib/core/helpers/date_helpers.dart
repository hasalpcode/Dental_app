const List<String> frenchMonthNames = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

const List<String> frenchMonthAbbreviations = [
  'Jan',
  'Fév',
  'Mar',
  'Avr',
  'Mai',
  'Juin',
  'Juil',
  'Août',
  'Sep',
  'Oct',
  'Nov',
  'Déc',
];

String monthNameFr(int month) => frenchMonthNames[month - 1];

String formatDateFr(DateTime date) {
  return '${date.day} ${monthNameFr(date.month)} ${date.year}';
}
