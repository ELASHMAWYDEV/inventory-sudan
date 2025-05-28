import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class DynamicDropdownWidget extends StatefulWidget {
  final String name;
  final String label;
  final String? value;
  final List<String> options;
  final Function(String) onChanged;
  final Function(String) onNewOptionAdded;
  final String? hintText;
  final bool isRequired;
  final IconData? prefixIcon;
  final List<FormFieldValidator<String>>? validators;
  final bool enabled;
  final String? initialValue;

  const DynamicDropdownWidget({
    Key? key,
    required this.name,
    required this.label,
    this.value,
    required this.options,
    required this.onChanged,
    required this.onNewOptionAdded,
    this.hintText,
    this.isRequired = false,
    this.prefixIcon,
    this.validators,
    this.enabled = true,
    this.initialValue,
  }) : super(key: key);

  @override
  State<DynamicDropdownWidget> createState() => _DynamicDropdownWidgetState();
}

class _DynamicDropdownWidgetState extends State<DynamicDropdownWidget> {
  final TextEditingController _textController = TextEditingController();
  bool _isAddingNew = false;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value ?? widget.initialValue;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _toggleAddNew() {
    setState(() {
      _isAddingNew = !_isAddingNew;
      if (!_isAddingNew) {
        _textController.clear();
      }
    });
  }

  void _addNewOption() {
    final newOption = _textController.text.trim();
    if (newOption.isNotEmpty && !widget.options.contains(newOption)) {
      widget.onNewOptionAdded(newOption);
      widget.onChanged(newOption);
      setState(() {
        _selectedValue = newOption;
        _isAddingNew = false;
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (!_isAddingNew) ...[
          FormBuilderDropdown<String>(
            name: widget.name,
            initialValue: _selectedValue,
            validator: widget.validators != null ? FormBuilderValidators.compose(widget.validators!) : null,
            enabled: widget.enabled,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'اختر ${widget.label}',
              prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: Colors.grey.shade600) : null,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: _toggleAddNew,
                tooltip: 'اضافة ${widget.label.toLowerCase()}',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: widget.options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedValue = newValue;
                });
                widget.onChanged(newValue);
              }
            },
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'ادخل ${widget.label.toLowerCase()}',
                    prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: Colors.grey.shade600) : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onFieldSubmitted: (_) => _addNewOption(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: _addNewOption,
                tooltip: 'Add',
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: _toggleAddNew,
                tooltip: 'Cancel',
              ),
            ],
          ),
        ],
      ],
    );
  }
}
