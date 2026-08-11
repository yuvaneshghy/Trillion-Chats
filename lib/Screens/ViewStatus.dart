import 'package:flutter/material.dart';
import 'package:flutter_application_1/CustomUI/AppAvatar.dart';
import 'package:flutter_application_1/Model/StatusModel.dart';
import 'package:flutter_application_1/State/AppState.dart';

class ViewStatus extends StatefulWidget {
  final List<StatusModel> statuses;
  final int initialIndex;

  const ViewStatus({
    super.key,
    required this.statuses,
    required this.initialIndex,
  });

  @override
  State<ViewStatus> createState() => _ViewStatusState();
}

class _ViewStatusState extends State<ViewStatus>
    with SingleTickerProviderStateMixin {
  late int _index;
  late AnimationController _anim;

  StatusModel get _current => widget.statuses[_index];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _goNext();
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _start() {
    _anim.reset();
    _anim.forward();
    AppState.instance.markStatusSeen(_current);
  }

  void _goNext() {
    if (_index < widget.statuses.length - 1) {
      setState(() {
        _index++;
        _start();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _goPrev() {
    if (_index > 0) {
      setState(() {
        _index--;
        _start();
      });
    } else {
      _anim.forward();
    }
  }

  void _onTap(TapUpDetails details) {
    final width = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < width * 0.3) {
      _goPrev();
    } else {
      _goNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _current.gradient;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: _onTap,
        onLongPressStart: (_) => _anim.stop(),
        onLongPressEnd: (_) => _anim.forward(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradient,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _current.isMyStatus ? Icons.person : Icons.emoji_emotions,
                        color: Colors.white70,
                        size: 90,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _current.content ?? 'No caption',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (context, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: _anim.value,
                        minHeight: 3,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AppAvatar(
                        name: _current.name,
                        isGroup: false,
                        color: _current.color,
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _current.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _current.time,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
