import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/models.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';

class SubZeroProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _reminderPrefsKey = 'subscription_reminders';

  SubZeroProvider({AppThemeMode? initialThemeMode}) {
    _themeMode = initialThemeMode ?? AppThemeMode.light;
    loadCategories();
    _loadReminderPrefs();
  }

  AppThemeMode _themeMode = AppThemeMode.light;
  AppThemeMode get themeMode => _themeMode;

  /// Erinnerung pro Abo: subId -> Tage davor (0 = aus, 5/15/25 = an)
  Map<int, int> _reminderPrefs = {};
  Map<int, int> get reminderPrefs => Map.unmodifiable(_reminderPrefs);

  int getReminderDays(int subId) => _reminderPrefs[subId] ?? 0;

  // URL
  final String _baseUrl = apiBaseUrl;

  // Auth
  int? _loggedInUserId;
  String? _loggedInUsername;
  String? _loggedInEmail;

  int? get loggedInUserId => _loggedInUserId;
  String? get loggedInUsername => _loggedInUsername;
  String? get loggedInEmail => _loggedInEmail;
  bool get isLoggedIn => _loggedInUserId != null;

  // Categories
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  // Subscriptions
  List<Subscription> _subscriptions = [];
  List<Subscription> get subscriptions => _subscriptions;

  // Stats
  StatsTotal? _statsTotal;
  StatsTotal? get statsTotal => _statsTotal;

  List<StatsByCategoryItem> _statsByCategory = [];
  List<StatsByCategoryItem> get statsByCategory => _statsByCategory;

  // User (für Settings)
  User? _user;
  User? get user => _user;

  /// Währungssymbol basierend auf User-Präferenz (isEur).
  String get currencySymbol => (_user?.isEur ?? true) ? '€' : '\$';

  // -----------------------------
  // THEME
  // -----------------------------

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.storageKey);
    } catch (_) {}
  }

  // -----------------------------
  // REMINDER PREFS (SharedPreferences, geräteabhängig)
  // -----------------------------

  Future<void> _loadReminderPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_reminderPrefsKey);
      if (json != null) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _reminderPrefs = map.map((k, v) => MapEntry(int.parse(k), v as int));
      }
      notifyListeners();
    } catch (_) {
      _reminderPrefs = {};
    }
  }

  Future<void> setReminderPref(int subId, int daysBefore) async {
    if (daysBefore == 0) {
      _reminderPrefs.remove(subId);
    } else {
      _reminderPrefs[subId] = daysBefore;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _reminderPrefs.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(_reminderPrefsKey, jsonEncode(map));
    } catch (_) {}

    final sub = _subscriptions.where((s) => s.id == subId).firstOrNull;
    if (sub != null) {
      if (daysBefore > 0) {
        await ReminderService().updateReminder(
          subId: subId,
          title: sub.title,
          nextPaymentDate: sub.nextReminderDate,
          daysBefore: daysBefore,
        );
      } else {
        await ReminderService().cancelReminder(subId);
      }
    }
  }

  // -----------------------------
  // AUTH
  // -----------------------------

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _loggedInUserId = data['id'] as int;
        _loggedInUsername = data['username'] as String?;
        _loggedInEmail = data['email'] as String?;
        notifyListeners();
        if (_loggedInUserId != null) {
          loadSubscriptions(_loggedInUserId!);
          loadStatsTotal(_loggedInUserId!);
          loadStatsByCategory(_loggedInUserId!);
          loadUser(_loggedInUserId!);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Gibt null bei Erfolg zurück, sonst die Fehlermeldung (z.B. "Username already exists").
  Future<String?> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _loggedInUserId = data['id'] as int;
        _loggedInUsername = data['username'] as String?;
        _loggedInEmail = data['email'] as String?;
        notifyListeners();
        if (_loggedInUserId != null) {
          loadSubscriptions(_loggedInUserId!);
          loadStatsTotal(_loggedInUserId!);
          loadStatsByCategory(_loggedInUserId!);
          loadUser(_loggedInUserId!);
        }
        return null;
      }
      if (response.statusCode == 409) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['error'] as String? ?? 'Registrierung fehlgeschlagen';
      }
      return 'Registrierung fehlgeschlagen';
    } catch (e) {
      return 'Verbindungsfehler – Backend erreichbar?';
    }
  }

  void logout() {
    _loggedInUserId = null;
    _loggedInUsername = null;
    _loggedInEmail = null;
    _subscriptions = [];
    _statsTotal = null;
    _statsByCategory = [];
    _user = null;
    _family = null;
    _familyMembers = [];
    _familyMembersWithStats = [];
    _familyTotal = null;
    _familyCurrency = 'EUR';
    notifyListeners();
  }

  // -----------------------------
  // LOAD
  // -----------------------------

  void loadCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _categories = data
            .map((x) => Category.fromJson(x as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _categories = [];
      notifyListeners();
    }
  }

  Future<void> loadUser(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users/$userId'));
      if (response.statusCode == 200) {
        _user = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        if (_user?.familyId != null) {
          _loadFamilyData();
        } else {
          _family = null;
          _familyMembers = [];
          _familyTotal = null;
        }
        notifyListeners();
      }
    } catch (e) {
      _user = null;
      notifyListeners();
    }
  }

  void loadSubscriptions(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/subscriptions/$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _subscriptions = data
            .map((x) => Subscription.fromJson(x as Map<String, dynamic>))
            .toList();
        _rescheduleAllReminders();
        notifyListeners();
      }
    } catch (e) {
      _subscriptions = [];
      notifyListeners();
    }
  }

  void loadStatsTotal(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/stats/$userId/total'));
      if (response.statusCode == 200) {
        _statsTotal = StatsTotal.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      _statsTotal = null;
      notifyListeners();
    }
  }

  void loadStatsByCategory(int userId) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/stats/$userId/by-category'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _statsByCategory = data
            .map((x) => StatsByCategoryItem.fromJson(x as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _statsByCategory = [];
      notifyListeners();
    }
  }

  void _reloadUserData() {
    if (_loggedInUserId != null) {
      loadSubscriptions(_loggedInUserId!);
      loadStatsTotal(_loggedInUserId!);
      loadStatsByCategory(_loggedInUserId!);
      if (_user?.familyId != null) {
        _loadFamilyData();
      }
    }
  }

  /// Plant alle gespeicherten Erinnerungen neu (nach Sub-Load).
  Future<void> _rescheduleAllReminders() async {
    for (final sub in _subscriptions) {
      final days = _reminderPrefs[sub.id];
      if (days != null && days > 0) {
        ReminderService().updateReminder(
          subId: sub.id,
          title: sub.title,
          nextPaymentDate: sub.nextReminderDate,
          daysBefore: days,
        );
      }
    }
  }

  // -----------------------------
  // SUBSCRIPTIONS (CRUD)
  // -----------------------------

  Future<bool> addSubscription(SubscriptionInput data) async {
    if (_loggedInUserId == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions/$_loggedInUserId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );
      if (response.statusCode == 201) {
        _reloadUserData();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void updateSubscription(int subId, SubscriptionInput data) async {
    if (_loggedInUserId == null) return;
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/subscriptions/$_loggedInUserId/$subId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );
      if (response.statusCode == 200) {
        _reloadUserData();
      }
    } catch (e) {
      _reloadUserData();
    }
  }

  void deleteSubscription(int subId) async {
    if (_loggedInUserId == null) return;
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/subscriptions/$_loggedInUserId/$subId'),
      );
      if (response.statusCode == 200) {
        _reloadUserData();
      }
    } catch (e) {
      _reloadUserData();
    }
  }

  // -----------------------------
  // USER
  // -----------------------------

  Future<void> updateUserCurrency(bool isEur) async {
    if (_loggedInUserId == null || _user == null) return;
    final previousUser = _user!;
    _user = User(
      id: previousUser.id,
      username: previousUser.username,
      email: previousUser.email,
      familyId: previousUser.familyId,
      isEur: isEur,
    );
    notifyListeners();
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$_loggedInUserId/currency'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isEur': isEur}),
      );
      if (response.statusCode == 200) {
        _reloadUserData();
      } else {
        _user = previousUser;
        notifyListeners();
      }
    } catch (e) {
      _user = previousUser;
      notifyListeners();
    }
  }

  // -----------------------------
  // FAMILY
  // -----------------------------

  Family? _family;
  List<FamilyMember> _familyMembers = [];
  List<FamilyMemberWithStats> _familyMembersWithStats = [];
  double? _familyTotal;
  String _familyCurrency = 'EUR';

  Family? get family => _family;
  List<FamilyMember> get familyMembers => _familyMembers;
  List<FamilyMemberWithStats> get familyMembersWithStats => _familyMembersWithStats;
  double? get familyTotal => _familyTotal;
  String get familyCurrency => _familyCurrency;

  Future<String?> createFamily(String name) async {
    if (_loggedInUserId == null) return 'Nicht eingeloggt';
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/families/$_loggedInUserId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _family = Family.fromJson(data);
        await loadUser(_loggedInUserId!);
        _loadFamilyData();
        return null;
      }
      if (response.statusCode == 409) {
        return 'Du bist bereits in einer Family';
      }
      return 'Fehler beim Erstellen';
    } catch (e) {
      return 'Verbindungsfehler';
    }
  }

  Future<String?> joinFamily(String inviteCode) async {
    if (_loggedInUserId == null) return 'Nicht eingeloggt';
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/families/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _loggedInUserId,
          'inviteCode': inviteCode.trim().toUpperCase(),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _family = Family.fromJson(data);
        await loadUser(_loggedInUserId!);
        _loadFamilyData();
        return null;
      }
      if (response.statusCode == 404) {
        return 'Ungültiger Einladungscode';
      }
      if (response.statusCode == 409) {
        return 'Du bist bereits in einer Family';
      }
      return 'Fehler beim Beitreten';
    } catch (e) {
      return 'Verbindungsfehler';
    }
  }

  void _loadFamilyData() {
    if (_loggedInUserId != null && _user?.familyId != null) {
      _loadFamily(_user!.familyId!);
      _loadFamilyMembers(_user!.familyId!);
      _loadFamilyMembersWithStats(_user!.familyId!);
      _loadFamilyStats(_user!.familyId!);
    } else {
      _family = null;
      _familyMembers = [];
      _familyMembersWithStats = [];
      _familyTotal = null;
      _familyCurrency = 'EUR';
      notifyListeners();
    }
  }

  void loadFamilyData() {
    _loadFamilyData();
  }

  void _loadFamily(int familyId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/families/$familyId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _family = Family.fromJson(data);
        notifyListeners();
      }
    } catch (_) {
      _family = null;
      notifyListeners();
    }
  }

  void _loadFamilyMembers(int familyId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/families/$familyId/members'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _familyMembers = data.map((x) => FamilyMember.fromJson(x as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (_) {
      _familyMembers = [];
      notifyListeners();
    }
  }

  void _loadFamilyMembersWithStats(int familyId) async {
    try {
      final url = Uri.parse('$_baseUrl/families/$familyId/members-with-stats').replace(
        queryParameters: {'userId': _loggedInUserId.toString()},
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        _familyMembersWithStats = data
            .map((x) => FamilyMemberWithStats.fromJson(x as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (_) {
      _familyMembersWithStats = [];
      notifyListeners();
    }
  }

  void _loadFamilyStats(int familyId) async {
    try {
      final url = Uri.parse('$_baseUrl/families/$familyId/stats/total').replace(
        queryParameters: {'userId': _loggedInUserId.toString()},
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _familyTotal = (data['total'] as num).toDouble();
        _familyCurrency = data['currency'] as String? ?? 'EUR';
        notifyListeners();
      }
    } catch (_) {
      _familyTotal = null;
      notifyListeners();
    }
  }
}
