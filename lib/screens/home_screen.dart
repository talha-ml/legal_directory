import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../database/db_helper.dart';
import '../models/client_model.dart';
import '../services/pdf_service.dart'; // PDF Service yahan import ho gayi hai
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ClientModel> clients = [];
  List<ClientModel> filteredClients = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Database se records read karna
  Future<void> _refreshList() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.queryAllRows();
    setState(() {
      clients = data;
      filteredClients = data;
      isLoading = false;
    });
  }

  // Search Logic
  void _runFilter(String enteredKeyword) {
    List<ClientModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = clients;
    } else {
      results = clients
          .where((client) =>
      client.name.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
          client.email.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredClients = results;
    });
  }

  // Safe Delete Operation (with confirmation)
  Future<void> _confirmDelete(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Record', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this case record?', style: GoogleFonts.poppins()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.delete(id);
              _refreshList();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Case record deleted successfully!', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Amin Gill Law Associates',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Search cases by name or category...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0B132B)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _runFilter('');
                    FocusScope.of(context).unfocus();
                  },
                )
                    : null,
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredClients.isEmpty
                ? _buildEmptyState()
                : _buildClientList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditScreen()),
          );
          _refreshList();
          _searchController.clear();
        },
        icon: const Icon(Icons.add_business_rounded),
        label: Text('New Case', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey.shade300)
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty ? 'No active cases found.' : 'No results match your search.',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          if (_searchController.text.isEmpty)
            Text(
              'Tap the button below to add a record.',
              style: GoogleFonts.poppins(color: Colors.grey.shade500),
            ),
        ],
      ).animate().fade(duration: 400.ms),
    );
  }

  Widget _buildClientList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredClients.length,
      itemBuilder: (context, index) {
        final client = filteredClients[index];
        return Card(
          elevation: 2,
          shadowColor: Colors.black12,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditScreen(client: client)),
              );
              _refreshList();
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Profile Image
                  Hero(
                    tag: 'profile_${client.id}',
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      backgroundImage: client.image.isNotEmpty ? FileImage(File(client.image)) : null,
                      child: client.image.isEmpty
                          ? Icon(Icons.person, size: 32, color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Case Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: const Color(0xFF0B132B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            client.email, // Category
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF0B132B)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.gavel_rounded, size: 14, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text(
                              'Hearing No: ${client.age}',
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Menu (PDF, Edit, Delete)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddEditScreen(client: client)),
                        );
                        _refreshList();
                      } else if (value == 'pdf') {
                        // PDF Generation trigger
                        await PdfService.generateAndPrintPdf(client);
                      } else if (value == 'delete') {
                        _confirmDelete(client.id!);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'pdf',
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.blueAccent, size: 20),
                            const SizedBox(width: 10),
                            Text('Generate PDF', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, color: Colors.orange, size: 20),
                            const SizedBox(width: 10),
                            Text('Edit Record', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red, size: 20),
                            const SizedBox(width: 10),
                            Text('Delete', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
      },
    );
  }
}