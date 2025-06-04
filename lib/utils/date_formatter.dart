class DateFormatter {
  /// Mengubah tanggal dari format 'yyyy-MM-dd' ke format Indonesia 'EEEE, dd MMMM yyyy'
  /// Contoh: '2025-06-04' -> 'Rabu, 04 Juni 2025'
  static String ubahTanggal(String date) {
    try {
      final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      final months = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final parts = date.split('-');
      if (parts.length != 3) return date;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final dt = DateTime(year, month, day);
      final dayName = days[dt.weekday % 7];
      final monthName = months[month];
      final dayStr = day.toString().padLeft(2, '0');
      return '$dayName, $dayStr $monthName $year';
    } catch (e) {
      return date;
    }
  }
}
