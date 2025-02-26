import 'dart:math';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:readybill/components/text_dialog_widget.dart';
import 'package:readybill/temp/user_data.dart';
import 'package:readybill/temp/user_model.dart';
import 'package:readybill/temp/utils.dart';

class EditableTable extends StatefulWidget {
  const EditableTable({super.key});

  @override
  State<EditableTable> createState() => _EditableTableState();
}

class _EditableTableState extends State<EditableTable> {
  final Set<User> _selectedUsers = {};
  bool isSortAscending = true;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<User> _filteredUsers = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();

    _filteredUsers = List.from(allUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EditableTable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewRow,
            tooltip: 'Add new row',
          ),
          if (_selectedUsers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedRows,
              tooltip: 'Delete selected rows',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Item Name',
                hintText: 'Type to filter rows',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterUsers('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),
          // Status bar showing number of visible rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchTerm.isEmpty
                      ? 'Showing all ${_filteredUsers.length} rows'
                      : 'Found ${_filteredUsers.length} ${_filteredUsers.length == 1 ? 'row' : 'rows'} containing "$_searchTerm"',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                if (_selectedUsers.isNotEmpty)
                  Text(
                    '${_selectedUsers.length} row(s) selected',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
              child: _filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        _searchTerm.isEmpty
                            ? 'No data available'
                            : 'No results found for "$_searchTerm"',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : buildDataTable()),
        ],
      ),
      // Alternative: Add floating action button for adding new rows
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        tooltip: 'Add new row',
        child: Icon(
          Icons.upload_file,
        ),
      ),
    );
  }

  // Filter users based on search term
  void _filterUsers(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm.trim();

      if (_searchTerm.isEmpty) {
        // Show all users when search is empty
        _filteredUsers = List.from(allUsers);
      } else {
        // Filter users by first name containing the search term (case insensitive)
        final searchTermLower = _searchTerm.toLowerCase();
        _filteredUsers = allUsers
            .where((user) =>
                user.firstName.toLowerCase().contains(searchTermLower))
            .toList();

        // Sort by relevance
        if (_filteredUsers.isNotEmpty) {
          _filteredUsers.sort((a, b) {
            // Exact match gets highest priority
            if (a.firstName.toLowerCase() == searchTermLower) return -1;
            if (b.firstName.toLowerCase() == searchTermLower) return 1;

            // Next priority: where the match appears in the string (earlier is better)
            final aIndex = a.firstName.toLowerCase().indexOf(searchTermLower);
            final bIndex = b.firstName.toLowerCase().indexOf(searchTermLower);
            if (aIndex != bIndex) return aIndex - bIndex;

            // If same position, sort by completeness ratio (what % of the name matches)
            final aRatio = searchTermLower.length / a.firstName.length;
            final bRatio = searchTermLower.length / b.firstName.length;
            return bRatio.compareTo(aRatio); // Higher ratio first
          });
        }
      }
    });
  }

  void _addNewRow() {
    final newId =
        allUsers.isEmpty ? 1 : allUsers.map((u) => u.id).reduce(max) + 1;

    final newUser = User(
      id: newId,
      firstName: "",
      lastName: "",
      age: "",
    );

    setState(() {
      allUsers.add(newUser);
      // Update filtered list if search is empty to show the new row
      if (_searchTerm.isEmpty) {
        _filteredUsers.add(newUser);
      }
    });
  }

  void _deleteSelectedRows() {
    // Count how many selected rows are visible in the filtered view
    final visibleSelectedUsers =
        _selectedUsers.where((user) => _filteredUsers.contains(user)).toList();

    if (visibleSelectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No visible rows are selected'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rows'),
        content: Text(
            'Are you sure you want to delete ${visibleSelectedUsers.length} selected row(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Remove from both the main list and filtered list
                allUsers
                    .removeWhere((user) => visibleSelectedUsers.contains(user));
                _filteredUsers
                    .removeWhere((user) => visibleSelectedUsers.contains(user));
                _selectedUsers.removeAll(visibleSelectedUsers);
              });
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget buildDataTable() {
    final columns = ['First Name', 'Last Name', 'Age', 'abc', 'def'];
    return DataTable2(
      minWidth: columns.length * 130,
      dataRowHeight: 50,
      fixedTopRows: 1,
      fixedLeftColumns: 2,
      columns: getColumns(columns),
      rows: getRows(_filteredUsers),
      showCheckboxColumn: true,
    );
  }

  List<DataColumn2> getColumns(List<String> columns) {
    return columns.map((column) {
      final isNumericColumn = ['Age'].contains(column);
      return DataColumn2(
        onSort: (columnIndex, ascending) {
          isSortAscending = !isSortAscending;
          setState(() {
            if (isSortAscending) {
              switch (columnIndex) {
                case 0:
                  _filteredUsers
                      .sort((a, b) => a.firstName.compareTo(b.firstName));
                  break;
                case 1:
                  _filteredUsers
                      .sort((a, b) => a.lastName.compareTo(b.lastName));
                  break;
                case 2:
                  _filteredUsers.sort((a, b) => a.age.compareTo(b.age));
                  break;
              }
            } else {
              switch (columnIndex) {
                case 0:
                  _filteredUsers
                      .sort((a, b) => -a.firstName.compareTo(b.firstName));
                  break;
                case 1:
                  _filteredUsers
                      .sort((a, b) => -a.lastName.compareTo(b.lastName));
                  break;
                case 2:
                  _filteredUsers.sort((a, b) => -a.age.compareTo(b.age));
                  break;
              }
            }
          });
        },
        label: Text(
          column,
          overflow: TextOverflow.visible,
        ),
        numeric: isNumericColumn,
      );
    }).toList();
  }

  List<DataRow2> getRows(List<User> users) => users.map(
        (User user) {
          final cells = [user.firstName, user.lastName, user.age, 'abc', 'def'];
          return DataRow2(
            cells: Utils.modelBuilder(
              cells,
              (index, cell) {
                Widget cellContent;
                if (_searchTerm.isNotEmpty && index == 0) {
                  cellContent = RichText(
                    text: _highlightOccurrences(cell.toString(), _searchTerm),
                  );
                } else {
                  cellContent = Text(cell);
                }

                return DataCell(
                  cellContent,
                  onTap: () {
                    switch (index) {
                      case 0:
                        editFirstName(user);
                        break;
                      case 1:
                        editLastName(user);
                        break;
                      case 2:
                        editAge(user);
                        break;
                    }
                  },
                );
              },
            ),
            selected: _selectedUsers.contains(user),
            onSelectChanged: (isSelected) {
              setState(() {
                if (isSelected != null) {
                  isSelected
                      ? _selectedUsers.add(user)
                      : _selectedUsers.remove(user);
                }
              });
            },
          );
        },
      ).toList();

  // Helper method to highlight matched text
  // Helper method to highlight matched text
  TextSpan _highlightOccurrences(String text, String query) {
    if (query.isEmpty || text.isEmpty) {
      return TextSpan(text: text);
    }

    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();

    if (!textLower.contains(queryLower)) {
      return TextSpan(text: text);
    }

    final List<TextSpan> spans = [];
    int start = 0;

    // Find all occurrences of the query in the text
    int matchIndex;
    while ((matchIndex = textLower.indexOf(queryLower, start)) != -1) {
      // Add text before the match
      if (matchIndex > start) {
        spans.add(TextSpan(
          text: text.substring(start, matchIndex),
          style: const TextStyle(color: Colors.black),
        ));
      }

      // Add the highlighted match
      spans.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + query.length),
        style: const TextStyle(
          backgroundColor: Color(0xFFADD8E6), // Light blue background
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ));

      // Move start index past this match
      start = matchIndex + query.length;
    }

    // Add any remaining text after the last match
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: const TextStyle(color: Colors.black),
      ));
    }

    return TextSpan(children: spans);
  }

  Future editFirstName(User editUser) async {
    final firstName = await showTextDialog(
      context,
      title: 'Edit First Name',
      value: editUser.firstName,
    );

    setState(() {
      // Update user in allUsers
      final index = allUsers.indexWhere((user) => user.id == editUser.id);
      if (index >= 0) {
        allUsers[index] = editUser.copy(firstName: firstName);
      }

      // Update filtered users
      final filteredIndex =
          _filteredUsers.indexWhere((user) => user.id == editUser.id);
      if (filteredIndex >= 0) {
        _filteredUsers[filteredIndex] = editUser.copy(firstName: firstName);
      }

      // If search is active, re-filter to make sure this user still matches
      if (_searchTerm.isNotEmpty) {
        _filterUsers(_searchTerm);
      }
    });
  }

  Future editLastName(User editUser) async {
    final lastName = await showTextDialog(
      context,
      title: 'Edit Last Name',
      value: editUser.lastName,
    );

    setState(() {
      // Update user in allUsers
      final index = allUsers.indexWhere((user) => user.id == editUser.id);
      if (index >= 0) {
        allUsers[index] = editUser.copy(lastName: lastName);
      }

      // Update filtered users
      final filteredIndex =
          _filteredUsers.indexWhere((user) => user.id == editUser.id);
      if (filteredIndex >= 0) {
        _filteredUsers[filteredIndex] = editUser.copy(lastName: lastName);
      }
    });
  }

  Future editAge(User editUser) async {
    final age = await showTextDialog(
      context,
      title: 'Edit Age',
      value: editUser.age,
    );

    setState(() {
      // Update user in allUsers
      final index = allUsers.indexWhere((user) => user.id == editUser.id);
      if (index >= 0) {
        allUsers[index] = editUser.copy(age: age);
      }

      // Update filtered users
      final filteredIndex =
          _filteredUsers.indexWhere((user) => user.id == editUser.id);
      if (filteredIndex >= 0) {
        _filteredUsers[filteredIndex] = editUser.copy(age: age);
      }
    });
  }
}
