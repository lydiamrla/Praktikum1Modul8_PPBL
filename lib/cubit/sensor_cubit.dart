import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/sensor_info.dart';

class SensorCubit extends Cubit<List<SensorInfo>> {
  SensorCubit()
      : super([
          const SensorInfo(
            kode: 'ketinggian_air',
            nama: 'Tinggi Air',
            satuan: 'cm',
            posDefault: 'Pos Sungai Citarum',
            nilaiTerkini: 110.0,
            batasWaspada: 150.0,
            batasSiaga: 220.0,
            ikon: Icons.waves_rounded,
          ),
          const SensorInfo(
            kode: 'pergeseran_tanah',
            nama: 'Geser Tanah',
            satuan: 'mm',
            posDefault: 'Pos Tebing Lembang',
            nilaiTerkini: 2.5,
            batasWaspada: 10.0,
            batasSiaga: 25.0,
            ikon: Icons.landslide_rounded,
          ),
          const SensorInfo(
            kode: 'curah_hujan',
            nama: 'Curah Hujan',
            satuan: 'mm/jam',
            posDefault: 'Pos Bojongsoang',
            nilaiTerkini: 18.0,
            batasWaspada: 50.0,
            batasSiaga: 100.0,
            ikon: Icons.thunderstorm_rounded,
          ),
        ]);

  void perbaruiNilaiLive(String kodeSensor, double nilaiBaru, String posBaru) {
    final daftarBaru = state.map((sensor) {
      if (sensor.kode == kodeSensor) {
        return sensor.copyWith(nilaiTerkini: nilaiBaru, posDefault: posBaru);
      }
      return sensor;
    }).toList();
    emit(daftarBaru);
  }
}