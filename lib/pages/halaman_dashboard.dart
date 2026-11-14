import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sensor_cubit.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../models/sensor_info.dart';
import '../theme/app_theme.dart';
import '../widgets/sensor_grid_item.dart';
import '../widgets/theme_toggle_button.dart';
import 'halaman_riwayat.dart';

class HalamanDashboard extends StatelessWidget {
  const HalamanDashboard({super.key});

  String _formatWaktuSekarang() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  void _tampilkanFormInputSensor(BuildContext context, SensorInfo sensor) {
    final nilaiController =
        TextEditingController(text: sensor.nilaiTerkini.toString());
    final posController = TextEditingController(text: sensor.posDefault);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Catat Pembacaan: ${sensor.nama}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ambang Waspada: ${sensor.batasWaspada} ${sensor.satuan} • Siaga: ${sensor.batasSiaga} ${sensor.satuan}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nilaiController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Nilai Sensor (${sensor.satuan})',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: posController,
                decoration: InputDecoration(
                  labelText: 'Lokasi Pos Pemantauan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Simulasi Acak'),
                      onPressed: () {
                        final randomVal = (sensor.batasWaspada * 0.5 +
                                Random().nextDouble() * sensor.batasSiaga)
                            .toStringAsFixed(1);
                        nilaiController.text = randomVal;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.navyPrimary,
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan SQLite'),
                      onPressed: () async {
                        final nilai = double.tryParse(nilaiController.text);
                        final pos = posController.text.trim();
                        if (nilai == null || pos.isEmpty) return;

                        final waktu = _formatWaktuSekarang();

                        // 1. Update tampilan live (Cubit)
                        context
                            .read<SensorCubit>()
                            .perbaruiNilaiLive(sensor.kode, nilai, pos);

                        // 2. Simpan permanen ke SQLite (Create)
                        await DatabaseHelper.instance.tambahPembacaan(
                          PembacaanSensor(
                            jenisSensor: sensor.kode,
                            nilai: nilai,
                            lokasiPos: pos,
                            waktu: waktu,
                          ),
                        );

                        if (!context.mounted) return;
                        Navigator.pop(sheetCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Data ${sensor.nama} ($nilai ${sensor.satuan}) tersimpan ke SQLite.',
                            ),
                            backgroundColor: AppTheme.tealAccent,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.tealAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'BPBD Siaga',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: 'Riwayat Sensor (SQLite)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HalamanRiwayat()),
              );
            },
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: BlocBuilder<SensorCubit, List<SensorInfo>>(
        builder: (context, daftarSensor) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Pemantauan AIoT Terkini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Banner Card Ala JAKI
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.navyPrimary, Color(0xFF155E63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MODE OFFLINE AKTIF • SQLITE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sistem Peringatan Dini Bencana',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ketuk ikon sensor di bawah untuk mencatat atau mensimulasikan pembacaan baru ke penyimpanan lokal perangkat.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.tealAccent,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.list_alt_rounded, size: 18),
                      label: const Text('Buka Log Audit Riwayat'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HalamanRiwayat()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Panel Bawah Putih Ala JAKI Sheet
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Satu aplikasi beragam sensor',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: daftarSensor.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final sensor = daftarSensor[index];
                        return SensorGridItem(
                          sensor: sensor,
                          onTap: () =>
                              _tampilkanFormInputSensor(context, sensor),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}