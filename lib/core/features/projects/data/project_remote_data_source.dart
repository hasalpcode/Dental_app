import 'dart:convert';
import 'dart:io';
import 'package:dental_app/core/features/projects/data/project_model.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:http/http.dart' as http;

class ProjectRemoteDataSource {
  final String baseUrl = 'https://c84b-46-193-66-177.ngrok-free.app';

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
      print("PROJECTS RESPONSE: ${response.body}");
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

  Future<List<String>> getProjectImages(int projectId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/member-service/api/imgprojects/$projectId/images'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data
            .map<String>((e) {
              if (e is String) return e;
              if (e is Map) {
                return (e['url'] ?? e['imageUrl'] ?? e['path'] ?? '')
                    .toString();
              }
              return '';
            })
            .where((url) => url.isNotEmpty)
            .toList();
      }
      return [];
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception(
          'Erreur récupération images: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> uploadProjectImage(int projectId, File image) async {
    final token = await UserStorage.getToken();
    if (token == null) throw Exception('Utilisateur non connecté');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/member-service/api/imgprojects/$projectId/images'),
    )..headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamed = await request.send();
    if (streamed.statusCode != 200 && streamed.statusCode != 201) {
      final body = await streamed.stream.bytesToString();
      throw Exception('Erreur upload image: ${streamed.statusCode} - $body');
    }
  }
}

// =============================================================
// SPRING BOOT 2.3 — Images de projet stockées sur Cloudinary
// =============================================================
//
// ── 1. pom.xml — dépendance Cloudinary ───────────────────────
//
// <dependency>
//     <groupId>com.cloudinary</groupId>
//     <artifactId>cloudinary-http44</artifactId>
//     <version>1.34.0</version>
// </dependency>
//
// ── 2. application.properties ────────────────────────────────
//
// cloudinary.cloud-name=VOTRE_CLOUD_NAME
// cloudinary.api-key=VOTRE_API_KEY
// cloudinary.api-secret=VOTRE_API_SECRET
//
// spring.servlet.multipart.enabled=true
// spring.servlet.multipart.max-file-size=10MB
// spring.servlet.multipart.max-request-size=10MB
//
// ── 3. CloudinaryConfig.java ─────────────────────────────────
//
// @Configuration
// public class CloudinaryConfig {
//
//     @Value("${cloudinary.cloud-name}")
//     private String cloudName;
//
//     @Value("${cloudinary.api-key}")
//     private String apiKey;
//
//     @Value("${cloudinary.api-secret}")
//     private String apiSecret;
//
//     @Bean
//     public Cloudinary cloudinary() {
//         return new Cloudinary(ObjectUtils.asMap(
//             "cloud_name", cloudName,
//             "api_key",    apiKey,
//             "api_secret", apiSecret,
//             "secure",     true
//         ));
//     }
// }
//
// ── 4. ProjectImage.java (Entity) ────────────────────────────
//
// @Entity
// @Table(name = "project_images")
// public class ProjectImage {
//
//     @Id
//     @GeneratedValue(strategy = GenerationType.IDENTITY)
//     private Long id;
//
//     @Column(nullable = false)
//     private Long projectId;
//
//     @Column(nullable = false)
//     private String url;            // URL HTTPS Cloudinary
//
//     @Column(nullable = false)
//     private String publicId;       // identifiant Cloudinary (pour suppression)
//
//     @Column
//     private String originalName;
//
//     @Column
//     private String contentType;
//
//     @Column(nullable = false, updatable = false)
//     private LocalDateTime uploadedAt;
//
//     @PrePersist
//     protected void onCreate() { uploadedAt = LocalDateTime.now(); }
//
//     // getters / setters
// }
//
// ── 5. ProjectImageRepository.java ───────────────────────────
//
// @Repository
// public interface ProjectImageRepository
//         extends JpaRepository<ProjectImage, Long> {
//
//     List<ProjectImage> findByProjectIdOrderByUploadedAtDesc(Long projectId);
//
//     Optional<ProjectImage> findByPublicId(String publicId);
// }
//
// ── 6. ProjectImageService.java ──────────────────────────────
//
// @Service
// public class ProjectImageService {
//
//     @Autowired
//     private Cloudinary cloudinary;
//
//     @Autowired
//     private ProjectImageRepository repository;
//
//     /** Upload vers Cloudinary et persiste les métadonnées en base. */
//     public ProjectImage save(Long projectId, MultipartFile file)
//             throws IOException {
//
//         Map<?, ?> result = cloudinary.uploader().upload(
//             file.getBytes(),
//             ObjectUtils.asMap(
//                 "folder",        "projects/" + projectId,
//                 "resource_type", "image",
//                 "overwrite",     false
//             )
//         );
//
//         ProjectImage img = new ProjectImage();
//         img.setProjectId(projectId);
//         img.setUrl((String) result.get("secure_url"));
//         img.setPublicId((String) result.get("public_id"));
//         img.setOriginalName(file.getOriginalFilename());
//         img.setContentType(file.getContentType());
//
//         return repository.save(img);
//     }
//
//     public List<ProjectImage> findByProject(Long projectId) {
//         return repository.findByProjectIdOrderByUploadedAtDesc(projectId);
//     }
//
//     /** Supprime l'image de Cloudinary et de la base. */
//     public void delete(Long imageId) throws IOException {
//         ProjectImage img = repository.findById(imageId)
//             .orElseThrow(() -> new RuntimeException("Image introuvable"));
//
//         cloudinary.uploader().destroy(
//             img.getPublicId(),
//             ObjectUtils.asMap("resource_type", "image")
//         );
//
//         repository.delete(img);
//     }
// }
//
// ── 7. ProjectImageController.java ───────────────────────────
//
// @RestController
// @RequestMapping("/api/projects")
// public class ProjectImageController {
//
//     @Autowired
//     private ProjectImageService imageService;
//
//     /** POST /api/projects/{id}/images  (multipart, champ "file") */
//     @PostMapping("/{projectId}/images")
//     public ResponseEntity<Map<String, Object>> upload(
//             @PathVariable Long projectId,
//             @RequestParam("file") MultipartFile file) throws IOException {
//
//         ProjectImage saved = imageService.save(projectId, file);
//
//         Map<String, Object> body = new HashMap<>();
//         body.put("id",           saved.getId());
//         body.put("url",          saved.getUrl());
//         body.put("publicId",     saved.getPublicId());
//         body.put("uploadedAt",   saved.getUploadedAt());
//
//         return ResponseEntity.status(HttpStatus.CREATED).body(body);
//     }
//
//     /** GET /api/projects/{id}/images */
//     @GetMapping("/{projectId}/images")
//     public ResponseEntity<List<Map<String, Object>>> getImages(
//             @PathVariable Long projectId) {
//
//         List<Map<String, Object>> result = imageService
//             .findByProject(projectId)
//             .stream()
//             .map(img -> {
//                 Map<String, Object> m = new HashMap<>();
//                 m.put("id",           img.getId());
//                 m.put("url",          img.getUrl());         // URL Cloudinary directe
//                 m.put("originalName", img.getOriginalName());
//                 m.put("uploadedAt",   img.getUploadedAt());
//                 return m;
//             })
//             .collect(Collectors.toList());
//
//         return ResponseEntity.ok(result);
//     }
//
//     /** DELETE /api/projects/{id}/images/{imageId} */
//     @DeleteMapping("/{projectId}/images/{imageId}")
//     public ResponseEntity<Void> deleteImage(
//             @PathVariable Long projectId,
//             @PathVariable Long imageId) throws IOException {
//
//         imageService.delete(imageId);
//         return ResponseEntity.noContent().build();
//     }
// }
//
// ── 8. Imports nécessaires ───────────────────────────────────
//
// import com.cloudinary.Cloudinary;
// import com.cloudinary.utils.ObjectUtils;
// import org.springframework.http.*;
// import org.springframework.web.bind.annotation.*;
// import org.springframework.web.multipart.MultipartFile;
// import javax.persistence.*;
// import java.io.IOException;
// import java.time.LocalDateTime;
// import java.util.*;
// import java.util.stream.Collectors;
//
// ── 9. Note sécurité ─────────────────────────────────────────
//
// Les URLs Cloudinary sont publiques par défaut — aucun token
// nécessaire pour Image.network() côté Flutter.
// Pour restreindre l'accès, activez "Strict Transformations" ou
// utilisez des signed URLs dans Cloudinary.
// =============================================================
