import 'dart:io';

import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/projects/data/project_remote_data_source.dart';
import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectEntity project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final _dataSource = ProjectRemoteDataSource();
  final _picker = ImagePicker();

  List<String> _imageUrls = [];
  bool _loadingImages = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final id = widget.project.projectId;
    if (id == null) return;
    setState(() => _loadingImages = true);
    try {
      final urls = await _dataSource.getProjectImages(id);
      if (mounted) setState(() => _imageUrls = urls);
    } catch (_) {
      // endpoint images pas encore implémenté côté serveur
    } finally {
      if (mounted) setState(() => _loadingImages = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final id = widget.project.projectId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID du projet introuvable')),
      );
      return;
    }
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      await _dataSource.uploadProjectImage(id, File(picked.path));
      await _loadImages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur upload : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ---- UI helpers ----

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'EN_COURS':
      case 'EN COURS':
        return Colors.blue;
      case 'TERMINE':
      case 'TERMINÉ':
        return Colors.green;
      case 'ANNULE':
      case 'ANNULÉ':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text(
            '$label : ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final p = widget.project;
    final date = p.dateCreation;
    final dateStr = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
        : 'N/A';

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.libelle,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                if (p.status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(p.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _statusColor(p.status)),
                    ),
                    child: Text(
                      p.status!,
                      style: TextStyle(
                          color: _statusColor(p.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            if (p.budget != null)
              _infoRow(Icons.attach_money, 'Budget',
                  '${p.budget!.toStringAsFixed(0)} Fcfa'),
            if (p.bureauId != null)
              _infoRow(Icons.corporate_fare, 'Bureau', '${p.bureauId}'),
            _infoRow(Icons.calendar_today, 'Créé le', dateStr),
            if (p.description != null && p.description!.isNotEmpty)
              _infoRow(Icons.description, 'Description', p.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Photos du projet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_imageUrls.length} photo${_imageUrls.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loadingImages)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ))
          else if (_imageUrls.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('Aucune photo',
                      style: TextStyle(color: Colors.grey[500])),
                  const SizedBox(height: 4),
                  Text('Appuyez sur + pour en ajouter',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[400])),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () => _showImageFullscreen(_imageUrls[i]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrls[i],
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showImageFullscreen(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canModify =
        Provider.of<AuthProvider>(context, listen: false).canModify;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project.libelle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: canModify
          ? FloatingActionButton.extended(
              onPressed: _uploading ? null : _pickAndUpload,
              backgroundColor: Colors.deepPurple,
              icon: _uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_a_photo),
              label:
                  Text(_uploading ? 'Envoi en cours...' : 'Ajouter une photo'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadImages,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              _buildImagesSection(),
            ],
          ),
        ),
      ),
    );
  }
}
