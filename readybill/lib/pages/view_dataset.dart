import 'dart:convert';
import 'dart:math';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:readybill/components/api_constants.dart';
import 'package:readybill/components/color_constants.dart';
import 'package:readybill/components/custom_components.dart';
import 'package:readybill/components/text_dialog_widget.dart';
import 'package:readybill/models/item_model.dart';

import 'package:readybill/services/api_services.dart';
import 'package:readybill/services/global_internet_connection_handler.dart';
import 'package:readybill/services/local_database_2.dart';
import 'package:readybill/services/result.dart';
import 'package:readybill/services/utils.dart';
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
  List<String> fullUnits = [
    'Full Unit',
    'Bags',
    'Bottle',
    'Box',
    'Bundle',
    'Can',
    'Cartoon',
    'Gram',
    'Kilogram',
    'Litre',
    'Meter',
    'Millilitre',
    'Number',
    'Pack',
    'Pair',
    'Piece',
    'Roll',
    'Square Feet',
    'Square Meter'
  ];
  List<String> shortUnits = [
    'Short Unit *',
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
  List<Widget> taxRateRows = [];
  List<Key> taxRateRowKeys = [];
  TextEditingController itemNameValueController = TextEditingController();
  TextEditingController mrpValueController = TextEditingController();
  TextEditingController salePriceValueController = TextEditingController();
  TextEditingController stockQuantityValueController = TextEditingController();
  TextEditingController codeHSNSACvalueController = TextEditingController();
  TextEditingController rateOneValueController = TextEditingController();
  TextEditingController rateTwoValueController = TextEditingController();
  TextEditingController minumumStockController = TextEditingController();

  Map<int, String> rateControllers = {};
  Map<int, String> taxControllers = {};

  String? fullUnitDropdownValue;
  String? shortUnitDropdownValue;

  bool maintainMRP = false;
  bool maintainStock = false;
  bool showHSNSACCode = false;
  bool isLoading = false;

  List<ItemModel> _filteredItems = [];
  String _searchTerm = '';
  List<ItemModel> items = [];
  var apiKey;

  var token;

  getItems(String reset) async {
    if (widget.jsonResponse == null) {
      token = await APIService.getToken();
      apiKey = await APIService.getXApiKey();
      EasyLoading.show(status: 'loading...');
      var response = await http.post(
        Uri.parse('$baseUrl/dataset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'auth-key': '$apiKey',
        },
        body: jsonEncode({
          'isReset': reset,
        }),
      );
      EasyLoading.dismiss();
      print(response.body);

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
    getItems('0');
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
          onPressed: _showNewRowDialog,
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
          errorMessages.isNotEmpty && errorCoordinates.isNotEmpty
              ? Container(
                  height: errorMessages.length <= 3
                      ? errorMessages.length * 50.0
                      : 150,
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.all(8.0),
                  child: Scrollbar(
                    trackVisibility: true,
                    thumbVisibility: true,
                    interactive: true,
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
              : const SizedBox.shrink(),
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
        tooltip: 'Submit',
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
            if (aHasError != bHasError) {
              return bHasError - aHasError; // Error rows first
            }

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

  Widget _buildCombinedDropdown(
      List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Color(0xffbfbfbf),
            width: 3.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: green2,
            width: 3.0,
          ),
        ),
      ),
      hint: const Text(
        'Full Unit (Short Unit)' ' *',
      ),
      value: fullUnitDropdownValue == null
          ? null
          : '$fullUnitDropdownValue ($shortUnitDropdownValue)', // Initial value
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTaxRateRow(Key key, int index, StateSetter dialogSetState) {
    bool isFirstRow = index == 0;
    bool isMaxRowsReached = taxRateRows.length >= 2;

    return Row(
      key: key,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
              value: taxControllers[index] ?? 'GST',
              onChanged: (String? value) {
                dialogSetState(() {
                  taxControllers[index] = value!;
                });
              },
              items: const [
                DropdownMenuItem<String>(
                  value: 'GST',
                  child: Text('GST'),
                ),
                DropdownMenuItem<String>(
                  value: 'SASS',
                  child: Text('SASS'),
                ),
              ],
              hint: const Text('Select Tax'),
              decoration: customTfInputDecoration("Select Tax")),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: TextField(
              controller:
                  index == 0 ? rateOneValueController : rateTwoValueController,
              keyboardType: TextInputType.number,
              decoration: customTfInputDecoration("Rate *")),
        ),
        IconButton(
          icon: Icon(isFirstRow ? Icons.add : Icons.remove),
          onPressed: () {
            try {
              if (isMaxRowsReached && isFirstRow) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return customAlertBox(
                      title: 'Warning',
                      content: 'You cannot add more than 2 tax rows.',
                      actions: <Widget>[
                        customElevatedButton("OK", green2, white, () {
                          navigatorKey.currentState?.pop();
                        }),
                      ],
                    );
                  },
                );
              } else {
                dialogSetState(() {
                  if (isFirstRow) {
                    var newKey = GlobalKey();
                    taxRateRowKeys.insert(index + 1, newKey);
                    taxRateRows.insert(index + 1,
                        _buildTaxRateRow(newKey, index + 1, dialogSetState));
                    rateControllers[index + 1] = '';
                    taxControllers[index + 1] = '';
                  } else {
                    taxRateRowKeys.removeAt(index);
                    taxRateRows.removeAt(index);
                    rateControllers.remove(index);
                    taxControllers.remove(index);
                  }
                });
              }
            } catch (e) {
              Result.error("Book list not available");
            }
          },
        ),
      ],
    );
  }

  void _showNewRowDialog() {
    showDialog(
        barrierDismissible: false,
        useSafeArea: false,
        context: context,
        builder: (context) {
          taxRateRows.clear();
          var key = GlobalKey();
          taxRateRowKeys.add(key);

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              if (taxRateRows.isEmpty) {
                taxRateRows.add(_buildTaxRateRow(key, 0, setState));
              }

              return AlertDialog(
                insetPadding: EdgeInsets.zero,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add New Row'),
                    IconButton(
                        onPressed: () {
                          navigatorKey.currentState!.pop();
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInputBox(' Item Name *', itemNameValueController,
                            (value) {
                          setState(() {
                            itemNameValueController.text = value;
                          });
                        }),
                        const SizedBox(height: 20.0),
                        Row(children: [
                          Expanded(
                            child: _buildCombinedDropdown(
                                fullUnits
                                    .map((unit) =>
                                        '$unit (${shortUnits[fullUnits.indexOf(unit)]})')
                                    .toList(), (value) {
                              List<String> units = value!.split(' (');
                              String fullUnit = units[0];
                              String shortUnit =
                                  units[1].substring(0, units[1].length - 1);
                              setState(() {
                                fullUnitDropdownValue = fullUnit;
                                shortUnitDropdownValue = shortUnit;
                              });
                            }),
                          )
                        ]),
                        const SizedBox(height: 20.0),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputBox(' Sale price: Rs. *',
                                  salePriceValueController, (value) {
                                setState(() {
                                  salePriceValueController.text = value;
                                });
                              }, isNumeric: true),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: _buildInputBox(
                                  ' MRP ${maintainMRP ? '*' : ''}',
                                  mrpValueController, (value) {
                                setState(() {
                                  mrpValueController.text = value;
                                });
                              }, isNumeric: true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputBox(
                                  ' Stock Quantity ${maintainStock ? '*' : ''}',
                                  stockQuantityValueController, (value) {
                                setState(() {
                                  stockQuantityValueController.text = value;
                                });
                              }, isNumeric: true),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                                child: Visibility(
                              visible:
                                  stockQuantityValueController.text.isNotEmpty,
                              child: _buildInputBox(
                                  ' Minimum Stock ', minumumStockController,
                                  (value) {
                                setState(() {
                                  minumumStockController.text = value;
                                });
                              }, isNumeric: true),
                            ))
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        _buildInputBox(
                            ' HSN/ SAC Code ${showHSNSACCode ? '*' : ''}',
                            codeHSNSACvalueController, (value) {
                          setState(() {
                            codeHSNSACvalueController.text = value;
                          });
                        }, isNumeric: true),
                        const SizedBox(height: 20.0),
                        Column(
                          children: [
                            for (int i = 0; i < taxRateRows.length; i++)
                              Column(
                                children: [
                                  taxRateRows[i],
                                  const SizedBox(height: 8.0),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
                actions: [
                  customElevatedButton('Save', green2, white, () async {
                    var response = await addNewRow();

                    print('response: $response');

                    if (response['status'] == 'success') {
                      navigatorKey.currentState!.pop();
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return customAlertBox(
                            title: 'Error',
                            content:
                                "${response['message']}\nPlease enter valid data.",
                            actions: [
                              customElevatedButton('OK', green2, white, () {
                                navigatorKey.currentState!.pop();
                              })
                            ],
                          );
                        },
                      );
                    }
                  }),
                  customElevatedButton('Cancel', red, white, () {
                    navigatorKey.currentState!.pop();
                  })
                ],
              );
            },
          );
        });
  }

  addNewRow() async {
    final newId =
        items.isEmpty ? 1 : items.map((u) => u.originalIndex).reduce(max) + 1;
    print(newId);

    final newItem = ItemModel(
      originalIndex: newId,
      itemName: itemNameValueController.text,
      quantity: stockQuantityValueController.text,
      minStockAlert: minumumStockController.text,
      mrp: mrpValueController.text,
      salePrice: salePriceValueController.text,
      unit: shortUnitDropdownValue ?? '',
      hsn: codeHSNSACvalueController.text,
      gst: rateOneValueController.text,
      cess: rateTwoValueController.text,
      flag: 0,
    );
    EasyLoading.show(status: 'loading...');
    var response =
        await http.post(Uri.parse('$baseUrl/update-cell-data'), headers: {
      'Authorization': 'Bearer $token',
      'auth-key': '$apiKey',
    }, body: {
      'id': '0',
      'row_index': '$newId',
      'item_name': newItem.itemName,
      'quantity': newItem.quantity,
      'min_stock_alert': newItem.minStockAlert,
      'mrp': newItem.mrp,
      'sale_price': newItem.salePrice,
      'short_unit': newItem.unit,
      'hsn': newItem.hsn,
      'gst': newItem.gst,
      'cess': newItem.cess,
    });
    EasyLoading.dismiss();
    if (response.statusCode == 200) {
      setState(() {
        items.add(newItem);

        if (_searchTerm.isEmpty) {
          _filteredItems.add(newItem);
        }
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent + 70);
      });
    }
    print(jsonDecode(response.body));
    return jsonDecode(response.body);
  }

  Widget _buildInputBox(String hintText, TextEditingController textControllers,
      void Function(String) updateIdentifier,
      {bool isNumeric = false}) {
    return TextField(
      controller: textControllers,
      decoration: customTfInputDecoration("$hintText "),
      keyboardType: isNumeric
          ? TextInputType.number
          : TextInputType.text, // Set keyboardType based on isNumeric flag
      onChanged: (value) {
        updateIdentifier(
            value); // Call the callback function to update the identifier
      },
    );
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
                              _updateItem(item,
                                  unit: newValue.toString(), cellIndex: 6);
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
      _updateItem(editItem, quantity: quantity, cellIndex: 2);
    });
  }

  Future<void> editItemName(ItemModel editItem) async {
    final itemName = await showTextDialog(
      context,
      title: 'Edit Item Name',
      value: editItem.itemName,
    );

    setState(() {
      _updateItem(editItem, itemName: itemName, cellIndex: 1);
    });
  }

  Future<void> editMinStockAlert(ItemModel editItem) async {
    final minStockAlert = await showTextDialog(
      context,
      title: 'Edit Minimum Stock Alert',
      value: editItem.minStockAlert,
    );

    setState(() {
      _updateItem(editItem, minStockAlert: minStockAlert, cellIndex: 3);
    });
  }

  Future<void> editMrp(ItemModel editItem) async {
    final mrp = await showTextDialog(
      context,
      title: 'Edit MRP',
      value: editItem.mrp,
    );

    setState(() {
      _updateItem(editItem, mrp: mrp, cellIndex: 4);
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
      _updateItem(editItem, salePrice: salePrice, cellIndex: 5);
    });
  }

  Future<void> editHsn(ItemModel editItem) async {
    final hsn = await showTextDialog(
      context,
      title: 'Edit HSN',
      value: editItem.hsn,
    );

    setState(() {
      _updateItem(editItem, hsn: hsn, cellIndex: 9);
    });
  }

  Future<void> editgst(ItemModel editItem) async {
    final gst = await showTextDialog(
      context,
      title: 'Edit Rate 1',
      value: editItem.gst,
    );

    setState(() {
      _updateItem(editItem, gst: gst, cellIndex: 7);
    });
  }

  Future<void> editcess(ItemModel editItem) async {
    final cess = await showTextDialog(
      context,
      title: 'Edit Rate 2',
      value: editItem.cess,
    );

    setState(() {
      _updateItem(editItem, cess: cess, cellIndex: 8);
    });
  }

// Helper function to update an item in the list
  void _updateItem(ItemModel editItem,
      {String? itemName,
      String? quantity,
      String? minStockAlert,
      String? mrp,
      String? salePrice,
      String? unit,
      String? hsn,
      String? gst,
      String? cess,
      int? flag,
      required int cellIndex}) async {
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

    print('cellIndex: $cellIndex');

    EasyLoading.show(status: 'loading...');
    var response =
        await http.post(Uri.parse('$baseUrl/update-cell-data'), headers: {
      'Authorization': 'Bearer $token',
      'auth-key': '$apiKey',
    }, body: {
      'id': (_filteredItems[filteredIndex].originalIndex + 1).toString(),
      'cell_index': cellIndex.toString(),
      'row_index': items.indexOf(_filteredItems[filteredIndex]).toString(),
      'item_name': _filteredItems[filteredIndex].itemName,
      'quantity': _filteredItems[filteredIndex].quantity,
      'min_stock_alert': _filteredItems[filteredIndex].minStockAlert,
      'mrp': _filteredItems[filteredIndex].mrp,
      'sale_price': _filteredItems[filteredIndex].salePrice,
      'unit': _filteredItems[filteredIndex].unit,
      'hsn': _filteredItems[filteredIndex].hsn,
      'gst': _filteredItems[filteredIndex].gst,
      'cess': _filteredItems[filteredIndex].cess,
    });
    EasyLoading.dismiss();
    if (response.statusCode == 200) {
      print('success');
      print(response.body);
    } else {
      print(editItem.originalIndex + 1);
      print(cellIndex);
      print(response.statusCode);
      print(response.body);
      print('failed');
    }
  }

  submitList(String action) async {
    errorCoordinates = [];
    errorMessages = [];
    var token = await APIService.getToken();
    var apiKey = await APIService.getXApiKey();
    List<Map<String, dynamic>> uploadItems = [];
    print('submitList');
    for (var item in items) {
      uploadItems.add({
        'item_name': item.itemName,
        'quantity': item.quantity,
        'min_stock_alert': item.minStockAlert,
        'mrp': item.mrp,
        'sale_price': item.salePrice,
        'unit': item.unit.toUpperCase(),
        'hsn': item.hsn,
        'gst': item.gst,
        'cess': item.cess,
      });
    }
    var jsonData;

    // EasyLoading.show(status: 'loading...');

    // try {

    var request = http.post(Uri.parse('$baseUrl/inventory-store-multiple'),
        headers: {
          'Authorization': 'Bearer $token',
          'auth-key': '$apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'items': uploadItems,
          'action': action,
        }));
    var response = await request;
    print("request: ${jsonEncode({
          'items': uploadItems,
          'action': action,
        })}");

    jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print('successful');
      LocalDatabase2.instance.clearTable();
      LocalDatabase2.instance.fetchDataAndStoreLocally();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data uploaded successfully')));
    } else {
      print('failed');
      print(response.body);
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
    //  }
    //  catch (e) {
    //   print('jsonData: $jsonData');
    //   print("error: $e");
    // }

    // EasyLoading.dismiss();
  }
}
