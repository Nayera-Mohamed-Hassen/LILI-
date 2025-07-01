import 'package:flutter/material.dart';
import '../services/ocr_service.dart';

class ExtractedItemsDialog extends StatefulWidget {
  final List<OCRItem> items;

  const ExtractedItemsDialog({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  _ExtractedItemsDialogState createState() => _ExtractedItemsDialogState();
}

class _ExtractedItemsDialogState extends State<ExtractedItemsDialog> {
  Set<int> _selectedIndices = {};

  bool get _allSelected => _selectedIndices.length == widget.items.length;

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        _selectedIndices.clear();
      } else {
        _selectedIndices = Set<int>.from(List.generate(widget.items.length, (i) => i));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3E5879), // Light blue from app gradient
              Color(0xFF1F3354), // Dark blue from app gradient
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Extracted Items',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Select items to add to your inventory:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _toggleSelectAll,
                icon: Icon(_allSelected ? Icons.check_box : Icons.check_box_outline_blank, color: Colors.white),
                label: Text(_allSelected ? 'Deselect All' : 'Select All', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = _selectedIndices.contains(index);
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF3E5879) : Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIndices.add(index);
                            } else {
                              _selectedIndices.remove(index);
                            }
                          });
                        },
                        activeColor: Colors.white,
                        checkColor: Color(0xFF1F3354),
                      ),
                      title: Text(
                        item.name.isNotEmpty ? item.name : 'Unknown Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            'Quantity: ${item.quantity}',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Price: \$${item.amount.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white70),
                          ),
                          if (item.unitPrice > 0)
                            Text(
                              'Unit Price: \$${item.unitPrice.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIndices.remove(index);
                          } else {
                            _selectedIndices.add(index);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedIndices.isEmpty ? null : () {
                    final selectedItems = _selectedIndices
                        .map((index) => widget.items[index])
                        .toList();
                    Navigator.of(context).pop(selectedItems);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add Selected (${_selectedIndices.length})',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 