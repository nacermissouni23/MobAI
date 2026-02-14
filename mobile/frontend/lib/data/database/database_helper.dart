import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton database helper managing the SQLite instance and schema.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static const int _version = 1;
  static const String _dbName = 'warehouse.db';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // ── Users ───────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL DEFAULT '',
        role TEXT NOT NULL DEFAULT 'employee',
        emplacement_id TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        server_id TEXT,
        sync_pending INTEGER NOT NULL DEFAULT 1,
        last_synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── Products ────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        sku TEXT NOT NULL,
        nom_produit TEXT NOT NULL,
        unite_mesure TEXT NOT NULL DEFAULT 'pcs',
        categorie TEXT,
        actif INTEGER NOT NULL DEFAULT 1,
        colisage_fardeau INTEGER,
        colisage_palette INTEGER,
        volume_pcs REAL,
        poids REAL,
        is_gerbable INTEGER NOT NULL DEFAULT 0,
        demand_frequency REAL NOT NULL DEFAULT 0.0,
        reception_frequency REAL NOT NULL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        server_id TEXT,
        sync_pending INTEGER NOT NULL DEFAULT 1,
        last_synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── Emplacements ────────────────────────────────────────
    batch.execute('''
      CREATE TABLE emplacements (
        id TEXT PRIMARY KEY,
        x INTEGER NOT NULL,
        y INTEGER NOT NULL,
        z INTEGER NOT NULL DEFAULT 0,
        floor INTEGER NOT NULL DEFAULT 0,
        is_obstacle INTEGER NOT NULL DEFAULT 0,
        is_slot INTEGER NOT NULL DEFAULT 0,
        is_elevator INTEGER NOT NULL DEFAULT 0,
        is_road INTEGER NOT NULL DEFAULT 0,
        is_expedition INTEGER NOT NULL DEFAULT 0,
        product_id TEXT,
        quantity INTEGER NOT NULL DEFAULT 0,
        is_occupied INTEGER NOT NULL DEFAULT 0,
        location_code TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        server_id TEXT,
        sync_pending INTEGER NOT NULL DEFAULT 1,
        last_synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // ── Chariots ────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE chariots (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        current_x INTEGER NOT NULL DEFAULT 0,
        current_y INTEGER NOT NULL DEFAULT 0,
        current_z INTEGER NOT NULL DEFAULT 0,
        current_floor INTEGER NOT NULL DEFAULT 0,
        assigned_to_operation TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        server_id TEXT,
        sync_pending INTEGER NOT NULL DEFAULT 1,
        last_synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── Orders ──────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        lines_json TEXT NOT NULL DEFAULT '[]',
        generated_by_ai INTEGER NOT NULL DEFAULT 0,
        overridden_by TEXT,
        override_reason TEXT,
        completed_at TEXT,
        completed_by TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        server_id TEXT,
        sync_pending INTEGER NOT NULL DEFAULT 1,
        last_synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── Operations ──────────────────────────────────────────
    batch.execute('''
      CREATE TABLE operations (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        employee_id TEXT,
        validator_id TEXT,
        validated_at TEXT,
        chariot_id TEXT,
        order_id TEXT,
        destination_x INTEGER,
        destination_y INTEGER,
        destination_z INTEGER,
        destination_floor INTEGER,
        source_x INTEGER,
        source_y INTEGER,
        source_z INTEGER,
        source_floor INTEGER,
        warehouse_id TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        started_at TEXT,
        completed_at TEXT,
        product_id TEXT,
        quantity INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        server_id TEXT,
        sync_pending INTEGER NOT NULL DEFAULT 1,
        last_synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (employee_id) REFERENCES users(id),
        FOREIGN KEY (chariot_id) REFERENCES chariots(id),
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // ── Operation Logs ──────────────────────────────────────
    batch.execute('''
      CREATE TABLE operation_logs (
        id TEXT PRIMARY KEY,
        operation_id TEXT NOT NULL,
        employee_id TEXT,
        product_id TEXT,
        quantity INTEGER NOT NULL DEFAULT 0,
        type TEXT,
        overrider_id TEXT,
        chariot_id TEXT,
        storage_floor INTEGER,
        storage_row INTEGER,
        storage_col INTEGER,
        override_reason TEXT,
        ai_suggested_floor INTEGER,
        ai_suggested_row INTEGER,
        ai_suggested_col INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        server_id TEXT,
        sync_pending INTEGER NOT NULL DEFAULT 1,
        last_synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (operation_id) REFERENCES operations(id),
        FOREIGN KEY (employee_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // ── Reports ─────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        operation_id TEXT NOT NULL,
        missing_quantity INTEGER NOT NULL DEFAULT 0,
        physical_damage INTEGER NOT NULL DEFAULT 0,
        extra_quantity INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        reported_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        server_id TEXT,
        sync_pending INTEGER NOT NULL DEFAULT 1,
        last_synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (operation_id) REFERENCES operations(id),
        FOREIGN KEY (reported_by) REFERENCES users(id)
      )
    ''');

    // ── Stock Ledger ────────────────────────────────────────
    batch.execute('''
      CREATE TABLE stock_ledger (
        id TEXT PRIMARY KEY,
        x INTEGER NOT NULL,
        y INTEGER NOT NULL,
        z INTEGER NOT NULL DEFAULT 0,
        floor INTEGER NOT NULL DEFAULT 0,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        recorded_at TEXT NOT NULL,
        operation_id TEXT,
        operation_type TEXT,
        user_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        server_id TEXT,
        sync_pending INTEGER NOT NULL DEFAULT 1,
        last_synced_at TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (operation_id) REFERENCES operations(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // ── Sync Metadata ───────────────────────────────────────
    batch.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // ── Indexes ─────────────────────────────────────────────
    batch.execute('CREATE INDEX idx_users_email ON users(email)');
    batch.execute('CREATE INDEX idx_users_role ON users(role)');
    batch.execute('CREATE INDEX idx_products_sku ON products(sku)');
    batch.execute('CREATE INDEX idx_products_category ON products(categorie)');
    batch.execute('CREATE INDEX idx_emplacements_coords ON emplacements(x, y, z, floor)');
    batch.execute('CREATE INDEX idx_emplacements_floor ON emplacements(floor)');
    batch.execute('CREATE INDEX idx_emplacements_product ON emplacements(product_id)');
    batch.execute('CREATE INDEX idx_chariots_code ON chariots(code)');
    batch.execute('CREATE INDEX idx_operations_type ON operations(type)');
    batch.execute('CREATE INDEX idx_operations_status ON operations(status)');
    batch.execute('CREATE INDEX idx_operations_employee ON operations(employee_id)');
    batch.execute('CREATE INDEX idx_operations_order ON operations(order_id)');
    batch.execute('CREATE INDEX idx_operation_logs_operation ON operation_logs(operation_id)');
    batch.execute('CREATE INDEX idx_reports_operation ON reports(operation_id)');
    batch.execute('CREATE INDEX idx_stock_ledger_product ON stock_ledger(product_id)');
    batch.execute('CREATE INDEX idx_stock_ledger_operation ON stock_ledger(operation_id)');
    batch.execute('CREATE INDEX idx_stock_ledger_location ON stock_ledger(x, y, z, floor)');

    // Sync-pending indexes for efficient sync queries
    batch.execute('CREATE INDEX idx_users_sync ON users(sync_pending)');
    batch.execute('CREATE INDEX idx_products_sync ON products(sync_pending)');
    batch.execute('CREATE INDEX idx_emplacements_sync ON emplacements(sync_pending)');
    batch.execute('CREATE INDEX idx_chariots_sync ON chariots(sync_pending)');
    batch.execute('CREATE INDEX idx_orders_sync ON orders(sync_pending)');
    batch.execute('CREATE INDEX idx_operations_sync ON operations(sync_pending)');
    batch.execute('CREATE INDEX idx_operation_logs_sync ON operation_logs(sync_pending)');
    batch.execute('CREATE INDEX idx_reports_sync ON reports(sync_pending)');
    batch.execute('CREATE INDEX idx_stock_ledger_sync ON stock_ledger(sync_pending)');

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here.
    // if (oldVersion < 2) { ... }
  }

  /// Close the database.
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }

  /// Delete and recreate the database (for development/testing).
  Future<void> resetDatabase() async {
    await close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
    _database = await _initDatabase();
  }
}
