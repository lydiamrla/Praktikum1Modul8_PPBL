import 'package:flutter/material.dart';

class SensorInfo {
  final String kode; // 'ketinggian_air', 'pergeseran_tanah', 'curah_hujan'
  final String nama;
  final String satuan;
  final String posDefault;
  final double nilaiTerkini;
  final double batasWaspada;
  final double batasSiaga;
  final IconData ikon;
  final bool isDarurat;

  const SensorInfo({
    required this.kode,
    required this.nama,
    required this.satuan,
    required this.posDefault,
    required this.nilaiTerkini,
    required this.batasWaspada,
    required this.batasSiaga,
    required this.ikon,
    this.isDarurat = false,
  });

  SensorInfo copyWith({double? nilaiTerkini, String? posDefault}) {
    return SensorInfo(
      kode: kode,
      nama: nama,
      satuan: satuan,
      posDefault: posDefault ?? this.posDefault,
      nilaiTerkini: nilaiTerkini ?? this.nilaiTerkini,
      batasWaspada: batasWaspada,
      batasSiaga: batasSiaga,
      ikon: ikon,
      isDarurat: (nilaiTerkini ?? this.nilaiTerkini) >= batasSiaga,
    );
  }
}