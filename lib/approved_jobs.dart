
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ApprovedJobsPage extends StatefulWidget {
  const ApprovedJobsPage({super.key, required this.title});
  final String title;

  @override
  State<ApprovedJobsPage> createState() => _ApprovedJobsPageState();
}

class _ApprovedJobsPageState extends State<ApprovedJobsPage> {
  List<Map<String, dynamic>> approvedJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApprovedJobs();
  }

  Future<void> fetchApprovedJobs() async {
    setState(() => _isLoading = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String baseUrl = sh.getString('url') ?? '';
    String lid = sh.getString('lid') ?? '';

    try {
      var response = await http.post(
        Uri.parse('$baseUrl/job_seeker_view_approved_jobs/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            approvedJobs = List<Map<String, dynamic>>.from(data['approved_jobs']);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          Fluttertoast.showToast(
            msg: "No approved jobs found",
            backgroundColor: Colors.orange,
          );
        }
      } else {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(
          msg: "Server error: ${response.statusCode}",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Fluttertoast.showToast(msg: "Could not make call");
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Fluttertoast.showToast(msg: "Could not send email");
    }
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
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF14b8a6),
        ),
      )
          : approvedJobs.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_rounded,
                size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No Approved Jobs Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2d3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your approved job applications will appear here",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : RefreshIndicator(
        color: const Color(0xFF14b8a6),
        onRefresh: fetchApprovedJobs,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: approvedJobs.length,
          itemBuilder: (context, index) {
            final job = approvedJobs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Header with Success Badge
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10b981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified_rounded,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'APPROVED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          job['job_title'] ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Job Details Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Job Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2d3748),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                          '₹ ${job['salary']}',
                          const Color(0xFF10b981),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.school_rounded,
                          'Eligibility',
                          job['eligibility'] ?? '',
                          const Color(0xFF3b82f6),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.calendar_today_rounded,
                          'Deadline',
                          job['deadline'] ?? '',
                          const Color(0xFFf59e0b),
                        ),

                        const SizedBox(height: 24),

                        // Company Contact Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF0FDFA), Color(0xFFccfbf1)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.business_rounded,
                                      color: Color(0xFF14b8a6)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Company Contact',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2d3748),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildContactRow(
                                Icons.business_rounded,
                                'Company',
                                job['provider_name'] ?? '',
                              ),

                              const SizedBox(height: 12),
                              _buildContactRow(
                                Icons.location_city_rounded,
                                'Email',
                                job['provider_email'] ?? '',
                              ),

                              const SizedBox(height: 12),
                              _buildContactRow(
                                Icons.location_city_rounded,
                                'Phone',
                                job['provider_phone'] ?? '',
                              ),

                              const SizedBox(height: 12),
                              _buildContactRow(
                                Icons.location_city_rounded,
                                'Address',
                                job['provider_location'] ?? '',
                              ),
                            ],
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

  Widget _buildContactRow(IconData icon, String label, String value,
      {bool isClickable = false}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF14b8a6), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isClickable
                            ? const Color(0xFF14b8a6)
                            : const Color(0xFF2d3748),
                        decoration: isClickable
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  if (isClickable)
                    const Icon(Icons.open_in_new,
                        size: 16, color: Color(0xFF14b8a6)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
