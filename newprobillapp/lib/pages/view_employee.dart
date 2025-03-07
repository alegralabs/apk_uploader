import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:newprobillapp/components/api_constants.dart';
import 'package:newprobillapp/components/bottom_navigation_bar.dart';
import 'package:newprobillapp/components/custom_components.dart';
import 'package:newprobillapp/components/color_constants.dart';
import 'package:newprobillapp/components/sidebar.dart';
import 'package:newprobillapp/pages/employee_signup.dart';
import 'package:newprobillapp/pages/view_employee_details.dart';
import 'package:newprobillapp/services/api_services.dart';

class Employee {
  final int id;
  final String name;
  final String mobile;
  final String address;
  final String photo;

  Employee({
    required this.id,
    required this.name,
    required this.mobile,
    required this.address,
    required this.photo,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['staff_id'],
      name: json['name'],
      mobile: json['mobile'],
      address: json['address'],
      photo: json['photo'],
    );
  }
}

class EmployeeService {
  static const String apiUrl = '$baseUrl/all-sub-users-without-pagination';

  static Future<List<Employee>> fetchEmployees() async {
    var token = await APIService.getToken();
    var apiKey = await APIService.getXApiKey();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'auth-key': '$apiKey',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      final List<dynamic> EmployeesData = jsonData['data'];

      print(EmployeesData);
      //  print('employees data: $EmployeesData');
      var data = EmployeesData.map((json) => Employee.fromJson(json)).toList();

      return data;
    } else {
      throw Exception(response.body);
    }
  }
}

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final int _rowsPerPage = 30;

  final List<Employee> _employees = [];
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _selectedIndex = 3;
  int _noOfEmployees = 0;
  String _selectedColumn = 'Name';

  String _searchQuery = '';

  List<Employee> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    if (!_hasMoreData) return; // No more data to load
    setState(() {
      _isLoadingMore = true;
    });

    try {
      List<Employee> fetchedEmployees = await EmployeeService.fetchEmployees();
      _noOfEmployees = fetchedEmployees.length;
      setState(() {
        _filteredEmployees.addAll(fetchedEmployees);
        _employees.addAll(fetchedEmployees);

        if (fetchedEmployees.length < _rowsPerPage) {
          _hasMoreData = false; // No more data to load
        }
      });
    } catch (error) {
      print("Error fetching sub-users: $error");
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _fetchEmployees(); // Fetch more data when reaching the bottom
    }
  }

  _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredEmployees = _searchEmployees(_searchQuery);
    });
  }

  List<Employee> _searchEmployees(String query) {
    if (query.isEmpty) {
      return _employees;
    } else {
      return _employees.where((employee) {
        switch (_selectedColumn) {
          case 'Name':
            return employee.name.toLowerCase().contains(query);
          case 'Mobile':
            return employee.mobile.toLowerCase().contains(query);
          case 'Address':
            return employee.address.toLowerCase().contains(query);
          default:
            return false;
        }
      }).toList();
    }
  }

  void _handleColumnSelect(String? columnName) {
    setState(() {
      _selectedColumn = columnName!;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isKeyboardVisible
          ? null
          : FloatingActionButton(
              backgroundColor: green2,
              foregroundColor: black,
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const EmployeeSignUpPage(),
                  ),
                );
              },
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: CustomNavigationBar(
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
      ),
      drawer: const Drawer(
        child: Sidebar(),
      ),
      appBar: customAppBar("Employees"),
      body: Column(
        children: [
          _SearchBar(
              onSearch: _handleSearch,
              selectedColumn: _selectedColumn,
              onColumnSelect: _handleColumnSelect),
          _employees.isNotEmpty
              ? Text(_noOfEmployees > 0
                  ? 'Total Employees: $_noOfEmployees'
                  : 'No Employees Found')
              : const SizedBox.shrink(),
          const Divider(
            thickness: 1,
            height: 5,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Mobile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 1,
            height: 5,
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(
                thickness: 0.2,
                height: 0,
              ),
              controller: _scrollController,
              itemCount: _filteredEmployees.length + 1,
              itemBuilder: (context, index) {
                if (index == _filteredEmployees.length) {
                  return _isLoadingMore
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox();
                }
                final employee = _filteredEmployees[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            ViewEmployeeDetails(user: employee),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2, // Larger space for item name
                          child: Text(
                            employee.name,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2, // Larger space for item name
                          child: Text(
                            employee.mobile,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String selectedColumn;
  final Function(String?) onColumnSelect;

  const _SearchBar({
    required this.onSearch,
    required this.selectedColumn,
    required this.onColumnSelect,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final List<String> _columnNames = [
    'Name',
    'Mobile',
    'Address',
  ];
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          focusNode: focusNode,
          onTap: () {
            setState(() {});
          },
          onSubmitted: (value) {
            setState(() {});
          },
          onChanged: widget.onSearch,
          decoration: customTfDecorationWithSuffix(
              "Search",
              DropdownButton<String>(
                value: widget.selectedColumn,
                onChanged: widget.onColumnSelect,
                style: const TextStyle(color: Colors.black),
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                items: _columnNames.map((columnName) {
                  return DropdownMenuItem<String>(
                    value: columnName,
                    child: Text(columnName),
                  );
                }).toList(),
              ),
              focusNode)),
    );
  }
}
