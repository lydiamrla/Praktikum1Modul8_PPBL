import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../theme/app_theme.dart';
import '../widgets/status_siaga_badge.dart';

class HalamanRiwayat extends StatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  State<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  late Future<List<PembacaanSensor>> _futureRiwayat;
  String _statusSiagaDB = 'AMAN';

  @override
  void initState() {
    super.initState();
    _muatUlangData();
  }

  void _muatUlangData() {
    setState(() {
      _futureRiwayat = DatabaseHelper.instance.ambilSemuaPembacaan();
    });
    _perbaruiStatusSiaga();
  }

  Future<void> _perbaruiStatusSiaga() async {
    final statusTerbaru =
        await DatabaseHelper.instance.hitungStatusSiagaDariDB();
    if (!mounted) return;
    setState(() {
      _statusSiagaDB = statusTerbaru;
    });
  }

  String _formatNamaSensor(String kode) {
    switch (kode) {
      case 'ketinggian_air':
        return 'Ketinggian Air Sungai';
      case 'pergeseran_tanah':
        return 'Pergeseran Tanah';
      case 'curah_hujan':
        return 'Curah Hujan';
      default:
        return kode;
    }
  }

  String _satuanSensor(String kode) {
    switch (kode) {
      case 'ketinggian_air':
        return 'cm';
      case 'pergeseran_tanah':
        return 'mm';
      case 'curah_hujan':
        return 'mm/jam';
      default:
        return '';
    }
  }

  Future<void> _dialogKoreksiNilai(PembacaanSensor data) async {
    final controller = TextEditingController(text: data.nilai.toString());

    final nilaiBaru = await showDialog<double>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Koreksi Nilai Sensor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatNamaSensor(data.jenisSensor)} (${data.lokasiPos})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Nilai Terkoreksi (${_satuanSensor(data.jenisSensor)})',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogCtx,
              double.tryParse(controller.text),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (nilaiBaru != null) {
      await DatabaseHelper.instance.ubahPembacaan(
        PembacaanSensor(
          id: data.id,
          jenisSensor: data.jenisSensor,
          nilai: nilaiBaru,
          lokasiPos: data.lokasiPos,
          waktu: data.waktu,
        ),
      );
      _muatUlangData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Sensor',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          StatusSiagaBadge(status: _statusSiagaDB),
        ],
      ),
      body: FutureBuilder<List<PembacaanSensor>>(
        future: _futureRiwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan pembacaan sensor di SQLite.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: daftar.length,
            itemBuilder: (context, index) {
              final item = daftar[index];
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.alertRed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_forever, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await DatabaseHelper.instance.hapusPembacaan(item.id!);
                  _muatUlangData();
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.navyPrimary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.sensors,
                        color: AppTheme.navyPrimary,
                      ),
                    ),
                    title: Text(
                      _formatNamaSensor(item.jenisSensor),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item.lokasiPos}\n${item.waktu}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.nilai} ${_satuanSensor(item.jenisSensor)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppTheme.navyPrimary,
                          ),
                        ),
                        const Text(
                          'Ketuk koreksi',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () => _dialogKoreksiNilai(item),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}