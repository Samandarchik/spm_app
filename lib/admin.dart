// // ================ ADMIN USER MANAGEMENT PAGE ================
// // pages/admin_user_management_page.dart
// import 'package:flutter/material.dart';
// import 'package:mone_app/admin/model/user_model.dart';
// import 'package:mone_app/admin/services/user_management_service.dart';
// import 'package:mone_app/admin/pages/edit_user_page.dart';

// class AdminUserManagementPage extends StatefulWidget {
//   const AdminUserManagementPage({super.key});

//   @override
//   State<AdminUserManagementPage> createState() =>
//       _AdminUserManagementPageState();
// }
// lib/422db6c0-42fc-4792-ae4b-773343abd446.png
// class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
//   final UserManagementService _userService = UserManagementService();
  
//   List<User> _users = [];
//   List<User> _filteredUsers = [];
//   bool _isLoading = false;
//   String _errorMessage = '';
  
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _filterType = 'all'; // all, admin, user

//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = _searchController.text.toLowerCase();
//       _applyFilters();
//     });
//   }

//   void _applyFilters() {
//     _filteredUsers = _users.where((user) {
//       // Search filter
//       final matchesSearch = user.name.toLowerCase().contains(_searchQuery) ||
//           user.phone.toLowerCase().contains(_searchQuery);

//       // Type filter
//       final matchesType = _filterType == 'all' ||
//           (_filterType == 'admin' && user.isAdmin) ||
//           (_filterType == 'user' && !user.isAdmin);

//       return matchesSearch && matchesType;
//     }).toList();
//   }

//   Future<void> _loadUsers() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final users = await _userService.getAllUsers();
//       setState(() {
//         _users = users;
//         _applyFilters();
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _deleteUser(User user) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
//             const SizedBox(width: 12),
//             Text('delete_user'.tr()),
//           ],
//         ),
//         content: Text(
//           'delete_user_confirm'.tr(args: [user.name]),
//           style: const TextStyle(fontSize: 16),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('cancel'.tr()),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red.shade600,
//               foregroundColor: Colors.white,
//             ),
//             child: Text('delete'.tr()),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     try {
//       await _userService.deleteUser(user.id);
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.white),
//                 const SizedBox(width: 12),
//                 Text('user_deleted_success'.tr()),
//               ],
//             ),
//             backgroundColor: Colors.green.shade600,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//         _loadUsers();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white),
//                 const SizedBox(width: 12),
//                 Expanded(child: Text(e.toString())),
//               ],
//             ),
//             backgroundColor: Colors.red.shade600,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }

//   void _navigateToCreateUser() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const EditUserPage(),
//       ),
//     ).then((result) {
//       if (result == true) {
//         _loadUsers();
//       }
//     });
//   }

//   void _navigateToEditUser(User user) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditUserPage(user: user),
//       ),
//     ).then((result) {
//       if (result == true) {
//         _loadUsers();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: Text(
//           'user_management'.tr(),
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.blue.shade600,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadUsers,
//             tooltip: 'refresh'.tr(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search and Filter Section
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Search Field
//                 TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'search_users'.tr(),
//                     prefixIcon: const Icon(Icons.search),
//                     suffixIcon: _searchQuery.isNotEmpty
//                         ? IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: () {
//                               _searchController.clear();
//                             },
//                           )
//                         : null,
//                     filled: true,
//                     fillColor: Colors.grey.shade100,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
                
//                 // Filter Chips
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       _buildFilterChip(
//                         label: 'all_users'.tr(),
//                         value: 'all',
//                         count: _users.length,
//                       ),
//                       const SizedBox(width: 8),
//                       _buildFilterChip(
//                         label: 'admins'.tr(),
//                         value: 'admin',
//                         count: _users.where((u) => u.isAdmin).length,
//                       ),
//                       const SizedBox(width: 8),
//                       _buildFilterChip(
//                         label: 'users'.tr(),
//                         value: 'user',
//                         count: _users.where((u) => !u.isAdmin).length,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Users List
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator.adaptive())
//                 : _errorMessage.isNotEmpty
//                     ? _buildErrorWidget()
//                     : _filteredUsers.isEmpty
//                         ? _buildEmptyWidget()
//                         : RefreshIndicator(
//                             onRefresh: _loadUsers,
//                             child: ListView.builder(
//                               padding: const EdgeInsets.all(16),
//                               itemCount: _filteredUsers.length,
//                               itemBuilder: (context, index) {
//                                 final user = _filteredUsers[index];
//                                 return _buildUserCard(user);
//                               },
//                             ),
//                           ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _navigateToCreateUser,
//         backgroundColor: Colors.blue.shade600,
//         icon: const Icon(Icons.person_add),
//         label: Text('add_user'.tr()),
//       ),
//     );
//   }

//   Widget _buildFilterChip({
//     required String label,
//     required String value,
//     required int count,
//   }) {
//     final isSelected = _filterType == value;
//     return FilterChip(
//       label: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(label),
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//             decoration: BoxDecoration(
//               color: isSelected ? Colors.white : Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               count.toString(),
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: isSelected ? Colors.blue.shade700 : Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//       selected: isSelected,
//       onSelected: (selected) {
//         setState(() {
//           _filterType = value;
//           _applyFilters();
//         });
//       },
//       selectedColor: Colors.blue.shade100,
//       checkmarkColor: Colors.blue.shade700,
//     );
//   }

//   Widget _buildUserCard(User user) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       child: InkWell(
//         onTap: () => _navigateToEditUser(user),
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Avatar
//               Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: user.isAdmin
//                       ? Colors.purple.shade100
//                       : Colors.blue.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   user.isAdmin ? Icons.admin_panel_settings : Icons.person,
//                   color: user.isAdmin
//                       ? Colors.purple.shade700
//                       : Colors.blue.shade700,
//                   size: 28,
//                 ),
//               ),
//               const SizedBox(width: 16),

//               // User Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             user.name,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         if (user.isAdmin)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.purple.shade50,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               'Admin',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.purple.shade700,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.phone,
//                           size: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           user.phone,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade700,
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (user.filialName != null) ...[
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.business,
//                             size: 14,
//                             color: Colors.grey.shade600,
//                           ),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               user.filialName!,
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade600,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                     if (user.categoryIds != null &&
//                         user.categoryIds!.isNotEmpty) ...[
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.category,
//                             size: 14,
//                             color: Colors.grey.shade600,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${user.categoryIds!.length} kategoriya',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ],
//                 ),
//               ),

//               // Actions
//               PopupMenuButton<String>(
//                 icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 itemBuilder: (context) => [
//                   PopupMenuItem(
//                     value: 'edit',
//                     child: Row(
//                       children: [
//                         Icon(Icons.edit, size: 20, color: Colors.blue.shade700),
//                         const SizedBox(width: 12),
//                         Text('edit'.tr()),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem(
//                     value: 'delete',
//                     child: Row(
//                       children: [
//                         Icon(Icons.delete, size: 20, color: Colors.red.shade700),
//                         const SizedBox(width: 12),
//                         Text('delete'.tr()),
//                       ],
//                     ),
//                   ),
//                 ],
//                 onSelected: (value) {
//                   if (value == 'edit') {
//                     _navigateToEditUser(user);
//                   } else if (value == 'delete') {
//                     _deleteUser(user);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 80,
//               color: Colors.red.shade300,
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'error_loading_users'.tr(),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade800,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _errorMessage,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _loadUsers,
//               icon: const Icon(Icons.refresh),
//               label: Text('retry'.tr()),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue.shade600,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyWidget() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               _searchQuery.isNotEmpty
//                   ? Icons.search_off
//                   : Icons.people_outline,
//               size: 80,
//               color: Colors.grey.shade300,
//             ),
//             const SizedBox(height: 24),
//             Text(
//               _searchQuery.isNotEmpty
//                   ? 'no_users_found'.tr()
//                   : 'no_users_yet'.tr(),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade800,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _searchQuery.isNotEmpty
//                   ? 'try_different_search'.tr()
//                   : 'add_first_user'.tr(),
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             if (_searchQuery.isEmpty) ...[
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: _navigateToCreateUser,
//                 icon: const Icon(Icons.person_add),
//                 label: Text('add_user'.tr()),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade600,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }