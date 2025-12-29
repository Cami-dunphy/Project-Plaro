import 'package:flutter/material.dart';

class PlaroAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onSearchSubmit;
  final VoidCallback? onFilter;

  const PlaroAppBar({
    super.key,
    this.onSearch,
    this.onSearchSubmit,
    this.onFilter,
  });

  @override
  State<PlaroAppBar> createState() => _PlaroAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}

class _PlaroAppBarState extends State<PlaroAppBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Discover"),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _controller.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                if (widget.onSearch != null)
                                  widget.onSearch!("");
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: widget.onSearch,
                  onSubmitted: widget.onSearchSubmit,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: widget.onFilter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
