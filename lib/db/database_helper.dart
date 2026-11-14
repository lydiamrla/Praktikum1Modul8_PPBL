import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pembacaan_sensor.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'aiot_bencana.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pembacaan_sensor (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jenis_sensor TEXT NOT NULL,
            nilai REAL NOT NULL,
            lokasi_pos TEXT NOT NULL,
            waktu TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> tambahPembacaan(PembacaanSensor data) async {
    final db = await database;
    return db.insert('pembacaan_sensor', data.toMap());
  }

  // READ (Terurut dari terbaru)
  Future<List<PembacaanSensor>> ambilSemuaPembacaan() async {
    final db = await database;
    final hasil = await db.query('pembacaan_sensor', orderBy: 'id DESC');
    return hasil.map((baris) => PembacaanSensor.fromMap(baris)).toList();
  }

  // UPDATE (Wajib dengan where dan whereArgs)
  Future<int> ubahPembacaan(PembacaanSensor data) async {
    final db = await database;
    return db.update(
      'pembacaan_sensor',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  // DELETE (Wajib dengan where dan whereArgs)
  Future<int> hapusPembacaan(int id) async {
    final db = await database;
    return db.delete(
      'pembacaan_sensor',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hitung Status Siaga berdasarkan nilai terbaru per jenis sensor dari SQLite
  Future<String> hitungStatusSiagaDariDB() async {
    final semuaData = await ambilSemuaPembacaan();
    if (semuaData.isEmpty) return 'AMAN';

    // Ambil pembacaan paling baru untuk tiap jenis_sensor
    final Map<String, PembacaanSensor> terbaruPerJenis = {};
    for (final item in semuaData) {
      if (!terbaruPerJenis.containsKey(item.jenisSensor)) {
        terbaruPerJenis[item.jenisSensor] = item;
      }
    }

    String statusTertinggi = 'AMAN';

    terbaruPerJenis.forEach((jenis, data) {
      if (jenis == 'ketinggian_air') {
        if (data.nilai >= 220) {
          statusTertinggi = 'SIAGA';
        } else if (data.nilai >= 150 && statusTertinggi != 'SIAGA') {
          statusTertinggi = 'WASPADA';
        }
      } else if (jenis == 'pergeseran_tanah') {
        if (data.nilai >= 25) {
          statusTertinggi = 'SIAGA';
        } else if (data.nilai >= 10 && statusTertinggi != 'SIAGA') {
          statusTertinggi = 'WASPADA';
        }
      } else if (jenis == 'curah_hujan') {
        if (data.nilai >= 100) {
          statusTertinggi = 'SIAGA';
        } else if (data.nilai >= 50 && statusTertinggi != 'SIAGA') {
          statusTertinggi = 'WASPADA';
        }
      }
    });

    return statusTertinggi;
  }
}