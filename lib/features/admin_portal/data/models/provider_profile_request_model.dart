class ProviderProfileRequestModel {
  const ProviderProfileRequestModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.requestedChanges,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  final String id;
  final String providerId;
  final String providerName;
  final Map<String, dynamic> requestedChanges;
  final String status;
  final String? rejectionReason;
  final String createdAt;

  factory ProviderProfileRequestModel.fromJson(Map<String, dynamic> json) {
    String pId = '';
    String pName = 'Provider';

    final pRaw = json['providerId'] ?? json['provider_id'];
    if (pRaw is Map<String, dynamic>) {
      pId = (pRaw['_id'] ?? pRaw['id'] ?? '').toString();
      pName = (pRaw['shopName'] ?? pRaw['name'] ?? 'Provider').toString();
    } else if (pRaw != null) {
      pId = pRaw.toString();
    }

    final changes = json['requestedChanges'] ?? json['requested_changes'];
    final changesMap = changes is Map<String, dynamic> ? changes : <String, dynamic>{};

    return ProviderProfileRequestModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      providerId: pId,
      providerName: pName,
      requestedChanges: changesMap,
      status: (json['status'] as String?) ?? 'pending',
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: (json['createdAt'] as String?) ?? (json['created_at'] as String?) ?? '',
    );
  }
}
