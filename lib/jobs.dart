
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ViewJobsPage extends StatefulWidget {
  const ViewJobsPage({super.key, required this.title});
  final String title;

  @override
  State<ViewJobsPage> createState() => _ViewJobsPageState();
}

class _ViewJobsPageState extends State<ViewJobsPage> {
  List<Map<String, dynamic>> jobs = [];
  TextEditingController locationController = TextEditingController();
  TextEditingController salaryController = TextEditingController();
  Map<int, String> appliedJobsStatus = {};
  Timer? _refreshTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    userViewJobs();
    locationController.addListener(_onFilterChanged);
    salaryController.addListener(_onFilterChanged);

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      userViewJobs();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    locationController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    Future.delayed(const Duration(milliseconds: 400), () {
      userViewJobs();
    });
  }

  Future<void> userViewJobs() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url')!;
      String lid = sh.getString('lid') ?? '';

      String location = locationController.text.trim();
      String salary = salaryController.text.trim();

      String url = '$baseUrl/job_seeker_view_jobs/?lid=$lid';
      if (location.isNotEmpty) url += '&location=$location';
      if (salary.isNotEmpty) url += '&salary=$salary';

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'ok') {
          setState(() {
            jobs = List<Map<String, dynamic>>.from(jsondata['jobs']);
            appliedJobsStatus.clear();
            for (var job in jobs) {
              if (job['application_status'] != null &&
                  job['application_status'] != 'Not Applied') {
                appliedJobsStatus[job['id']] = job['application_status'];
              }
            }
            _isLoading = false;
          });
        } else {
          setState(() {
            jobs = [];
            appliedJobsStatus.clear();
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(msg: "Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  Future<void> showApplyDialog(int jobId) async {
    final ImagePicker picker = ImagePicker();
    XFile? selectedImage;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.upload_file_rounded, color: Color(0xFF14b8a6)),
              SizedBox(width: 12),
              Text(
                "Upload Resume",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.description_rounded,
                        size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Select your resume to apply',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    selectedImage = image;
                    Fluttertoast.showToast(
                      msg: "Resume selected!",
                      backgroundColor: Colors.green,
                    );
                  }
                },
                icon: const Icon(Icons.attach_file_rounded),
                label: const Text("Choose Resume"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14b8a6),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedImage == null) {
                  Fluttertoast.showToast(
                    msg: "Please upload your resume",
                    backgroundColor: Colors.red,
                  );
                  return;
                }
                Navigator.pop(context);
                await applyForJob(jobId, selectedImage!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14b8a6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Submit Application"),
            ),
          ],
        );
      },
    );
  }

  Future<void> applyForJob(int jobId, XFile image) async {
    File file = File(image.path);
    List<int> fileBytes = await file.readAsBytes();
    String base64File = base64Encode(fileBytes);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String baseUrl = sh.getString('url')!;
    String lid = sh.getString('lid') ?? '';

    var response = await http.post(
      Uri.parse('$baseUrl/job_seeker_apply_job_request/'),
      body: {
        'lid': lid,
        'job_id': jobId.toString(),
        'image_resume': base64File,
      },
    );

    var data = json.decode(response.body);
    Fluttertoast.showToast(
      msg: data['message'],
      backgroundColor: Colors.green,
    );

    setState(() {
      appliedJobsStatus[jobId] = 'Pending';
    });
    userViewJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF14b8a6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.filter_list_rounded, color: Color(0xFF14b8a6)),
                    SizedBox(width: 8),
                    Text(
                      'Filter Jobs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d3748),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: "Location",
                          prefixIcon: const Icon(Icons.location_on_outlined,
                              color: Color(0xFF14b8a6)),
                          filled: true,
                          fillColor: const Color(0xFFF0FDFA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF14b8a6), width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: salaryController,
                        decoration: InputDecoration(
                          labelText: "Min Salary",
                          prefixIcon: const Icon(Icons.currency_rupee,
                              color: Color(0xFF14b8a6)),
                          filled: true,
                          fillColor: const Color(0xFFF0FDFA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF14b8a6), width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Jobs List
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF14b8a6),
              ),
            )
                : jobs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off_rounded,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "No jobs found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Try adjusting your filters",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              color: const Color(0xFF14b8a6),
              onRefresh: userViewJobs,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  String status =
                      appliedJobsStatus[job['id']] ?? "Apply";
                  bool alreadyApplied = status != "Apply";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF14b8a6),
                                Color(0xFF0d9488)
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.business_rounded,
                                      color: Colors.white70,
                                      size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    job['provider_name'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Job Details
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                Icons.location_on_rounded,
                                'Location',
                                job['location'] ?? '',
                                const Color(0xFFef4444),
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.currency_rupee_rounded,
                                'Salary',
                                ' ${job['salary']}',
                                const Color(0xFF10b981),
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.school_rounded,
                                'Eligibility',
                                job['eligibility'] ??
                                    'Not specified',
                                const Color(0xFF3b82f6),
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.calendar_today_rounded,
                                'Deadline',
                                job['deadline'] ?? 'Not specified',
                                const Color(0xFFf59e0b),
                              ),
                              const SizedBox(height: 20),

                              // Apply Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: alreadyApplied
                                      ? null
                                      : () =>
                                      showApplyDialog(job['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    _getStatusColor(status),
                                    disabledBackgroundColor:
                                    _getStatusColor(status),
                                    padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(_getStatusIcon(status),
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        _getStatusText(status),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2d3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF3b82f6);
      case 'approved':
        return const Color(0xFF10b981);
      case 'rejected':
        return const Color(0xFFef4444);
      default:
        return const Color(0xFF14b8a6);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.send_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Application Pending';
      case 'approved':
        return 'Application Approved';
      case 'rejected':
        return 'Application Rejected';
      default:
        return 'Apply Now';
    }
  }
}
