import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/local_db.dart';

class AutoSuggestField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String dbKey;
  final int maxLines;
  final VoidCallback? onChanged;

  const AutoSuggestField({
    super.key,
    required this.controller,
    required this.label,
    required this.dbKey,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  State<AutoSuggestField> createState() => _AutoSuggestFieldState();
}

class _AutoSuggestFieldState extends State<AutoSuggestField> {
  // 1. Preserve the FocusNode in the state
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(); // Initialize it exactly once
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return RawAutocomplete<String>(
            textEditingController: widget.controller,
            focusNode: _focusNode, // 2. Use the preserved FocusNode
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return LocalDb.getSuggestions(widget.dbKey).where((option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              if (widget.onChanged != null) widget.onChanged!();
            },
            fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textController,
                focusNode: focusNode,
                maxLines: widget.maxLines,
                onChanged: (_) {
                  if (widget.onChanged != null) widget.onChanged!();
                },
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                ),
                onSubmitted: (String value) => onFieldSubmitted(),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: constraints.maxWidth,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return ListTile(
                          title: Text(option, style: const TextStyle(fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.arrow_upward, size: 16, color: Colors.grey),
                          onTap: () => onSelected(option),
                          hoverColor: Colors.blue.shade50,
                        );
                      },
                    ),
                  ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0),
                ),
              );
            },
          );
        }
    );
  }
}