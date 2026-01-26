class UpdateInfo {
  final String version;
  final String url;
  final String? changelog;

  UpdateInfo({
    required this.version,
    required this.url,
    this.changelog,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] as String,
      url: json['url'] as String,
      changelog: json['changelog'] as String?,
    );
  }
}