import 'package:flutter/material.dart';

class AddSkillDialog extends StatefulWidget {
  @override
  _AddSkillDialogState createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<AddSkillDialog> {
  final TextEditingController _skillController = TextEditingController();
  String _selectedLevel = 'Beginner';
  bool _isSkillNameValid = false;

  @override
  void initState() {
    super.initState();
    _skillController.addListener(() {
      setState(() {
        _isSkillNameValid = _skillController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
      ),
      backgroundColor: Colors.white, // Clean white background
      title: Text(
        'Add Skill',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _skillField(),
            SizedBox(height: 16.0),
            _levelDropdown(),
          ],
        ),
      ),
      actions: [
        _cancelButton(),
        _addButton(),
      ],
    );
  }

  Widget _skillField() {
    return TextField(
      controller: _skillController,
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: 'Skill Name',
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    );
  }

  Widget _levelDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: DropdownButton<String>(
        value: _selectedLevel,
        isExpanded: true, // Makes dropdown full-width
        underline: SizedBox(), // Removes default underline
        items: ['Beginner', 'Intermediate', 'Advanced'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: Colors.black87, fontSize: 16.0),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedLevel = newValue!;
          });
        },
      ),
    );
  }

  Widget _cancelButton() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        'Cancel',
        style: TextStyle(
          color: const Color.fromARGB(255, 13, 28, 68),
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _addButton() {
    return ElevatedButton(
      onPressed: _isSkillNameValid
          ? () {
              Navigator.pop(context, {
                'name': _skillController.text,
                'level': _selectedLevel,
              });
            }
          : null,
      child: Text(
        'Add',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 13, 28, 68),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 0, // Flat button for dialog
      ),
    );
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }
}