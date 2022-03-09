class UserModel {
  String id;
  String displayName;
  String email;
  AccountType accountType;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.accountType,
  });
}

enum AccountType { google, apple }
