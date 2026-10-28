import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_clean_starter/core/design_system/date_labels.dart';
import 'package:flutter_clean_starter/core/design_system/theme/app_radius.dart';
import 'package:flutter_clean_starter/core/design_system/theme/app_spacing.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:material_ui/material_ui.dart';

/// An optional date, as a form field: tap to pick, Clear to remove.
///
/// Adaptive: Material's calendar dialog on Android, a wheel in a bottom
/// sheet on iOS (where a calendar dialog would feel foreign). The value is a
/// [CalendarDate]: the pickers' `DateTime`s never leave this file.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.today,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;

  /// `null`: no date.
  final CalendarDate? value;

  /// Where the picker opens when there's no [value].
  final CalendarDate today;

  final ValueChanged<CalendarDate?> onChanged;
  final bool enabled;

  /// The years the pickers offer.
  static final first = CalendarDate(2000, 1, 1);
  static final last = CalendarDate(2100, 12, 31);

  Future<void> _pick(BuildContext context) async {
    final picked = await pickDate(context, value ?? today, title: label);
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return InkWell(
      onTap: enabled ? () => _pick(context) : null,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          enabled: enabled,
          prefixIcon: const Icon(Icons.event_outlined),
          suffixIcon: value == null
              ? null
              : IconButton(
                  tooltip: 'Clear $label',
                  icon: const Icon(Icons.clear),
                  onPressed: enabled ? () => onChanged(null) : null,
                ),
        ),
        child: Text(value == null ? '' : longDayLabel(value)),
      ),
    );
  }
}

/// Picks a day the platform's way, starting at [initial]; `null` if
/// dismissed.
Future<CalendarDate?> pickDate(
  BuildContext context,
  CalendarDate initial, {
  required String title,
}) async {
  final first = DatePickerField.first;
  final last = DatePickerField.last;
  final start = initial < first ? first : (initial > last ? last : initial);
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return showModalBottomSheet<CalendarDate>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CupertinoDateSheet(initial: start, title: title),
    );
  }
  final picked = await showDatePicker(
    context: context,
    initialDate: start.toDateTime(),
    firstDate: first.toDateTime(),
    lastDate: last.toDateTime(),
    helpText: title,
  );
  return picked == null ? null : CalendarDate.fromDateTime(picked);
}

class _CupertinoDateSheet extends StatefulWidget {
  const _CupertinoDateSheet({required this.initial, required this.title});

  final CalendarDate initial;
  final String title;

  @override
  State<_CupertinoDateSheet> createState() => _CupertinoDateSheetState();
}

class _CupertinoDateSheetState extends State<_CupertinoDateSheet> {
  late CalendarDate _day = widget.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        0,
        AppSpacing.medium,
        AppSpacing.medium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.title, style: theme.textTheme.titleLarge),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(_day),
                child: const Text('Done'),
              ),
            ],
          ),
          SizedBox(
            height: 216,
            child: CupertinoTheme(
              data: CupertinoThemeData(brightness: theme.brightness),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: widget.initial.toDateTime(),
                minimumDate: DatePickerField.first.toDateTime(),
                maximumDate: DatePickerField.last.toDateTime(),
                onDateTimeChanged: (value) =>
                    _day = CalendarDate.fromDateTime(value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
