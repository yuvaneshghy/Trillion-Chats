import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String type;
  final String? mediaPath;

  _ServerMessage({
    required this.from,
    required this.to,
    required this.text,
    required this.time,
    required this.ts,
    this.read = false,
    this.type = 'text',
    this.mediaPath,
  });

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'text': text,
        'time': time,
        'ts': ts,
        'read': read,
        'type': type,
        'mediaPath': mediaPath,
      };

  factory _ServerMessage.fromJson(Map<String, dynamic> json) {
    return _ServerMessage(
      from: json['from'] as String,
      to: json['to'] as String,
      text: json['text'] as String,
      time: json['time'] as String,
      ts: (json['ts'] as num).toDouble(),
      read: json['read'] == true,
      type: json['type'] as String? ?? 'text',
      mediaPath: json['mediaPath'] as String?,
    );
  }
}

class AppState extends ChangeNotifier {
  AppState._();

  static final AppState instance = AppState._();

  UserModel? _currentUser;
  final List<UserModel> _users = [];
  final Map<String, List<_ServerMessage>> _messages = {};
  final Map<String, ChatModel> _conversations = {};
  final List<ChatModel> _localGroups = [];
  final List<CallModel> _calls = [];
  late final List<StatusModel> _statuses = [_myStatus];
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

  StreamSubscription? _usersSub;
  StreamSubscription? _msgsSub;

  Future<void> init() async {
    _currentUser = null;
    _users.clear();
    _messages.clear();
    _conversations.clear();
    _localGroups.clear();

    // Listen to Firebase Authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        // Fetch current user's profile from Firestore
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _currentUser = UserModel.fromJson(doc.data()!);
        }

        // Listen for all users (for contacts list)
        _usersSub?.cancel();
        _usersSub = FirebaseFirestore.instance.collection('users').snapshots().listen((snap) {
          _users.clear();
          for (var uDoc in snap.docs) {
            _users.add(UserModel.fromJson(uDoc.data()));
          }
          notifyListeners();
        });

        // Listen for all messages (in a real app, you'd only listen to messages where user is sender or receiver)
        _msgsSub?.cancel();
        _msgsSub = FirebaseFirestore.instance.collection('messages').orderBy('ts').snapshots().listen((snap) {
          _messages.clear();
          for (var mDoc in snap.docs) {
            final m = _ServerMessage.fromJson(mDoc.data());
            _messages.putIfAbsent(_pairKey(m.from, m.to), () => []).add(m);
          }
          _loadConversations();
          notifyListeners();
        });
      } else {
        // User logged out
        _currentUser = null;
        _usersSub?.cancel();
        _msgsSub?.cancel();
        _users.clear();
        _messages.clear();
        _conversations.clear();
        notifyListeners();
      }
    });
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
          .map((m) {
                final msgType = MessageType.values.firstWhere((e) => e.name == m.type, orElse: () => MessageType.text);
                return MessageModel(
                  text: m.text,
                  time: m.time,
                  isSentByMe:
                      m.from.toLowerCase() == _currentUser!.username.toLowerCase(),
                  read: m.read,
                  type: msgType,
                  mediaPath: m.mediaPath,
                );
              })
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
    try {
      final email = '$username@trillionchats.com';
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // The authStateChanges listener in init() will handle the rest
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(String username, String password) async {
    final name = username.trim();
    if (name.isEmpty) return false;
    try {
      final email = '$name@trillionchats.com';
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      
      final user = UserModel(username: name, password: password);
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set(user.toJson());
      // The authStateChanges listener in init() will handle the rest
      return true;
    } catch (e) {
      debugPrint('Signup error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
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
      final msg = _ServerMessage(from: me, to: chat.name, text: text, time: display, ts: ts);
      FirebaseFirestore.instance.collection('messages').add(msg.toJson());
    }
    chat.unreadCount = 0;
    _moveToTop(chat);
    notifyListeners();
  }

  void sendMediaMessage(ChatModel chat, String path, MessageType type, {String text = ''}) {
    final ts = _now();
    final display = _fmtTime(ts);
    if (chat.isGroup) {
      chat.messages
          .add(MessageModel(text: text, time: display, isSentByMe: true, type: type, mediaPath: path));
      chat.lastTs = ts;
      unawaited(_persistGroups());
    } else {
      final me = _currentUser!.username;
      final msg = _ServerMessage(from: me, to: chat.name, text: text, time: display, ts: ts, type: type.name, mediaPath: path);
      FirebaseFirestore.instance.collection('messages').add(msg.toJson());
    }
    chat.unreadCount = 0;
    _moveToTop(chat);
    notifyListeners();
  }

  void markChatRead(ChatModel chat) async {
    if (chat.isGroup || _currentUser == null) return;
    
    // Find unread messages where the current user is the receiver
    final unreadQuery = await FirebaseFirestore.instance.collection('messages')
      .where('to', isEqualTo: _currentUser!.username)
      .where('from', isEqualTo: chat.name)
      .where('read', isEqualTo: false)
      .get();
      
    for (var doc in unreadQuery.docs) {
      doc.reference.update({'read': true});
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


  Future<void> _persistGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _localGroups.map((g) {
      return {
        'name': g.name,
        'color': g.avatarColor.toARGB32(),
        'lastTs': g.lastTs,
        'messages': g.messages
            .map((m) =>
                {'text': m.text, 'time': m.time, 'me': m.isSentByMe, 'type': m.type.name, 'mediaPath': m.mediaPath})
            .toList(),
      };
    }).toList();
    await prefs.setString('tc_groups', jsonEncode(list));
  }


}
