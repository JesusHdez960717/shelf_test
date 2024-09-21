import '../../bin/winter/core/core.dart';

@Valid([customTool])
class Tool {
  String? name;

  Tool({required this.name});

  @override
  String toString() {
    return 'Tool{name: $name}';
  }
}

bool customTool(dynamic prop, ConstraintValidatorContext cvc) {
  Tool tool = prop as Tool;
  if (tool.name == 'hammer') {
    cvc.addTemplateViolation('Cant be a hammer');
  }
  return cvc.isValid();
}

class Car {
  @NotEmpty()
  String? brand;

  Car({required this.brand});

  @override
  String toString() {
    return 'Car{brand: $brand}';
  }
}

@Valid([needMoreSpace])
class Laptop {
  int gbSpace;
  int ram;

  Laptop({required this.gbSpace, required this.ram});

  @override
  String toString() {
    return 'Laptop{gbSpace: $gbSpace, ram: $ram}';
  }
}

bool needMoreSpace(dynamic prop, ConstraintValidatorContext cvc) {
  Laptop laptop = prop as Laptop;
  if (laptop.ram < 32) {
    cvc.addTemplateViolation('need more ram');
  }
  if (laptop.gbSpace < 512) {
    cvc.addViolation(
      value: laptop.gbSpace,
      fieldName: 'hard_drive_space',
      message: 'need more hd space',
    );
  }
  return cvc.isValid();
}

class Address {
  @Valid([notNull, notEmpty])
  String? streetName;

  @NotNull()
  int? houseNumber;

  Address({
    this.streetName,
    this.houseNumber,
  });

  @override
  String toString() {
    return 'Address{streetName: $streetName, houseNumber: $houseNumber}';
  }
}

@Valid([customUser])
class User {
  @NotNull()
  @NotEmpty()
  String? userName;

  @NotNull()
  int? userId;

  Duration? duration;

  bool? isActive;

  @NotNull()
  List<Address>? addresses;

  @NotNull()
  Address? singleAddress;

  @NotEmpty()
  Map<String, dynamic>? additionalAttributes;

  User({
    required this.userName,
    required this.userId,
    required this.duration,
    required this.isActive,
    required this.addresses,
    required this.singleAddress,
    required this.additionalAttributes,
  });

  @override
  String toString() {
    return 'User{userName: $userName, userId: $userId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

bool customUser(dynamic prop, ConstraintValidatorContext cvc) {
  User user = prop as User;
  if (user.userId == 0) {
    cvc.addTemplateViolation('Can\'t have a cero id');
  }
  return cvc.isValid();
}

class NotBlankTestModel {
  @NotBlank()
  final String notBlankParam;

  NotBlankTestModel(this.notBlankParam);
}

class NotNullTestModel {
  @NotNull()
  final String? notNullParam;

  NotNullTestModel(this.notNullParam);
}

class NotEmptyStringTestModel {
  @NotEmpty()
  final String notEmptyParam;

  NotEmptyStringTestModel(this.notEmptyParam);
}

class NotEmptyListTestModel {
  @NotEmpty()
  final List<String> notEmptyParam;

  NotEmptyListTestModel(this.notEmptyParam);
}

class NotEmptyMapTestModel {
  @NotEmpty()
  final Map<String, String> notEmptyParam;

  NotEmptyMapTestModel(this.notEmptyParam);
}

class NotEmptySetTestModel {
  @NotEmpty()
  final Set<String> notEmptyParam;

  NotEmptySetTestModel(this.notEmptyParam);
}
