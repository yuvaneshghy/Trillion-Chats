import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application_1/Model/MessageModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/AppAvatar.dart';
import 'package:flutter_application_1/CustomUI/MessageBubble.dart';
import 'package:flutter_application_1/CustomUI/GlassContainer.dart';
import 'package:flutter_application_1/Model/ChatModel.dart';
import 'package:flutter_application_1/Screens/GroupInfoPage.dart';
import 'package:flutter_application_1/State/AppState.dart';
import 'package:flutter_application_1/Theme/AppColors.dart';

class IndividualPage extends StatefulWidget {
  final ChatModel chatModel;

  const IndividualPage({super.key, required this.chatModel});

  @override
  State<IndividualPage> createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  late ChatModel _chat;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focus = FocusNode();
  bool _showEmoji = false;
  bool _showAttach = false;

  @override
  void initState() {
    super.initState();
    _chat = widget.chatModel;
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppState.instance.markChatRead(_chat);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    AppState.instance.sendMessage(_chat, text);
    _controller.clear();
    if (_showEmoji) setState(() => _showEmoji = false);
    _scrollToBottom();
  }

  void _toggleEmoji() {
    setState(() {
      _showEmoji = !_showEmoji;
      _showAttach = false;
      if (_showEmoji) {
        _focus.unfocus();
      } else {
        _focus.requestFocus();
      }
    });
  }

  void _toggleAttach() {
    setState(() {
      _showAttach = !_showAttach;
      if (_showEmoji) _showEmoji = false;
      _focus.unfocus();
    });
    if (_showAttach) {
      _showAttachmentSheet();
    }
  }

  void _showAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _AttachmentSheet(chat: _chat),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: const GlassContainer(
        blur: 15,
        opacity: 0.1,
        borderRadius: BorderRadius.zero,
        child: SizedBox.expand(),
      ),
      leadingWidth: 100,
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_back, size: 30, color: Colors.white),
            const SizedBox(width: 8),
            AppAvatar(
              name: _chat.name,
              isGroup: _chat.isGroup,
              color: _chat.avatarColor,
              radius: 22,
            ),
          ],
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _chat.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 3),
          Text(
            _chat.lastSeen,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.video_call, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video call (demo)'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Call (demo)'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: AppColors.menu,
          onSelected: (value) {
            if (value == 'View Contact') {
              if (_chat.isGroup) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupInfoPage(chat: _chat),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact info (demo)'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$value (demo)'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'View Contact',
              child: Text(_chat.isGroup ? 'View Group Info' : 'View Contact'),
            ),
            const PopupMenuItem(
              value: 'Media, Links and Docs',
              child: Text('Media, Links and Docs'),
            ),
            const PopupMenuItem(value: 'Search', child: Text('Search')),
            const PopupMenuItem(
              value: 'Mute Notifications',
              child: Text('Mute Notifications'),
            ),
            const PopupMenuItem(value: 'Wallpaper', child: Text('Wallpaper')),
            const PopupMenuItem(value: 'More', child: Text('More')),
          ],
        ),
      ],
    );
  }

  Widget _buildMessages() {
    return Container(
      color: Colors.transparent,
      child: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final updatedChat = AppState.instance.chats.firstWhere(
            (c) => c.name == _chat.name && c.isGroup == _chat.isGroup,
            orElse: () => _chat,
          );
          final messages = updatedChat.messages;
          return ListView.builder(
            controller: _scroll,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[messages.length - 1 - index];
              return MessageBubble(message: message);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 300,
      child: EmojiPicker(
        textEditingController: _controller,
        config: const Config(height: 300, checkPlatformCompatibility: false),
      ),
    );
  }

  Widget _buildInputBar() {
    final hasText = _controller.text.trim().isNotEmpty;
    return GlassContainer(
      margin: EdgeInsets.only(
        left: 4,
        right: 4,
        top: 6,
        bottom: MediaQuery.of(context).viewInsets.bottom + 6,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      borderRadius: BorderRadius.circular(30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              _showEmoji ? Icons.keyboard : Icons.emoji_emotions,
              color: Colors.white,
            ),
            onPressed: _toggleEmoji,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      minLines: 1,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Message',
                        hintStyle: TextStyle(color: Colors.white54),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  if (!hasText) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.attach_file,
                        color: Colors.white,
                      ),
                      onPressed: _toggleAttach,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Camera (demo)'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 0),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white24,
              child: IconButton(
                onPressed: hasText ? _sendMessage : null,
                icon: Icon(
                  hasText ? Icons.send : Icons.mic,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          if (_showEmoji) _buildEmojiPicker(),
          _buildInputBar(),
        ],
      ),
    );
  }
}

class _AttachmentSheet extends StatelessWidget {
  final ChatModel chat;
  const _AttachmentSheet({required this.chat});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      AppState.instance.sendMediaMessage(
        chat,
        pickedFile.path,
        MessageType.image,
      );
    }
  }

  Future<void> _pickDocument(BuildContext context) async {
    Navigator.pop(context);
    final result = await FilePicker.pickFiles();
    // ignore: unnecessary_null_comparison
    if (result != null && result.isNotEmpty && result.single.path != null) {
      AppState.instance.sendMediaMessage(
        chat,
        result.single.path!,
        MessageType.document,
        text: result.single.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'Send media',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SheetIcon(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: AppColors.whatsappGreen,
                  onTap: () => _pickDocument(context),
                ),
                _SheetIcon(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: AppColors.chatGreen,
                  onTap: () => _pickImage(context, ImageSource.camera),
                ),
                _SheetIcon(
                  icon: Icons.insert_photo,
                  label: 'Gallery',
                  color: const Color(0xFFF57C00),
                  onTap: () => _pickImage(context, ImageSource.gallery),
                ),
                _SheetIcon(
                  icon: Icons.audio_file,
                  label: 'Audio',
                  color: const Color(0xFF8E24AA),
                  onTap: () => _demo(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SheetIcon(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: const Color(0xFF1E88E5),
                  onTap: () => _demo(context),
                ),
                _SheetIcon(
                  icon: Icons.person_add_alt,
                  label: 'Contact',
                  color: const Color(0xFFD81B60),
                  onTap: () => _demo(context),
                ),
                _SheetIcon(
                  icon: Icons.poll,
                  label: 'Poll',
                  color: const Color(0xFF00897B),
                  onTap: () => _demo(context),
                ),
                _SheetIcon(
                  icon: Icons.more_horiz,
                  label: 'More',
                  color: AppColors.grey,
                  onTap: () => _demo(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _demo(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not fully implemented yet (demo)'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _SheetIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
