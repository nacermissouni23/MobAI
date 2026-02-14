// Application enumerations mirroring the backend schema.
// Each enum has a [value] for DB storage and JSON serialization.

enum UserRole {
  admin('admin'),
  supervisor('supervisor'),
  employee('employee');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String s) => UserRole.values.firstWhere(
    (e) => e.value == s,
    orElse: () => UserRole.employee,
  );

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.employee:
        return 'Employee';
    }
  }
}

enum OperationType {
  receipt('receipt'),
  transfer('transfer'),
  picking('picking'),
  delivery('delivery');

  final String value;
  const OperationType(this.value);

  static OperationType fromString(String s) => OperationType.values.firstWhere(
    (e) => e.value == s,
    orElse: () => OperationType.receipt,
  );

  String get label {
    switch (this) {
      case OperationType.receipt:
        return 'Receipt';
      case OperationType.transfer:
        return 'Transfer';
      case OperationType.picking:
        return 'Picking';
      case OperationType.delivery:
        return 'Delivery';
    }
  }
}

enum OperationStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  failed('failed');

  final String value;
  const OperationStatus(this.value);

  static OperationStatus fromString(String s) => OperationStatus.values
      .firstWhere((e) => e.value == s, orElse: () => OperationStatus.pending);

  String get label {
    switch (this) {
      case OperationStatus.pending:
        return 'Pending';
      case OperationStatus.inProgress:
        return 'In Progress';
      case OperationStatus.completed:
        return 'Completed';
      case OperationStatus.failed:
        return 'Failed';
    }
  }
}

enum OrderType {
  command('command'),
  preparation('preparation'),
  picking('picking');

  final String value;
  const OrderType(this.value);

  static OrderType fromString(String s) => OrderType.values.firstWhere(
    (e) => e.value == s,
    orElse: () => OrderType.command,
  );

  String get label {
    switch (this) {
      case OrderType.command:
        return 'Command';
      case OrderType.preparation:
        return 'Preparation';
      case OrderType.picking:
        return 'Picking';
    }
  }
}

enum OrderStatus {
  pending('pending'),
  aiGenerated('ai_generated'),
  validated('validated'),
  overridden('overridden'),
  completed('completed');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String s) => OrderStatus.values.firstWhere(
    (e) => e.value == s,
    orElse: () => OrderStatus.pending,
  );

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.aiGenerated:
        return 'AI Generated';
      case OrderStatus.validated:
        return 'Validated';
      case OrderStatus.overridden:
        return 'Overridden';
      case OrderStatus.completed:
        return 'Completed';
    }
  }
}
