import 'package:flutter/material.dart';
import '../../../core/constants/app_color.dart';

class TimeRangeSelector extends StatelessWidget {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;

  const TimeRangeSelector({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
  });

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '00:00';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColor.textSecondary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Start Time
          Expanded(
            child: InkWell(
              onTap: onStartTimeTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.textSecondary.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColor.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(startTime),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Arrow
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: AppColor.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // End Time
          Expanded(
            child: InkWell(
              onTap: onEndTimeTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.textSecondary.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColor.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(endTime),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
