import 'package:flutter/material.dart';

import '../../screens/classroom/join_classroom_screen.dart';
import '../../screens/classroom/create_classroom_screen.dart';

class ClassroomActionSheet extends StatelessWidget {
  const ClassroomActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Join Class Option
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.onSurface, width: 2),
                  ),
                  child: Icon(
                    Icons.login,
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Join Class',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinClassroomScreen(),
                    ),
                  );
                },
              ),

              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.onSurface.withOpacity(0.2),
                indent: 16,
                endIndent: 16,
              ),

              // Create Class Option
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.onSurface, width: 2),
                  ),
                  child: Icon(
                    Icons.person_add,
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Create Class',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateClassroomScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
