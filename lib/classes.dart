// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class ViewEducationSessionsPage extends StatefulWidget {
//   const ViewEducationSessionsPage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<ViewEducationSessionsPage> createState() => _ViewEducationSessionsPageState();
// }
//
// class _ViewEducationSessionsPageState extends State<ViewEducationSessionsPage> {
//   List<Map<String, dynamic>> sessions = [];
//   TextEditingController subjectController = TextEditingController();
//   TextEditingController dateController = TextEditingController();
//   Timer? _refreshTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchEducationSessions();
//     subjectController.addListener(_onFilterChanged);
//     dateController.addListener(_onFilterChanged);
//
//     // Auto-refresh every 10 seconds
//     _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
//       fetchEducationSessions();
//     });
//   }
//
//   @override
//   void dispose() {
//     _refreshTimer?.cancel();
//     subjectController.dispose();
//     dateController.dispose();
//     super.dispose();
//   }
//
//   void _onFilterChanged() {
//     Future.delayed(const Duration(milliseconds: 400), () {
//       fetchEducationSessions();
//     });
//   }
//
//   Future<void> fetchEducationSessions() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String baseUrl = sh.getString('url') ?? '';
//       String lid = sh.getString('lid') ?? '';
//
//       String subject = subjectController.text.trim();
//       String date = dateController.text.trim();
//
//       String url = '$baseUrl/job_seeker_view_education_sessions/?lid=$lid';
//       if (subject.isNotEmpty) url += '&subject=$subject';
//       if (date.isNotEmpty) url += '&date=$date';
//
//       var response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         if (data['status'] == 'ok') {
//           setState(() {
//             sessions = List<Map<String, dynamic>>.from(data['sessions']);
//           });
//         } else {
//           setState(() {
//             sessions = [];
//           });
//         }
//       } else {
//         Fluttertoast.showToast(msg: "Server error: ${response.statusCode}");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: ${e.toString()}");
//     }
//   }
//
//   Widget buildLabelValue(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ),
//           Expanded(
//             child: Text(value, style: const TextStyle(color: Colors.white), maxLines: 2),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _launchMeetLink(String url) async {
//     if (url.isEmpty) {
//       Fluttertoast.showToast(msg: "Meet link not available");
//       return;
//     }
//
//     final Uri uri = Uri.parse(url);
//
//     try {
//       if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//         Fluttertoast.showToast(msg: "Could not open the link");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error opening link: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(widget.title),
//         backgroundColor: const Color.fromARGB(255, 18, 82, 98),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: subjectController,
//                     decoration: const InputDecoration(
//                       labelText: "Subject",
//                       prefixIcon: Icon(Icons.book),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: TextField(
//                     controller: dateController,
//                     decoration: const InputDecoration(
//                       labelText: "Date",
//                       prefixIcon: Icon(Icons.date_range),
//                       border: OutlineInputBorder(),
//                     ),
//                     readOnly: true,
//                     onTap: () async {
//                       DateTime? pickedDate = await showDatePicker(
//                         context: context,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2100),
//                       );
//                       if (pickedDate != null) {
//                         dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(),
//           Expanded(
//             child: sessions.isEmpty
//                 ? const Center(
//               child: Text(
//                 "No sessions found",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//             )
//                 : ListView.builder(
//               itemCount: sessions.length,
//               itemBuilder: (context, index) {
//                 final session = sessions[index];
//                 return Card(
//                   color: const Color.fromARGB(255, 18, 82, 98),
//                   elevation: 5,
//                   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(15),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(session['title'] ?? '',
//                             style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.yellow)),
//                         const SizedBox(height: 8),
//                         buildLabelValue("Educator", session['educator_name'] ?? ''),
//                         buildLabelValue("Specialization", session['specialization'] ?? ''),
//                         buildLabelValue("Date", session['session_date'] ?? ''),
//                         buildLabelValue("Start Time", session['start_time'] ?? ''),
//                         buildLabelValue("End Time", session['end_time'] ?? ''),
//                         const SizedBox(height: 10),
//                         session['status'] == 'Scheduled'
//                             ? ElevatedButton(
//                           onPressed: () => _launchMeetLink(session['meet_link'] ?? ''),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                           ),
//                           child: const Text("Join Class"),
//                         )
//                             : ElevatedButton(
//                           onPressed: null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey,
//                           ),
//                           child: Text(session['status'] ?? 'Unavailable'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewEducationSessionsPage extends StatefulWidget {
  const ViewEducationSessionsPage({super.key, required this.title});
  final String title;

  @override
  State<ViewEducationSessionsPage> createState() => _ViewEducationSessionsPageState();
}

class _ViewEducationSessionsPageState extends State<ViewEducationSessionsPage> {
  List<Map<String, dynamic>> sessions = [];
  TextEditingController subjectController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  Timer? _refreshTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEducationSessions();
    subjectController.addListener(_onFilterChanged);
    dateController.addListener(_onFilterChanged);

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchEducationSessions();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    subjectController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    Future.delayed(const Duration(milliseconds: 400), () {
      fetchEducationSessions();
    });
  }

  Future<void> fetchEducationSessions() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url') ?? '';
      String lid = sh.getString('lid') ?? '';

      String subject = subjectController.text.trim();
      String date = dateController.text.trim();

      String url = '$baseUrl/job_seeker_view_education_sessions/?lid=$lid';
      if (subject.isNotEmpty) url += '&subject=$subject';
      if (date.isNotEmpty) url += '&date=$date';

      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            sessions = List<Map<String, dynamic>>.from(data['sessions']);
            _isLoading = false;
          });
        } else {
          setState(() {
            sessions = [];
            _isLoading = false;
          });
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

  Future<void> _launchMeetLink(String url) async {
    if (url.isEmpty) {
      Fluttertoast.showToast(
        msg: "Meet link not available",
        backgroundColor: Colors.orange,
      );
      return;
    }

    final Uri uri = Uri.parse(url);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Fluttertoast.showToast(
          msg: "Could not open the link",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error opening link: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF10b981);
      case 'completed':
        return const Color(0xFF3b82f6);
      case 'cancelled':
        return const Color(0xFFef4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Icons.videocam_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
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
                      'Filter Classes',
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
                        controller: subjectController,
                        decoration: InputDecoration(
                          labelText: "Subject",
                          prefixIcon: const Icon(Icons.school_rounded,
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
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: "Date",
                          prefixIcon: const Icon(Icons.calendar_today_rounded,
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
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF14b8a6),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            dateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sessions List
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF14b8a6),
              ),
            )
                : sessions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "No classes found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Check back later for new sessions",
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
              onRefresh: fetchEducationSessions,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  String status = session['status'] ?? 'Unknown';
                  bool isScheduled = status.toLowerCase() == 'scheduled';

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
                        // Session Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getStatusColor(status),
                                _getStatusColor(status).withOpacity(0.8)
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      session['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(_getStatusIcon(status),
                                            color: Colors.white, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.person_rounded,
                                      color: Colors.white70, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    session['educator_name'] ?? '',
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

                        // Session Details
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                Icons.stars_rounded,
                                'Specialization',
                                session['specialization'] ?? '',
                                const Color(0xFF8b5cf6),
                              ),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                Icons.calendar_today_rounded,
                                'Date',
                                session['session_date'] ?? '',
                                const Color(0xFF3b82f6),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDetailRow(
                                      Icons.access_time_rounded,
                                      'Start Time',
                                      session['start_time'] ?? '',
                                      const Color(0xFF10b981),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDetailRow(
                                      Icons.timer_off_rounded,
                                      'End Time',
                                      session['end_time'] ?? '',
                                      const Color(0xFFef4444),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Join Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: isScheduled
                                      ? () => _launchMeetLink(
                                      session['meet_link'] ?? '')
                                      : null,
                                  icon: Icon(
                                    isScheduled
                                        ? Icons.videocam_rounded
                                        : _getStatusIcon(status),
                                    size: 22,
                                  ),
                                  label: Text(
                                    isScheduled
                                        ? 'Join Class'
                                        : status,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isScheduled
                                        ? const Color(0xFF10b981)
                                        : Colors.grey[400],
                                    disabledBackgroundColor:
                                    Colors.grey[400],
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
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
}
