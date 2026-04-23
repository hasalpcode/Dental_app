import 'dart:convert';
import 'dart:io';
import 'package:dental_app/core/features/projects/data/project_model.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:http/http.dart' as http;

class ProjectRemoteDataSource {
  final String baseUrl = 'https://117d-46-193-66-177.ngrok-free.app';

  Future<Map<String, String>> _getHeaders() async {
    final token = await UserStorage.getToken();
    if (token == null) throw Exception('Utilisateur non connecté');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // for projects
  Future<List<ProjectModel>> getProjects() async {
    final headers = await _getHeaders();
    final response = await http.get(
        Uri.parse('$baseUrl/member-service/api/projects'),
        headers: headers);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((project) => ProjectModel.fromJson(project))
          .toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  Future<ProjectModel> addProject(ProjectModel project) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/member-service/api/projects'),
      headers: headers,
      body: json.encode(project.toJson()),
    );
    if (response.statusCode == 201) {
      return ProjectModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add project');
    }
  }

  Future<ProjectModel> updateProject(ProjectModel project) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/member-service/api/projects/${project.projectId}'),
      headers: headers,
      body: json.encode(project.toJson()),
    );

    print("PR PROJECT RESPONSE: ${response.statusCode} - ${response.body}");
    if (response.statusCode == 200) {
      return ProjectModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update project');
    }
  }

  Future<void> deleteProject(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
        Uri.parse('$baseUrl/member-service/api/projects/$id'),
        headers: headers);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete project');
    }
  }
}
