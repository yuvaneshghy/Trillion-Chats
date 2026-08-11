import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/MessageModel.dart';
import '../Model/ChatModel.dart';
import '../Model/ContactModel.dart';
import '../Model/CallModel.dart';
import '../Model/StatusModel.dart';
import '../Model/UserModel.dart';
import '../Theme/AppColors.dart';

class _ServerMessage {
  final String from;
  final String to;
  final String text;
  final String time;
  final double ts;
  bool read;

  _ServerMessage({
    required this.from,
    required this.to,
    required this.text,
    required this.time,
    required this.ts,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'text': text,
        'time': time,
        'ts': ts,
        'read': read,
      };

  factory _ServerMessage.fromJson(Map<String, dynamic> json) {
    return _ServerMessage(
      from: json['from'] as String,
      to: json['to'] as String,
      text: json['text'] as String,
      time: json['time'] as String,
      ts: (json['ts'] as num).toDouble(),
      read: json['read'] == true,
    );
  }
}

class AppState extends ChangeNotifier {
  AppState._() {
    _seedCalls();
    _seedStatuses();
  }

  static final AppState instance = AppState._();

  UserModel? _currentUser;
  final List<UserModel> _users = [];
  final Map<String, List<_ServerMessage>> _messages = {};
  final Map<String, ChatModel> _conversations = {};
  final List<ChatModel> _localGroups = [];
  final List<CallModel> _calls = [];
  final List<StatusModel> _statuses = [];
  final StatusModel _myStatus = StatusModel(
    name: 'My status',
    time: 'Today, 7:30 AM',
    color: AppColors.whatsappGreen,
    gradient: const [Color(0xFF25D366), Color(0xFF128C7E)],
    isMyStatus: true,
    content: 'Hey there! I am using Trillion Chats',
  );

  bool get isLoggedIn => _currentUser != null;
  UserModel? get currentUser => _currentUser;

  List<ChatModel> get chats {
    final list = [..._conversations.values, ..._localGroups];
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.lastTs.compareTo(a.lastTs);
    });
    return List.unmodifiable(list);
  }

  List<ContactModel> get contacts => _users
      .where((u) => u.username.toLowerCase() != (_currentUser?.username ?? '').toLowerCase())
      .map((u) =>
          ContactModel(name: u.username, status: u.status, color: u.color))
      .toList();

  List<CallModel> get calls => List.unmodifiable(_calls);
  List<StatusModel> get statuses => List.unmodifiable(_statuses);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = null;
    _users.clear();
    _messages.clear();
    _conversations.clear();
    _localGroups.clear();

    final usersJson = prefs.getString('tc_users');
    if (usersJson == null || usersJson.isEmpty) {
      _seedUsers();
      await _persistUsers();
    } else {
      for (final j in jsonDecode(usersJson) as List) {
        _users.add(UserModel.fromJson(j as Map<String, dynamic>));
      }
    }

    final messagesJson = prefs.getString('tc_messages');
    if (messagesJson == null || messagesJson.isEmpty) {
      _seedMessages();
      await _persistMessages();
    } else {
      for (final j in jsonDecode(messagesJson) as List) {
        final m = _ServerMessage.fromJson(j as Map<String, dynamic>);
        _messages.putIfAbsent(_pairKey(m.from, m.to), () => []).add(m);
      }
    }

    final groupsJson = prefs.getString('tc_groups');
    if (groupsJson != null && groupsJson.isNotEmpty) {
      for (final j in jsonDecode(groupsJson) as List) {
        final map = j as Map<String, dynamic>;
        final chat = ChatModel(
          name: map['name'] as String,
          isGroup: true,
          avatarColor: Color(map['color'] as int),
          messages: (map['messages'] as List)
              .map((mm) => MessageModel(
                    text: (mm as Map<String, dynamic>)['text'] as String,
                    time: mm['time'] as String,
                    isSentByMe: mm['me'] == true,
                  ))
              .toList(),
        );
        chat.lastTs = (map['lastTs'] as num?)?.toDouble() ?? 0;
        _localGroups.add(chat);
      }
    }

    final session = prefs.getString('tc_session');
    if (session != null) {
      final user = _findUser(session);
      if (user != null) {
        _currentUser = user;
        _loadConversations();
      }
    }
    notifyListeners();
  }

  UserModel? _findUser(String username) {
    for (final u in _users) {
      if (u.username.toLowerCase() == username.trim().toLowerCase()) return u;
    }
    return null;
  }

  String _pairKey(String a, String b) {
    final list = [a, b]..sort();
    return list.join('|');
  }

  String _fmtTime(double ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts.round());
    final now = DateTime.now();
    final sameDay = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
    if (!sameDay) return '${dt.day}/${dt.month}';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }

  double _now() => DateTime.now().millisecondsSinceEpoch.toDouble();

  void _loadConversations() {
    _conversations.clear();
    final me = _currentUser!.username.toLowerCase();
    final peers = <String>{};
    _messages.forEach((key, msgs) {
      final participants = key.split('|');
      if (participants[0].toLowerCase() == me ||
          participants[1].toLowerCase() == me) {
        final peer = participants[0].toLowerCase() == me
            ? participants[1]
            : participants[0];
        peers.add(peer);
      }
    });
    for (final peer in peers) {
      final user = _findUser(peer);
      if (user != null) {
        _conversations[_pairKey(_currentUser!.username, user.username)] =
            _buildConversation(user);
      }
    }
  }

  ChatModel _buildConversation(UserModel user) {
    final key = _pairKey(_currentUser!.username, user.username);
    final msgs = _messages[key] ?? const [];
    final chat = ChatModel(
      name: user.username,
      isGroup: false,
      avatarColor: user.color,
      messages: msgs
          .map((m) => MessageModel(
                text: m.text,
                time: m.time,
                isSentByMe:
                    m.from.toLowerCase() == _currentUser!.username.toLowerCase(),
                read: m.read,
              ))
          .toList(),
      lastSeen: 'online',
    );
    chat.lastTs =
        msgs.isEmpty ? 0 : msgs.map((m) => m.ts).reduce((a, b) => a > b ? a : b);
    chat.unreadCount = msgs
        .where((m) =>
            m.from.toLowerCase() != _currentUser!.username.toLowerCase() &&
            !m.read)
        .length;
    return chat;
  }

  // ---------- Auth ----------

  Future<bool> login(String username, String password) async {
    final user = _findUser(username);
    if (user == null || user.password != password) return false;
    _currentUser = user;
    _loadConversations();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tc_session', user.username);
    notifyListeners();
    return true;
  }

  Future<bool> signup(String username, String password) async {
    final name = username.trim();
    if (name.isEmpty || _findUser(name) != null) return false;
    final user = UserModel(username: name, password: password);
    _users.add(user);
    _currentUser = user;
    _loadConversations();
    await _persistUsers();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tc_session', user.username);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    _conversations.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tc_session');
    notifyListeners();
  }

  List<UserModel> searchUsers(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final me = _currentUser?.username.toLowerCase() ?? '';
    return _users
        .where((u) =>
            u.username.toLowerCase() != me && u.username.toLowerCase().contains(q))
        .toList();
  }

  ChatModel ensureChatForContact(ContactModel contact) {
    final key = _pairKey(_currentUser!.username, contact.name);
    var chat = _conversations[key];
    if (chat == null) {
      chat = _buildConversation(
        _findUser(contact.name) ??
            UserModel(username: contact.name, password: ''),
      );
      _conversations[key] = chat;
    }
    notifyListeners();
    return chat;
  }

  ChatModel startChat(UserModel user) => ensureChatForContact(
        ContactModel(name: user.username, status: user.status, color: user.color),
      );

  ChatModel createGroup(String name, Color color) {
    final ts = _now();
    final chat = ChatModel(
      name: name,
      isGroup: true,
      avatarColor: color,
      messages: [
        MessageModel(
          text: 'You created group "$name"',
          time: _fmtTime(ts),
          isSentByMe: true,
        ),
      ],
    );
    chat.lastTs = ts;
    _localGroups.add(chat);
    unawaited(_persistGroups());
    notifyListeners();
    return chat;
  }

  // ---------- Messaging ----------

  void sendMessage(ChatModel chat, String text) {
    final ts = _now();
    final display = _fmtTime(ts);
    if (chat.isGroup) {
      chat.messages
          .add(MessageModel(text: text, time: display, isSentByMe: true));
      chat.lastTs = ts;
      unawaited(_persistGroups());
    } else {
      final me = _currentUser!.username;
      final key = _pairKey(me, chat.name);
      _messages.putIfAbsent(key, () => []).add(
            _ServerMessage(from: me, to: chat.name, text: text, time: display, ts: ts),
          );
      chat.messages
          .add(MessageModel(text: text, time: display, isSentByMe: true));
      chat.lastTs = ts;
      unawaited(_persistMessages());
    }
    chat.unreadCount = 0;
    _moveToTop(chat);
    notifyListeners();
  }

  void markChatRead(ChatModel chat) {
    if (chat.isGroup || _currentUser == null) return;
    var changed = false;
    final key = _pairKey(_currentUser!.username, chat.name);
    final msgs = _messages[key];
    if (msgs != null) {
      for (final m in msgs) {
        if (m.from.toLowerCase() != _currentUser!.username.toLowerCase() &&
            !m.read) {
          m.read = true;
          changed = true;
        }
      }
    }
    if (changed) {
      for (final m in chat.messages) {
        if (!m.isSentByMe && !m.read) m.read = true;
      }
      chat.unreadCount = 0;
      unawaited(_persistMessages());
      notifyListeners();
    }
  }

  void _moveToTop(ChatModel chat) {
    _conversations.removeWhere((key, c) => identical(c, chat));
    if (!chat.isGroup && _currentUser != null) {
      _conversations[_pairKey(_currentUser!.username, chat.name)] = chat;
    }
  }

  // ---------- Status / Calls ----------

  void addCall(ContactModel contact) {
    _calls.insert(
      0,
      CallModel(
        name: contact.name,
        time: 'Today, ${_fmtTime(_now())}',
        isVideo: false,
        isIncoming: false,
        isMissed: false,
        color: contact.color,
      ),
    );
    notifyListeners();
  }

  void updateMyStatus(String text) {
    _myStatus
      ..content = text
      ..time = 'Today, ${_fmtTime(_now())}';
    notifyListeners();
  }

  void markStatusSeen(StatusModel status) {
    if (!status.isSeen) {
      status.isSeen = true;
      notifyListeners();
    }
  }

  // ---------- Persistence ----------

  Future<void> _persistUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'tc_users',
      jsonEncode(_users.map((u) => u.toJson()).toList()),
    );
  }

  Future<void> _persistMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final all = <Map<String, dynamic>>[];
    _messages.forEach((key, msgs) {
      for (final m in msgs) {
        all.add(m.toJson());
      }
    });
    await prefs.setString('tc_messages', jsonEncode(all));
  }

  Future<void> _persistGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _localGroups.map((g) {
      return {
        'name': g.name,
        'color': g.avatarColor.toARGB32(),
        'lastTs': g.lastTs,
        'messages': g.messages
            .map((m) =>
                {'text': m.text, 'time': m.time, 'me': m.isSentByMe})
            .toList(),
      };
    }).toList();
    await prefs.setString('tc_groups', jsonEncode(list));
  }

  // ---------- Seed data ----------

  void _seedUsers() {
    const demos = [
      ('Alice', 'alice123', 'Busy coding'),
      ('Bob', 'bob123', 'Gym time'),
      ('Charlie', 'charlie123', 'Traveling'),
      ('Mom', 'mom123', 'Cooking is love'),
      ('Rahul', 'rahul123', 'Music on'),
      ('Sara', 'sara123', 'Designing'),
    ];
    for (final d in demos) {
      _users.add(
        UserModel(username: d.$1, password: d.$2, status: d.$3),
      );
    }
  }

  void _seedMessages() {
    void add(String from, String to, String text, double ts,
        {bool read = false}) {
      _messages.putIfAbsent(_pairKey(from, to), () => []).add(
            _ServerMessage(
              from: from,
              to: to,
              text: text,
              time: _fmtTime(ts),
              ts: ts,
              read: read,
            ),
          );
    }

    final now = _now();
    const min = 60000;
    add('Bob', 'Alice', 'Hey! Did you see the new Flutter release?', now - 30 * min);
    add('Alice', 'Bob', "Not yet, what's new?", now - 28 * min);
    add('Bob', 'Alice', 'Way better performance!', now - 25 * min);
    add('Mom', 'Alice', 'Are you coming home for dinner?', now - 60 * min);
    add('Alice', 'Mom', 'Yes mom, on my way!', now - 55 * min);
    add('Charlie', 'Bob', 'Beach day tomorrow?', now - 120 * min);
  }

  void _seedCalls() {
    _calls.addAll([
      const CallModel(name: 'Alice', time: 'Today, 2:15 PM', isVideo: true, isIncoming: true, isMissed: false, color: Color(0xFFE91E63)),
      const CallModel(name: 'Bob', time: 'Today, 11:30 AM', isVideo: false, isIncoming: false, isMissed: true, color: Color(0xFF00BCD4)),
      const CallModel(name: 'Mom', time: 'Yesterday, 6:00 PM', isVideo: true, isIncoming: true, isMissed: false, color: Color(0xFF5E5402)),
    ]);
  }

  void _seedStatuses() {
    _statuses.addAll([
      _myStatus,
      StatusModel(
        name: 'Alice',
        time: 'Today, 6:45 PM',
        color: const Color(0xFF00BCD4),
        gradient: const [Color(0xFF00BCD4), Color(0xFF00838F)],
        content: 'New coding setup',
      ),
      StatusModel(
        name: 'Mom',
        time: 'Today, 4:10 PM',
        color: const Color(0xFFE91E63),
        gradient: const [Color(0xFFE91E63), Color(0xFF880E4F)],
        content: 'Made your favourite pasta',
      ),
      StatusModel(
        name: 'Bob',
        time: 'Yesterday, 8:00 PM',
        color: const Color(0xFF9C27B0),
        gradient: const [Color(0xFF9C27B0), Color(0xFF4A148C)],
        content: 'Gym goals',
      ),
      StatusModel(
        name: 'Charlie',
        time: 'Yesterday, 1:00 PM',
        color: const Color(0xFFFF9800),
        gradient: const [Color(0xFFFF9800), Color(0xFFBF360C)],
        content: 'Beach day',
        isSeen: true,
      ),
    ]);
  }
}
