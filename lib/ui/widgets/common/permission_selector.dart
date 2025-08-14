import 'package:flutter/material.dart';
import 'package:inventory_sudan/utils/constants/app_colors.dart';
import 'package:inventory_sudan/utils/constants/app_text_styles.dart';

class PermissionSelector extends StatefulWidget {
  final List<String> availablePermissions;
  final List<String> selectedPermissions;
  final Function(List<String>) onPermissionsChanged;
  final String title;
  final Color? accentColor;

  const PermissionSelector({
    Key? key,
    required this.availablePermissions,
    required this.selectedPermissions,
    required this.onPermissionsChanged,
    required this.title,
    this.accentColor,
  }) : super(key: key);

  @override
  State<PermissionSelector> createState() => _PermissionSelectorState();
}

class _PermissionSelectorState extends State<PermissionSelector> {
  late List<String> _selectedPermissions;

  @override
  void initState() {
    super.initState();
    _selectedPermissions = List<String>.from(widget.selectedPermissions);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? AppColors.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.security,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        '${_selectedPermissions.length} من ${widget.availablePermissions.length} صلاحية محددة',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Select/Deselect All buttons
                Row(
                  children: [
                    TextButton(
                      onPressed: _selectAll,
                      child: Text(
                        'تحديد الكل',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _deselectAll,
                      child: Text(
                        'إلغاء الكل',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Permissions list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.availablePermissions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final permission = widget.availablePermissions[index];
                final isSelected = _selectedPermissions.contains(permission);

                return _buildPermissionItem(
                  permission: permission,
                  isSelected: isSelected,
                  accentColor: accentColor,
                  onChanged: (selected) => _togglePermission(permission, selected),
                );
              },
            ),

            const SizedBox(height: 16),

            // Add custom permission section
            _buildAddCustomPermission(accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required String permission,
    required bool isSelected,
    required Color accentColor,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? accentColor.withOpacity(0.3) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? accentColor : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                permission,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? accentColor : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              IconButton(
                onPressed: () => _removePermission(permission),
                icon: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomPermission(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'إضافة صلاحية مخصصة',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'اكتب اسم الصلاحية...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: _addCustomPermission,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _showAddPermissionDialog(accentColor),
              icon: Icon(Icons.add, color: accentColor),
              style: IconButton.styleFrom(
                backgroundColor: accentColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _togglePermission(String permission, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedPermissions.contains(permission)) {
          _selectedPermissions.add(permission);
        }
      } else {
        _selectedPermissions.remove(permission);
      }
    });
    widget.onPermissionsChanged(_selectedPermissions);
  }

  void _removePermission(String permission) {
    setState(() {
      _selectedPermissions.remove(permission);
    });
    widget.onPermissionsChanged(_selectedPermissions);
  }

  void _selectAll() {
    setState(() {
      _selectedPermissions = List<String>.from(widget.availablePermissions);
    });
    widget.onPermissionsChanged(_selectedPermissions);
  }

  void _deselectAll() {
    setState(() {
      _selectedPermissions.clear();
    });
    widget.onPermissionsChanged(_selectedPermissions);
  }

  void _addCustomPermission(String permission) {
    if (permission.trim().isNotEmpty && !widget.availablePermissions.contains(permission.trim())) {
      // Add to available permissions (this would typically be handled at a higher level)
      // For now, we'll just add to selected permissions
      _togglePermission(permission.trim(), true);
    }
  }

  void _showAddPermissionDialog(Color accentColor) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة صلاحية مخصصة'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'اكتب اسم الصلاحية...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addCustomPermission(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
