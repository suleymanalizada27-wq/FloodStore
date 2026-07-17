import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Saves/restores a JSON-serializable draft under a namespaced key.
/// Deliberately generic — the Register wizard is the first consumer, but
/// nothing here is register-specific.
///
/// Security note: callers are responsible for never putting a raw password
/// into the map passed to [save] — drafts land in plain `SharedPreferences`,
/// not [SecureTokenService]'s encrypted store, because a "resume my
/// half-finished signup" draft has no reason to be that sensitive if the
/// password field is simply excluded.
class DraftStorageService {
  DraftStorageService({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  String _key(String draftId) => 'floodstore.draft.$draftId';

  Future<void> save(String draftId, Map<String, dynamic> data) async {
    final prefs = await _prefs;
    await prefs.setString(_key(draftId), jsonEncode(data));
  }

  Future<Map<String, dynamic>?> load(String draftId) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_key(draftId));
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear(String draftId) async {
    final prefs = await _prefs;
    await prefs.remove(_key(draftId));
  }

  Future<bool> hasDraft(String draftId) async {
    final prefs = await _prefs;
    return prefs.containsKey(_key(draftId));
  }
}
