/// UserModel class for storing user data
class UserModel {
  final String uid;
  final String email;
  final String username;
  final String name;
  final String surname;
  final String profilePic;

  static const collectionName = "user";

  /// UserModel constructor
  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.name,
    required this.surname,
    required this.profilePic,
  });

  /// UserModel copyWith method for copying a UserModel object
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? name,
    String? surname,
    String? profilePic,
    bool? isLightMode,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  /// UserModel toMap method for converting a UserModel object to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'username': username,
      'name': name,
      'surname': surname,
      'profilePic': profilePic,
    };
  }

  /// UserModel fromMap method for converting a Map<String, dynamic> to a UserModel object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      profilePic: map['profilePic'] as String,
    );
  }

  /// UserModel toString method for printing a UserModel object
  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, username: $username, name: $name, surname: $surname, profilePic: $profilePic)';
  }

  /// UserModel operator == method for comparing two UserModel objects, returns true if they have the same values
  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.username == username &&
        other.name == name &&
        other.surname == surname &&
        other.profilePic == profilePic;
  }

  /// UserModel hashCode getter for generating a hash code for a UserModel object
  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        username.hashCode ^
        name.hashCode ^
        surname.hashCode ^
        profilePic.hashCode;
  }
}
