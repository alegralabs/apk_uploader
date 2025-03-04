import 'dart:convert';
import 'dart:math';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/components/text_dialog_widget.dart';
import 'package:readybill/models/item_model.dart';

import 'package:readybill/services/api_services.dart';
import 'package:readybill/services/global_internet_connection_handler.dart';
import 'package:readybill/temp/utils.dart';
import 'package:http/http.dart' as http;

class ViewDataset extends StatefulWidget {
  final String title;
  final http.Response? jsonResponse;

  const ViewDataset({super.key, required this.title, this.jsonResponse});

  @override
  State<ViewDataset> createState() => _ViewDatasetState();
}

class _ViewDatasetState extends State<ViewDataset> {
  final Set<ItemModel> _selectedItems = {};
  bool isSortAscending = true;

  List<String> errorMessages = [];
  List<String> errorCoordinates = [];

  final List<String> _dropdownItemsQuantity = [
    'Unit',
    'BAG',
    'BTL',
    'BOX',
    'BDL',
    'CAN',
    'CTN',
    'GM',
    'KG',
    'LTR',
    'MTR',
    'ML',
    'NUM',
    'PCK',
    'PRS',
    'PCS',
    'ROL',
    'SQF',
    'SQM'
  ];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ItemModel> _filteredItems = [];
  String _searchTerm = '';
  List<ItemModel> items = [];

  getItems() async {
    if (widget.jsonResponse == null) {
      var token = await APIService.getToken();
      var apiKey = await APIService.getXApiKey();
      EasyLoading.show(status: 'loading...');
      var response = await http.get(
        Uri.parse('$baseUrl/dataset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'auth-key': '$apiKey',
        },
      );
      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        setState(() {
          items = parseItems(response.body);
          _filteredItems = List.from(items); // Update filtered items
        });
      }
    } else {
      items = parseItems(widget.jsonResponse!.body);
      _filteredItems = List.from(items);
      errorCoordinates = jsonDecode(widget.jsonResponse!.body)['errors']
              ['grid_coordinates']
          .map<String>((item) => item.toString())
          .toList();
      errorMessages = jsonDecode(widget.jsonResponse!.body)['errors']
              ['messages']
          .map<String>((item) => item.toString())
          .toList();
    }
  }

  List<ItemModel> parseItems(String jsonResponse) {
    final Map<String, dynamic> decodedJson = json.decode(jsonResponse);
    final List<dynamic> jsonData = decodedJson['data'];

    return jsonData.asMap().entries.map((entry) {
      int index = entry.key;
      var item = entry.value;

      return ItemModel(
        originalIndex: index,
        itemName: item['item_name'] ?? '',
        quantity: item['quantity'] ?? '',
        minStockAlert: item['minimum_stock_alert'] ?? '',
        mrp: item['mrp'] ?? '0',
        salePrice: item['sale_price'].toString() ?? '',
        unit: item['unit'] ?? '',
        hsn: item['hsn'] ?? '',
        gst: item['gst']?.toString() ?? '0', // Assuming GST as gst
        cess: item['cess']?.toString() ?? '0', // Assuming cess as cess
        flag: 0,
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    getItems();
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
      appBar: customAppBar(widget.title, [
        IconButton(
          icon: const Text(
            'Add Row',
            style: TextStyle(
                color: white,
                fontFamily: 'Roboto-Regular',
                fontWeight: FontWeight.bold),
          ),
          onPressed: _addNewRow,
          tooltip: 'Add new row',
        ),
        if (_selectedItems.isNotEmpty)
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: white,
            ),
            onPressed: _deleteSelectedRows,
            tooltip: 'Delete selected rows',
          ),
      ]),
      body: Column(
        children: [
          errorMessages.isNotEmpty
              ? Container(
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: errorMessages.length * 50.0,
                        child: Center(
                          child: ListView.builder(
                            itemCount: errorMessages.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(errorMessages[index]),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : const SizedBox.shrink(),
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
                    _filterItems('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterItems,
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
                      ? 'Showing all ${_filteredItems.length} rows'
                      : 'Found ${_filteredItems.length} ${_filteredItems.length == 1 ? 'row' : 'rows'} containing "$_searchTerm"',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                if (_selectedItems.isNotEmpty)
                  Text(
                    '${_selectedItems.length} row(s) selected',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        _searchTerm.isEmpty
                            ? 'No data available'
                            : 'No results found for "$_searchTerm"',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : buildDataTable()),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom * 2,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return customAlertBox(
                  title: 'Upload Dataset',
                  content: "Do you want to replace or append the data?",
                  actions: [
                    customElevatedButton('Append', green2, white, () {
                      submitList('1');
                      navigatorKey.currentState?.pop();
                    }),
                    customElevatedButton("Replace", blue, white, () {
                      submitList('2');
                      navigatorKey.currentState?.pop();
                    })
                  ]);
            },
          );
        },
        tooltip: 'Add new row',
        child: const Icon(
          Icons.upload_file,
        ),
      ),
    );
  }

  // Filter items based on search term
  void _filterItems(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm.trim();

      if (_searchTerm.isEmpty) {
        // Show all items when search is empty
        _filteredItems = List.from(items);
      } else {
        // Filter items by item name containing the search term (case insensitive)
        final searchTermLower = _searchTerm.toLowerCase();
        _filteredItems = items
            .where(
                (item) => item.itemName.toLowerCase().contains(searchTermLower))
            .toList();

        // Sort by relevance
        if (_filteredItems.isNotEmpty) {
          _filteredItems.sort((a, b) {
            // 1. Error rows should always be at the top
            int aHasError = errorCoordinates
                    .any((coord) => coord.startsWith('${items.indexOf(a)},'))
                ? 1
                : 0;
            int bHasError = errorCoordinates
                    .any((coord) => coord.startsWith('${items.indexOf(b)},'))
                ? 1
                : 0;
            if (aHasError != bHasError)
              return bHasError - aHasError; // Error rows first

            // 2. Exact match gets highest priority
            if (a.itemName.toLowerCase() == searchTermLower) return -1;
            if (b.itemName.toLowerCase() == searchTermLower) return 1;

            // 3. Next priority: where the match appears in the string (earlier is better)
            final aIndex = a.itemName.toLowerCase().indexOf(searchTermLower);
            final bIndex = b.itemName.toLowerCase().indexOf(searchTermLower);
            if (aIndex != bIndex) return aIndex - bIndex;

            // 4. If same position, sort by completeness ratio (what % of the name matches)
            final aRatio = searchTermLower.length / a.itemName.length;
            final bRatio = searchTermLower.length / b.itemName.length;
            return bRatio.compareTo(aRatio); // Higher ratio first
          });
        }
      }
    });
  }

  void _addNewRow() {
    final newId =
        items.isEmpty ? 1 : items.map((u) => u.originalIndex).reduce(max) + 1;

    final newItem = ItemModel(
      originalIndex: newId,
      itemName: "",
      quantity: "",
      minStockAlert: "",
      mrp: "",
      salePrice: "",
      unit: "",
      hsn: "",
      gst: "",
      cess: "",
      flag: 0,
    );

    setState(() {
      items.add(newItem);

      if (_searchTerm.isEmpty) {
        _filteredItems.add(newItem);
      }
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 70);
    });
  }

  void _deleteSelectedRows() {
    final visibleSelectedItems =
        _selectedItems.where((item) => _filteredItems.contains(item)).toList();

    if (visibleSelectedItems.isEmpty) {
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
            'Are you sure you want to delete ${visibleSelectedItems.length} selected row(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              print("errorCoordinates before delete: $errorCoordinates");
              setState(() {
                for (var entry in List.from(errorCoordinates)) {
                  String firstPart = entry.split(',')[0];
                  int firstValue = int.parse(firstPart);

                  if (visibleSelectedItems.contains(items[firstValue])) {
                    errorCoordinates.removeLast();
                  }
                }

                items
                    .removeWhere((item) => visibleSelectedItems.contains(item));

                _filteredItems
                    .removeWhere((item) => visibleSelectedItems.contains(item));

                _selectedItems.removeAll(visibleSelectedItems);
              });
              print("errorCoordinates after delete: $errorCoordinates");
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
    final columns = [
      'Item Name',
      'MRP',
      'Sale Price',
      'Quantity',
      'Minimum Stock Alert',
      'Unit',
      'HSN',
      'GST',
      'Cess'
    ];

    return DataTable2(
      scrollController: _scrollController,
      minWidth: columns.length * 130,
      dataRowHeight: 70,
      fixedTopRows: 1,
      fixedLeftColumns: 2,
      columns: getColumns(columns),
      rows: getRows(_filteredItems),
      showCheckboxColumn: true,
    );
  }

  List<DataColumn2> getColumns(List<String> columns) {
    return columns.map((column) {
      return DataColumn2(
        onSort: (columnIndex, ascending) {
          setState(() {
            isSortAscending =
                !isSortAscending; // Use the provided ascending parameter

            if (isSortAscending) {
              switch (columnIndex) {
                case 0:
                  _filteredItems
                      .sort((a, b) => a.itemName.compareTo(b.itemName));
                  break;
                case 1:
                  _filteredItems.sort((a, b) =>
                      double.parse(a.mrp).compareTo(double.parse(b.mrp)));
                  break;
                case 2:
                  _filteredItems.sort((a, b) => double.parse(a.salePrice)
                      .compareTo(double.parse(b.salePrice)));
                  break;
                case 3:
                  _filteredItems.sort((a, b) =>
                      int.parse(a.quantity).compareTo(int.parse(b.quantity)));
                  break;
              }
            } else {
              switch (columnIndex) {
                case 0:
                  _filteredItems
                      .sort((a, b) => b.itemName.compareTo(a.itemName));
                  break;
                case 1:
                  _filteredItems.sort((a, b) =>
                      double.parse(b.mrp).compareTo(double.parse(a.mrp)));
                  break;
                case 2:
                  _filteredItems.sort((a, b) => double.parse(b.salePrice)
                      .compareTo(double.parse(a.salePrice)));
                  break;
                case 3:
                  _filteredItems.sort((a, b) =>
                      int.parse(b.quantity).compareTo(int.parse(a.quantity)));
                  break;
              }
            }
          });
        },
        label: Text(
          column,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // numeric: isNumericColumn,
      );
    }).toList();
  }

  List<DataRow2> getRows(List<ItemModel> items) => items.asMap().entries.map(
        (entry) {
          int index = entry.key;
          ItemModel item = entry.value;

          final cells = [
            item.itemName,
            item.mrp,
            item.salePrice.toString(),
            item.quantity,
            item.minStockAlert,
            item.unit,
            item.hsn,
            item.gst,
            item.cess,
          ];

          return DataRow2(
            color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (index < errorCoordinates.length) {
                  return Colors.red.shade100;
                }
                return null;
              },
            ),
            cells: Utils.modelBuilder(
              cells,
              (cellIndex, cell) {
                Widget cellContent;

                if (cellIndex == 0 && index < errorCoordinates.length) {
                  cellContent = Text(
                    cell.toString(),
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  );
                } else {
                  cellContent = Text(cell.toString());
                }

                return DataCell(
                  cellIndex == 5
                      ? DropdownButton(
                          value: _dropdownItemsQuantity.firstWhere(
                              (element) =>
                                  element.toLowerCase() ==
                                  item.unit.toLowerCase(),
                              orElse: () => _dropdownItemsQuantity.first),
                          items: _dropdownItemsQuantity
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _updateItem(item, unit: newValue.toString());
                            });
                          })
                      : cellContent,
                  onTap: () {
                    switch (cellIndex) {
                      case 0:
                        editItemName(item);
                        break;
                      case 1:
                        editMrp(item);
                        break;
                      case 2:
                        editSalePrice(item);
                        break;
                      case 3:
                        editQuantity(item);
                        break;
                      case 4:
                        editMinStockAlert(item);
                        break;

                      case 6:
                        editHsn(item);
                        break;
                      case 7:
                        editgst(item);
                        break;
                      case 8:
                        editcess(item);
                    }
                  },
                );
              },
            ),
            selected: _selectedItems.contains(item),
            onSelectChanged: (isSelected) {
              setState(() {
                if (isSelected != null) {
                  isSelected
                      ? _selectedItems.add(item)
                      : _selectedItems.remove(item);
                }
              });
            },
          );
        },
      ).toList();

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

  Future<void> editQuantity(ItemModel editItem) async {
    final quantity = await showTextDialog(
      context,
      title: 'Edit Quantity',
      value: editItem.quantity,
    );

    setState(() {
      _updateItem(editItem, quantity: quantity);
    });
  }

  Future<void> editItemName(ItemModel editItem) async {
    final itemName = await showTextDialog(
      context,
      title: 'Edit Item Name',
      value: editItem.itemName,
    );

    setState(() {
      _updateItem(editItem, itemName: itemName);
    });
  }

  Future<void> editMinStockAlert(ItemModel editItem) async {
    final minStockAlert = await showTextDialog(
      context,
      title: 'Edit Minimum Stock Alert',
      value: editItem.minStockAlert,
    );

    setState(() {
      _updateItem(editItem, minStockAlert: minStockAlert);
    });
  }

  Future<void> editMrp(ItemModel editItem) async {
    final mrp = await showTextDialog(
      context,
      title: 'Edit MRP',
      value: editItem.mrp,
    );

    setState(() {
      _updateItem(editItem, mrp: mrp);
    });
  }

  Future<void> editSalePrice(ItemModel editItem) async {
    final salePriceString = await showTextDialog(
      context,
      title: 'Edit Sale Price',
      value: editItem.salePrice.toString(),
    );
    final salePrice = salePriceString ?? editItem.salePrice;

    setState(() {
      _updateItem(editItem, salePrice: salePrice);
    });
  }

  Future<void> editUnit(ItemModel editItem) async {
    final unit = await showTextDialog(
      context,
      title: 'Edit Unit',
      value: editItem.unit,
    );

    setState(() {
      _updateItem(editItem, unit: unit);
    });
  }

  Future<void> editHsn(ItemModel editItem) async {
    final hsn = await showTextDialog(
      context,
      title: 'Edit HSN',
      value: editItem.hsn,
    );

    setState(() {
      _updateItem(editItem, hsn: hsn);
    });
  }

  Future<void> editgst(ItemModel editItem) async {
    final gst = await showTextDialog(
      context,
      title: 'Edit Rate 1',
      value: editItem.gst,
    );

    setState(() {
      _updateItem(editItem, gst: gst);
    });
  }

  Future<void> editcess(ItemModel editItem) async {
    final cess = await showTextDialog(
      context,
      title: 'Edit Rate 2',
      value: editItem.cess,
    );

    setState(() {
      _updateItem(editItem, cess: cess);
    });
  }

// Helper function to update an item in the list
  void _updateItem(
    ItemModel editItem, {
    String? itemName,
    String? quantity,
    String? minStockAlert,
    String? mrp,
    String? salePrice,
    String? unit,
    String? hsn,
    String? gst,
    String? cess,
    int? flag,
  }) {
    final index = items
        .indexWhere((item) => item.originalIndex == editItem.originalIndex);
    if (index >= 0) {
      items[index] = editItem.copy(
        itemName: itemName,
        quantity: quantity,
        minStockAlert: minStockAlert,
        mrp: mrp,
        salePrice: salePrice,
        unit: unit,
        hsn: hsn,
        gst: gst,
        cess: cess,
        flag: flag,
      );
    }

    final filteredIndex = _filteredItems
        .indexWhere((item) => item.originalIndex == editItem.originalIndex);
    if (filteredIndex >= 0) {
      _filteredItems[filteredIndex] = editItem.copy(
        itemName: itemName,
        quantity: quantity,
        minStockAlert: minStockAlert,
        mrp: mrp,
        salePrice: salePrice,
        unit: unit,
        hsn: hsn,
        gst: gst,
        cess: cess,
        flag: flag,
      );
    }
  }

  submitList(String action) async {
    errorCoordinates = [];
    errorMessages = [];
    var token = await APIService.getToken();
    var apiKey = await APIService.getXApiKey();
    List<Map<String, dynamic>> uploadItems = [];

    for (var item in items) {
      //print(item.unit);
      uploadItems.add({
        'item_name': item.itemName,
        'quantity': item.quantity,
        'minimum_stock_alert': item.minStockAlert,
        'mrp': item.mrp,
        'sale_price': item.salePrice,
        'unit': item.unit.toUpperCase(),
        'hsn': item.hsn,
        'gst': item.gst,
        'cess': item.cess,
      });
    }

    EasyLoading.show(status: 'loading...');

    try {
      var response =
          await http.post(Uri.parse('$baseUrl/inventory-store-multiple'),
              headers: {
                'Authorization': 'Bearer $token',
                'auth-key': '$apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'items': uploadItems,
                'action': action,
              }));

      var jsonData = jsonDecode(response.body);
      print(jsonData['errors']['grid_coordinates']);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data uploaded successfully')));
      } else {
        setState(() {
          errorMessages = (jsonData['errors']['messages'] as List)
              .map((item) => item.toString())
              .toList();

          errorCoordinates = (jsonData['errors']['grid_coordinates'] as List)
              .map((item) => item.toString())
              .toList();

          items = parseItems(response.body);
          _filteredItems = List.from(items);
          print('object'); // Update filtered items
        });
      }
      //print(errorCoordinates);
    } catch (e) {
      //  print("error: $e");
    }

    EasyLoading.dismiss();
  }
}
