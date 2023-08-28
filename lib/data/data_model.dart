

class Service {
  String id = "";
  String libelle = "";
  String description = "";
  String qualite_de_service = "";
  int qualite_de_service_id = 0;
  late DateTime lastUpdate;

  Service(this.id, this.libelle, this.description, this.qualite_de_service,
      this.qualite_de_service_id, this.lastUpdate);

  // Service.fromJson(Map<String, dynamic> json) {
  //   id = json['id'].toString();
  //   libelle = json['libelle'];
  //   description = json['description'];
  //   qualite_de_service = json['qualiteDeService']['libelle'];
  //   qualite_de_service_id = json['qualiteDeService']['id'];
  // }

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    libelle = json['attributes']['libelle'];
    description = json['attributes']['description'];
    qualite_de_service = json['attributes']['qualite_de_service']['data']['attributes']['libelle'];
    qualite_de_service_id = json['attributes']['qualite_de_service']['data']['id'];
    lastUpdate = DateTime.parse(json['attributes']['updatedAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['libelle'] = libelle;
    data['description'] = description;
    data['qualiteDeService']['libelle'] = qualite_de_service;
    data['qualiteDeService']['id'] = qualite_de_service_id;
    data['updatedAt'] = lastUpdate;
    return data;
  }
}
