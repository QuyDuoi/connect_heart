import 'package:connect_heart/presentation/widgets/user_greeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_heart/providers/user_provider.dart';

class EventHeader extends ConsumerStatefulWidget {
  final void Function(String query) onSearch;

  const EventHeader({super.key, required this.onSearch});

  @override
  ConsumerState<EventHeader> createState() => _EventHeaderState();
}

class _EventHeaderState extends ConsumerState<EventHeader>
    with TickerProviderStateMixin {
  bool _showSearch = false;
  final TextEditingController _controller = TextEditingController();

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (!_showSearch) {
      _controller.clear();
      widget.onSearch('');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header chính
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const UserGreeting(),
              const Spacer(),
              IconButton(
                icon: Icon(_showSearch ? Icons.close : Icons.search),
                onPressed: _toggleSearch,
              ),
            ],
          ),
        ),

        // AnimatedSize để hiển thị/ẩn TextField
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _showSearch
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sự kiện...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          widget.onSearch(_controller.text.trim());
                        },
                      ),
                    ),
                    onSubmitted: (query) {
                      widget.onSearch(query.trim());
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}