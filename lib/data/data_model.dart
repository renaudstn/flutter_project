class Service {
  String id = "";
  String libelle = "";
  String description = "";
  String qualite_de_service = "";
  int qualite_de_service_id = 0;

  Service(
    this.id,
    this.libelle,
    this.description,
    this.qualite_de_service,
    this.qualite_de_service_id,
  );

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    libelle = json['libelle'];
    description = json['description'];
    qualite_de_service = json['qualiteDeService']['libelle'];
    qualite_de_service_id = json['qualiteDeService']['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id.toString();
    data['libelle'] = this.libelle;
    data['description'] = this.description;
    data['qualiteDeService']['libelle'] = this.qualite_de_service;
    data['qualiteDeService']['id'] = this.qualite_de_service_id;
    return data;
  }
}
