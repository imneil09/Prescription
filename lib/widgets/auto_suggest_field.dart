import 'package:flutter/material.dart';
import '../utils/local_db.dart';

class AutoSuggestField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String dbKey;
  final int maxLines;

  const AutoSuggestField({
    super.key,
    required this.controller,
    required this.label,
    required this.dbKey,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return RawAutocomplete<String>(
            textEditingController: controller,
            focusNode: FocusNode(),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              // Fetch suggestions and filter based on what the doctor is typing
              return LocalDb.getSuggestions(dbKey).where((option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              // Do nothing on select, the controller updates automatically
            },
            fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textController,
                focusNode: focusNode,
                maxLines: maxLines,
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (String value) => onFieldSubmitted(),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(4),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      maxWidth: constraints.maxWidth, // Match width of text field
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(option, style: const TextStyle(fontSize: 14)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }
    );
  }
}