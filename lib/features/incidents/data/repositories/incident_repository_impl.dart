import '../../domain/entities/incident_comment_entity.dart';
import '../../domain/entities/incident_entity.dart';
import '../../domain/repositories/incident_repository.dart';
import '../datasources/incident_remote_datasource.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentRemoteDataSource remoteDataSource;

  IncidentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<IncidentEntity>> getIncidents({int skip = 0, int limit = 100, String? statusFilter, String? priorityFilter, bool myOnly = false}) async {
    return (await remoteDataSource.getIncidents(skip: skip, limit: limit, statusFilter: statusFilter, priorityFilter: priorityFilter, myOnly: myOnly)).cast<IncidentEntity>();
  }

  @override
  Future<IncidentEntity> getIncident(String incidentId) async {
    return await remoteDataSource.getIncident(incidentId) as IncidentEntity;
  }

  @override
  Future<IncidentEntity> createIncident({
    required String title,
    required String description,
    required String priority,
    String? location,
  }) async {
    return await remoteDataSource.createIncident(
      title: title,
      description: description,
      priority: priority,
      location: location,
    ) as IncidentEntity;
  }

  @override
  Future<IncidentEntity> updateIncidentStatus({
    required String incidentId,
    required String status,
  }) async {
    return await remoteDataSource.updateIncidentStatus(
      incidentId: incidentId,
      status: status,
    ) as IncidentEntity;
  }

  @override
  Future<void> deleteIncident(String incidentId) async {
    await remoteDataSource.deleteIncident(incidentId);
  }

  @override
  Future<IncidentCommentEntity> addComment(String incidentId, {required String content}) async {
    return await remoteDataSource.addComment(incidentId, content: content);
  }

  @override
  Future<List<IncidentCommentEntity>> getComments(String incidentId) async {
    return (await remoteDataSource.getComments(incidentId)).cast<IncidentCommentEntity>();
  }
}
