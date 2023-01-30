class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? regdate;
  String? credit;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.regdate,
      required this.credit});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    regdate = json['regdate'];
    credit = json['credit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['regdate'] = regdate;
    data['credit'] = credit;

    return data;
  }
}
