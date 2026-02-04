import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; // Needed for Date formatting

// --- Data Model ---
class Project {
  final int id;
  final String title;
  final String description;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String assignedTo;
  final String budget;
  final String expense;
  final String expenseHistory; // Stores logs like "Hosting: $50"
  final String deadline;
  final String priority;
  final int progress;
  final String phase;
  final String resources;
  final int rating;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.assignedTo,
    required this.budget,
    required this.expense,
    required this.expenseHistory,
    required this.deadline,
    required this.priority,
    required this.progress,
    required this.phase,
    required this.resources,
    required this.rating,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? "No details.",
      clientName: json['client_name'],
      clientEmail: json['client_email'] ?? "",
      clientPhone: json['client_phone'] ?? "",
      assignedTo: json['assigned_to'] ?? "Unassigned",
      budget: json['budget'],
      expense: json['expense'] ?? "0.00",
      expenseHistory: json['expense_history'] ?? "",
      deadline: json['deadline'],
      priority: json['priority'] ?? "Medium",
      progress: json['progress'] ?? 0,
      phase: json['phase'] ?? "Planning",
      resources: json['resources'] ?? "",
      rating: json['rating'] ?? 0,
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agency Manager',
      themeMode: ThemeMode.system,
      
      // Light Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Colors.indigo, foregroundColor: Colors.white),
        cardTheme: CardThemeData(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), color: Colors.white, surfaceTintColor: Colors.white),
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      ),

      // Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Color(0xFF1E1E2C), foregroundColor: Colors.white),
        cardTheme: CardThemeData(elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), color: const Color(0xFF1E1E2C), surfaceTintColor: const Color(0xFF1E1E2C)),
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xFF2C2C3E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      ),
      home: const ProjectListScreen(),
    );
  }
}

// --- Dashboard Screen ---
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Project> allProjects = [];
  bool isLoading = true;
  bool showCompleted = false;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    // NOTE: Use 10.0.2.2 for Emulator, 127.0.0.1 for Web
    final url = Uri.parse('https://sagarm.pythonanywhere.com/api/projects/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          allProjects = data.map((json) => Project.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<Project> get currentList {
    return showCompleted
        ? allProjects.where((p) => p.progress == 100).toList()
        : allProjects.where((p) => p.progress < 100).toList();
  }

  @override
  Widget build(BuildContext context) {
    int ongoingCount = allProjects.where((p) => p.progress < 100).length;
    int completedCount = allProjects.where((p) => p.progress == 100).length;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('ScalerVerse Dashboard')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            child: Row(
              children: [
                _buildSummaryCard("Active", "$ongoingCount", Colors.orange, !showCompleted, isDark),
                const SizedBox(width: 15),
                _buildSummaryCard("Done", "$completedCount", Colors.green, showCompleted, isDark),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(children: [_buildToggleBtn("Ongoing", !showCompleted), const SizedBox(width: 10), _buildToggleBtn("Completed", showCompleted)]),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentList.length,
                    itemBuilder: (context, index) {
                      final project = currentList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text("Client: ${project.clientName} | ${project.phase}"),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: project.progress / 100, 
                                backgroundColor: Colors.grey.withOpacity(0.2), 
                                color: showCompleted ? Colors.green : Colors.indigoAccent
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectDetailScreen(project: project))).then((_) => fetchProjects()),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProjectScreen()));
          if (result == true) fetchProjects();
        },
        label: const Text("New Project"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color, bool isActive, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : (isDark ? const Color(0xFF2C2C3E) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? color : Colors.transparent),
        ),
        child: Column(children: [
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isActive ? color : Colors.grey)),
          Text(title, style: TextStyle(color: isActive ? color : Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isSelected) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => showCompleted = text == "Completed"),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.indigo : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.grey,
          elevation: 0,
        ),
        child: Text(text),
      ),
    );
  }
}

// --- Project Details Screen ---
class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Project _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  Future<void> _refreshData() async {
    final url = Uri.parse('https://sagarm.pythonanywhere.com/api/projects/${_project.id}/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() => _project = Project.fromJson(json.decode(response.body)));
    }
  }

  // --- DELETE LOGIC ---
  Future<void> _deleteProject() async {
    final confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Project?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: ()=> Navigator.pop(ctx, true), child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      )
    );

    if (confirm == true) {
      final url = Uri.parse('https://sagarm.pythonanywhere.com/api/projects/${_project.id}/');
      await http.delete(url);
      if (mounted) Navigator.pop(context);
    }
  }

  // --- EDIT & ADD EXPENSE DIALOG ---
  void _showEditDialog() {
    final linksC = TextEditingController(text: _project.resources);
    final newExpenseAmountC = TextEditingController();
    final newExpenseReasonC = TextEditingController();
    
    String selectedPhase = _project.phase;
    double rating = _project.rating.toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Project"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedPhase,
                  decoration: const InputDecoration(labelText: "Phase"),
                  items: ['Planning', 'Designing', 'Development', 'Testing', 'Deployed'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => selectedPhase = v!,
                ),
                const SizedBox(height: 15),
                const Text("Client Rating"),
                StatefulBuilder(builder: (context, setState) => Slider(value: rating, min: 0, max: 5, divisions: 5, label: rating.toInt().toString(), onChanged: (v) => setState(() => rating = v))),
                
                const Divider(height: 30),
                const Text("Add New Expense", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(flex: 1, child: TextFormField(controller: newExpenseAmountC, decoration: const InputDecoration(labelText: "Amount \$"), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: TextFormField(controller: newExpenseReasonC, decoration: const InputDecoration(labelText: "Reason (e.g. Server)"))),
                ]),

                const Divider(height: 30),
                TextFormField(controller: linksC, decoration: const InputDecoration(labelText: "Resource Links"), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                double currentTotal = double.tryParse(_project.expense) ?? 0;
                double addedAmount = double.tryParse(newExpenseAmountC.text) ?? 0;
                String addedReason = newExpenseReasonC.text;
                
                double newTotal = currentTotal + addedAmount;
                String newHistory = _project.expenseHistory;
                
                if (addedAmount > 0) {
                  newHistory = "$newHistory\n$addedReason: \$$addedAmount".trim();
                }

                final url = Uri.parse('https://sagarm.pythonanywhere.com/api/projects/${_project.id}/');
                await http.patch(
                  url, 
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "phase": selectedPhase,
                    "rating": rating.toInt(),
                    "resources": linksC.text,
                    "expense": newTotal.toString(),
                    "expense_history": newHistory
                  })
                );
                Navigator.pop(context);
                _refreshData();
              },
              child: const Text("Save Updates"),
            )
          ],
        );
      },
    );
  }

  // --- OFFICIAL INVOICE GENERATOR ---
  Future<void> _generateInvoice() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();
    
    // Calculate totals
    double budget = double.tryParse(_project.budget) ?? 0;
    double expenses = double.tryParse(_project.expense) ?? 0;
    double grandTotal = budget + expenses;

    // Parse expense history for table
    List<List<String>> tableData = [
      ['Description', 'Amount'], // Header
      ['Project Development Fee (${_project.title})', '\$${_project.budget}'], // Base budget
    ];

    // Add individual expenses to table
    List<String> expenseLogs = _project.expenseHistory.split('\n').where((s) => s.trim().isNotEmpty).toList();
    for (var log in expenseLogs) {
      // Assuming log format "Reason: $Amount"
      var parts = log.split(':');
      if (parts.length == 2) {
        tableData.add(["Expense: ${parts[0]}", parts[1]]);
      }
    }

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("INVOICE", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                  pw.Text("ScalerVerse Ltd.", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Address Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Bill From:", style: pw.TextStyle(color: PdfColors.grey)),
                      pw.Text("ScalerVerse Ltd.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("Dhaka, Bangladesh"),
                      pw.Text("contact@scalerverse.com"),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Bill To:", style: pw.TextStyle(color: PdfColors.grey)),
                      pw.Text(_project.clientName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(_project.clientEmail),
                      pw.Text("Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}"),
                    ]
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Items Table
              pw.Table.fromTextArray(
                context: context,
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                },
                data: tableData,
              ),
              pw.Divider(),
              
              // Totals
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Subtotal: \$${grandTotal.toStringAsFixed(2)}"),
                    pw.SizedBox(height: 5),
                    pw.Text("Total Due: \$${grandTotal.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                  ]
                )
              ),
              
              pw.Spacer(),
              pw.Center(child: pw.Text("Thank you for your business!", style: const pw.TextStyle(color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    double budget = double.tryParse(_project.budget) ?? 0;
    double expense = double.tryParse(_project.expense) ?? 0;
    double profit = budget - expense;
    List<String> links = _project.resources.split(RegExp(r'[\n,]')).where((s) => s.trim().isNotEmpty).toList();
    List<String> expenseLogs = _project.expenseHistory.split('\n').where((s) => s.trim().isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Overview"),
        actions: [
          IconButton(onPressed: _showEditDialog, icon: const Icon(Icons.edit_note), tooltip: "Edit & Add Expense"),
          IconButton(onPressed: _deleteProject, icon: const Icon(Icons.delete_forever, color: Colors.redAccent), tooltip: "Delete Project"),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profit Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: profit >= 0 ? [Colors.green.shade700, Colors.green.shade500] : [Colors.red.shade700, Colors.red.shade500]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Net Profit", style: TextStyle(color: Colors.white70)),
                    Text("\$${profit.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text("Spent: \$$expense", style: const TextStyle(color: Colors.white)),
                    Text("Budget: \$$budget", style: const TextStyle(color: Colors.white70)),
                  ])
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Progress Slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Progress"), Text("${_project.progress}%", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))]),
                  Slider(value: _project.progress.toDouble(), min: 0, max: 100, divisions: 100, onChanged: (val) async {
                    final url = Uri.parse('https://sagarm.pythonanywhere.com/api/projects/${_project.id}/');
                    await http.patch(url, headers: {"Content-Type": "application/json"}, body: jsonEncode({"progress": val.toInt()}));
                    _refreshData();
                  }),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // ACTION BUTTONS (Email Added Here)
            Row(children: [
              Expanded(child: ElevatedButton.icon(onPressed: () => launchUrl(Uri.parse("tel:${_project.clientPhone}")), icon: const Icon(Icons.call), label: const Text("Call"))),
              const SizedBox(width: 10),
              // Email Button Restored
              Expanded(child: ElevatedButton.icon(onPressed: () => launchUrl(Uri.parse("mailto:${_project.clientEmail}")), icon: const Icon(Icons.email), label: const Text("Email"))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(onPressed: _generateInvoice, icon: const Icon(Icons.receipt), label: const Text("Invoice"))),
            ]),
            const SizedBox(height: 25),

            // Details
            _sectionTitle("DETAILS"),
            _infoTile("Description", _project.description),
            _infoTile("Current Phase", _project.phase),
            _infoTile("Assigned To", _project.assignedTo),
            _infoTile("Deadline", _project.deadline),
            
            const SizedBox(height: 20),
            _sectionTitle("EXPENSE HISTORY"),
            expenseLogs.isEmpty 
              ? const Text("No expenses recorded yet.", style: TextStyle(color: Colors.grey))
              : Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: expenseLogs.map((log) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        const Icon(Icons.remove_circle_outline, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(log, style: const TextStyle(fontSize: 15))
                      ]),
                    )).toList(),
                  ),
                ),

            const SizedBox(height: 20),
            _sectionTitle("RESOURCES"),
            links.isEmpty 
              ? const Text("No links added.", style: TextStyle(color: Colors.grey))
              : Column(children: links.map((link) => ListTile(
                  leading: const Icon(Icons.link, color: Colors.blue),
                  title: Text(link.trim(), style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                  onTap: () => launchUrl(Uri.parse(link.trim())),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )).toList()),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)));
  
  Widget _infoTile(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value.isEmpty ? "N/A" : value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// --- Create Project Form ---
class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});
  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final clientC = TextEditingController();
  final phoneC = TextEditingController();
  final emailC = TextEditingController();
  final assignedToC = TextEditingController();
  final budgetC = TextEditingController();
  final resourcesC = TextEditingController();
  final dateC = TextEditingController();
  String selectedPriority = 'Medium';

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('https://sagarm.pythonanywhere.com/api/projects/');
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": titleC.text, "description": descC.text,
          "client_name": clientC.text, "client_email": emailC.text, "client_phone": phoneC.text,
          "assigned_to": assignedToC.text, "priority": selectedPriority,
          "budget": budgetC.text, "resources": resourcesC.text, "deadline": dateC.text,
          "expense": "0.00", "expense_history": "", "rating": 0, "progress": 0
        }),
      );
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Project")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: titleC, decoration: const InputDecoration(labelText: "Title"), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 15),
              TextFormField(controller: descC, decoration: const InputDecoration(labelText: "Description"), maxLines: 2),
              const SizedBox(height: 15),
              TextFormField(controller: clientC, decoration: const InputDecoration(labelText: "Client Name"), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 15),
              Row(children: [Expanded(child: TextFormField(controller: phoneC, decoration: const InputDecoration(labelText: "Phone"))), const SizedBox(width: 15), Expanded(child: TextFormField(controller: emailC, decoration: const InputDecoration(labelText: "Email")))]),
              const SizedBox(height: 15),
              TextFormField(controller: assignedToC, decoration: const InputDecoration(labelText: "Assign To")),
              const SizedBox(height: 15),
              Row(children: [Expanded(child: TextFormField(controller: budgetC, decoration: const InputDecoration(labelText: "Budget (\$)"))), const SizedBox(width: 15), Expanded(child: DropdownButtonFormField(value: selectedPriority, items: ['High', 'Medium', 'Low'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => selectedPriority = v!))]),
              const SizedBox(height: 15),
              TextFormField(controller: resourcesC, decoration: const InputDecoration(labelText: "Resources (Links)"), maxLines: 2),
              const SizedBox(height: 15),
              TextFormField(controller: dateC, decoration: const InputDecoration(labelText: "Deadline", suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () async { DateTime? d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)); if(d!=null) dateC.text = d.toString().split(' ')[0]; }),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: submit, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white), child: const Text("CREATE PROJECT"))),
            ],
          ),
        ),
      ),
    );
  }
}