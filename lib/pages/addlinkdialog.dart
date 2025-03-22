import 'package:flutter/material.dart';

class AddLinkDialog extends StatefulWidget {
  @override
  _AddLinkDialogState createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends State<AddLinkDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateFormValidity);
    _urlController.addListener(_updateFormValidity);
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty && _urlController.text.isNotEmpty;
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
        'Add Link',
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
            _nameField(),
            SizedBox(height: 16.0),
            _urlField(),
          ],
        ),
      ),
      actions: [
        _cancelButton(),
        _addButton(),
      ],
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _nameController,
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: 'Link Name (e.g., My LinkedIn)',
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

  Widget _urlField() {
    return TextField(
      controller: _urlController,
      style: TextStyle(color: Colors.black87, fontSize: 16.0),
      decoration: InputDecoration(
        labelText: 'URL (e.g., https://linkedin.com)',
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
      onPressed: _isFormValid
          ? () {
              Navigator.pop(context, {
                'name': _nameController.text,
                'url': _urlController.text,
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
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}