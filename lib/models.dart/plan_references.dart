class PlanReference {
  String planReferenceId, planId, hyperlink, description;

  PlanReference(
      this.planReferenceId, this.planId, this.hyperlink, this.description);

  static PlanReference fromJson(Map<String, dynamic> json) {
    return PlanReference(json['planReferenceId'], json['planId'] ?? "",
        json['hyperLink'] ?? "", json['description']);
  }

  static PlanReference newReference(String planId) {
    return PlanReference(
        DateTime.now().millisecondsSinceEpoch.toString(), planId, "", "");
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hyperLink': hyperlink,
      'description': description
    };
  }
}
