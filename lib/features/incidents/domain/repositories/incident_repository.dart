import '../entities/incident_comment_entity.dart';
import '../entities/incident_entity.dart';

abstract class IncidentRepository {
  Future<List<IncidentEntity>> getIncidents({int skip = 0, int limit = 100, String? statusFilter, String? priorityFilter, bool myOnly = false});
  Future<IncidentEntity> getIncident(String incidentId);
  Future<IncidentEntity> createIncident({
    required String title,
    required String description,
    required String priority,
    String? location,
  });
  Future<IncidentEntity> updateIncidentStatus({
    required String incidentId,
    required String status,
  });
  Future<void> deleteIncident(String incidentId);
  Future<IncidentCommentEntity> addComment(String incidentId, {required String content});
  Future<List<IncidentCommentEntity>> getComments(String incidentId);
}
