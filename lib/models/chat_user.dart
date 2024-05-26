class ChatUser {
  final String uid;
  final String name;
  final String email;
  final String imageURL;
  late DateTime lastActive;
  late String symmetric_key; // Anahtar bilgisi eklendi

  ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageURL,
    required this.lastActive,
    required this.symmetric_key, // Constructor'a eklendi
  });

  // Boş bir ChatUser nesnesi döndürür
  static ChatUser empty() {
    return ChatUser(
      uid: '',
      name: '',
      email: '',
      imageURL: '',
      lastActive: DateTime.now(),
      symmetric_key: '', // Anahtar bilgisi için boş değer
    );
  }

  factory ChatUser.fromJSON(Map<String, dynamic> _json) {
    return ChatUser(
      uid: _json["uid"],
      name: _json["name"],
      email: _json["email"],
      imageURL: _json["image"],
      lastActive: _json["last_active"].toDate(),
      symmetric_key: _json["symmetric_key"], // JSON'dan symmetric_key çekiliyor
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "name": name,
      "last_active": lastActive,
      "image": imageURL,
      "symmetric_key": symmetric_key, // Map'e eklendi
    };
  }

  String lastDayActive() {
    return "${lastActive.month}/${lastActive.day}/${lastActive.year}";
  }

  bool wasRecentlyActive() {
    return DateTime.now().difference(lastActive).inHours < 2;
  }
}
