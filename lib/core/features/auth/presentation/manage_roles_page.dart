import 'package:dental_app/core/features/auth/data/remote_data_auth_source.dart';
import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// role_id 1 = USER, role_id 3 = COMPTABLE (table role côté user-service).
int _roleIdForRole(String role) => role.toUpperCase() == 'COMPTABLE' ? 3 : 1;

/// Réservé à ADMIN : assigner ou retirer le rôle COMPTABLE à un membre.
/// Indépendant de toute affectation à un bureau (voir BureauDetailPage).
class ManageRolesPage extends StatefulWidget {
  const ManageRolesPage({super.key});

  @override
  State<ManageRolesPage> createState() => _ManageRolesPageState();
}

class _ManageRolesPageState extends State<ManageRolesPage> {
  late final AuthRemoteDataSource authDataSource;
  late final GetMembers getMembers;

  bool _isLoading = true;
  String? _error;
  List<Member> _members = [];
  Map<int, String> _roleByUserId = {};
  int? _updatingUserId;

  @override
  void initState() {
    super.initState();
    authDataSource = AuthRemoteDataSource(ApiClient.instance);
    final memberRepo =
        MemberRepositoryImpl(MemberRemoteDataSource(ApiClient.instance));
    getMembers = GetMembers(memberRepo);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        getMembers(),
        authDataSource.getTenantMemberships(),
      ]);
      final members = results[0] as List<Member>;
      final memberships = results[1] as List;

      setState(() {
        _members = members;
        _roleByUserId = {
          for (final m in memberships) m.userId as int: m.roleName as String,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleComptable(Member member, bool makeComptable) async {
    final userId = member.userId;
    if (userId == null) return;

    setState(() => _updatingUserId = userId);
    try {
      final roleId = _roleIdForRole(makeComptable ? 'COMPTABLE' : 'USER');
      await authDataSource.updateUserRole(userId, roleId);
      setState(() {
        _roleByUserId[userId] = makeComptable ? 'COMPTABLE' : 'USER';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CurvedAppBar(
        title: 'Gérer les rôles',
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _buildList(),
                ),
    );
  }

  Widget _buildList() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final myUserId = auth.user?.userId;

    // L'ADMIN (propriétaire du tenant) ne se gère pas lui-même ici, et pas
    // de membre sans compte utilisateur associé.
    final eligible = _members.where((m) {
      if (m.userId == null || m.userId == myUserId) return false;
      final role = _roleByUserId[m.userId]?.toUpperCase();
      return role != 'ADMIN';
    }).toList();

    if (eligible.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Aucun membre à gérer.'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eligible.length,
      itemBuilder: (context, index) {
        final member = eligible[index];
        final isComptable =
            _roleByUserId[member.userId]?.toUpperCase() == 'COMPTABLE';
        final isUpdating = _updatingUserId == member.userId;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xff0b5260).withOpacity(0.12),
                child: Text(
                  member.displayName.isNotEmpty
                      ? member.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Color(0xff0b5260), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.displayName,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      isComptable ? 'Rôle : COMPTABLE' : 'Rôle : USER',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isUpdating)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch(
                  value: isComptable,
                  activeColor: const Color(0xfff08024),
                  onChanged: (value) => _toggleComptable(member, value),
                ),
            ],
          ),
        );
      },
    );
  }
}
