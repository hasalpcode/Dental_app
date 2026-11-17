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

const List<String> _roleOptions = ['USER', 'COMPTABLE', 'ADMIN'];

/// role_id de repli si un rôle n'a jamais encore été observé dans les
/// memberships du tenant (ADMIN est toujours présent — le propriétaire —
/// donc seuls USER/COMPTABLE ont besoin de ce repli sur un tenant neuf).
const Map<String, int> _fallbackRoleIds = {'USER': 1, 'COMPTABLE': 3};

/// Réservé à ADMIN : assigner ou retirer un rôle (USER/COMPTABLE/ADMIN) à un
/// membre. Indépendant de toute affectation à un bureau (voir
/// BureauDetailPage). Le backend applique en plus une limite de 3 COMPTABLE
/// et 2 ADMIN par tenant (409 si dépassée).
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
  Map<String, int> _roleIdByName = {};
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

      final roleByUserId = <int, String>{};
      final roleIdByName = Map<String, int>.from(_fallbackRoleIds);
      for (final m in memberships) {
        final userId = m.userId as int;
        final roleName = (m.roleName as String).toUpperCase();
        roleByUserId[userId] = roleName;
        roleIdByName[roleName] = m.roleId as int;
      }

      setState(() {
        _members = members;
        _roleByUserId = roleByUserId;
        _roleIdByName = roleIdByName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changeRole(Member member, String newRole) async {
    final userId = member.userId;
    final roleId = _roleIdByName[newRole];
    if (userId == null || roleId == null) return;

    setState(() => _updatingUserId = userId);
    try {
      await authDataSource.updateUserRole(userId, roleId);
      setState(() => _roleByUserId[userId] = newRole);
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

    // On ne peut pas changer son propre rôle depuis cet écran (pour éviter
    // de se verrouiller soi-même hors de la gestion des rôles).
    final eligible =
        _members.where((m) => m.userId != null && m.userId != myUserId).toList();

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
        final currentRole = _roleByUserId[member.userId] ?? 'USER';
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
                child: Text(member.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              if (isUpdating)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                DropdownButton<String>(
                  value: currentRole,
                  underline: const SizedBox(),
                  items: _roleOptions
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null && value != currentRole) {
                      _changeRole(member, value);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
