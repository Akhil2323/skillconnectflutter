// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'home.dart';
//
// class FeedbackPage extends StatefulWidget {
//   const FeedbackPage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<FeedbackPage> createState() => _FeedbackPageState();
// }
//
// class _FeedbackPageState extends State<FeedbackPage> {
//   List<Map<String, dynamic>> feedbackList = [];
//   List<Map<String, dynamic>> jobs = [];
//   List<Map<String, dynamic>> sessions = [];
//
//   TextEditingController feedbackController = TextEditingController();
//   String? selectedType; // 'job' or 'session'
//   String? selectedJobId;
//   String? selectedSessionId;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchJobsAndSessions();
//     fetchFeedback();
//   }
//
//   // Fetch jobs and sessions from Django
//   Future<void> fetchJobsAndSessions() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String baseUrl = sh.getString('url') ?? '';
//
//     try {
//       // Jobs
//       var jobResp = await http.get(Uri.parse('$baseUrl/user_jobs/'));
//       if (jobResp.statusCode == 200) {
//         var jobsData = jsonDecode(jobResp.body);
//         if (jobsData['status'] == 'ok') {
//           jobs = List<Map<String, dynamic>>.from(jobsData['data']);
//         }
//       }
//
//       // Sessions
//       var sessionResp = await http.get(Uri.parse('$baseUrl/user_sessions/'));
//       if (sessionResp.statusCode == 200) {
//         var sessionsData = jsonDecode(sessionResp.body);
//         if (sessionsData['status'] == 'ok') {
//           sessions = List<Map<String, dynamic>>.from(sessionsData['data']);
//         }
//       }
//
//       setState(() {});
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Failed to load jobs or sessions: $e");
//     }
//   }
//
//   // Fetch feedbacks from Django
//   Future<void> fetchFeedback() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String baseUrl = sh.getString('url') ?? '';
//     String lid = sh.getString('lid') ?? '';
//
//     try {
//       var response = await http.post(
//         Uri.parse('$baseUrl/user_view_feedback/'),
//         body: {'lid': lid},
//       );
//       var jsondata = json.decode(response.body);
//
//       if (jsondata['status'] == 'ok') {
//         setState(() {
//           feedbackList = List<Map<String, dynamic>>.from(jsondata['data']);
//         });
//       } else {
//         Fluttertoast.showToast(msg: 'No feedbacks found');
//         setState(() {
//           feedbackList = [];
//         });
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error fetching feedback: $e");
//     }
//   }
//
//   // Send feedback to Django
//   void _sendFeedback() async {
//     String feedbackText = feedbackController.text.trim();
//     if (feedbackText.isEmpty) {
//       Fluttertoast.showToast(msg: "Please enter your feedback");
//       return;
//     }
//     if (selectedType == null) {
//       Fluttertoast.showToast(msg: "Please select feedback type");
//       return;
//     }
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? baseUrl = sh.getString('url');
//     String? lid = sh.getString('lid');
//
//     if (baseUrl == null || lid == null) {
//       Fluttertoast.showToast(msg: "URL or user ID not found");
//       return;
//     }
//
//     var body = {
//       'lid': lid,
//       'feedback_type': selectedType!,
//       'feedback_text': feedbackText,
//     };
//
//     if (selectedType == 'job' && selectedJobId != null) {
//       body['job_id'] = selectedJobId!;
//     } else if (selectedType == 'session' && selectedSessionId != null) {
//       body['session_id'] = selectedSessionId!;
//     }
//
//     try {
//       var response = await http.post(Uri.parse('$baseUrl/user_send_feedback/'), body: body);
//       if (response.statusCode == 200) {
//         var jsonData = jsonDecode(response.body);
//         if (jsonData['status'] == 'ok') {
//           Fluttertoast.showToast(msg: 'Feedback submitted successfully');
//           feedbackController.clear();
//           setState(() {
//             selectedType = null;
//             selectedJobId = null;
//             selectedSessionId = null;
//           });
//           await fetchFeedback();
//         } else {
//           Fluttertoast.showToast(msg: jsonData['message'] ?? 'Failed to send feedback');
//         }
//       } else {
//         Fluttertoast.showToast(msg: 'Network Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'Error sending feedback: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: BackButton(onPressed: () {
//           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeNewPage(title: '')));
//         }),
//         title: Text("Feedback"),
//         backgroundColor: const Color.fromARGB(255, 18, 82, 98),
//       ),
//       body: Column(
//         children: [
//           // Feedback List
//           Expanded(
//             child: feedbackList.isEmpty
//                 ? const Center(child: Text("No feedbacks to show"))
//                 : ListView.builder(
//               itemCount: feedbackList.length,
//               itemBuilder: (context, index) {
//                 var f = feedbackList[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '${f['feedback_type'].toString().toUpperCase()}: ${f['feedback_text']}',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                         ),
//                         if (f['job'] != null)
//                           Text('Job: ${f['job']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                         if (f['session'] != null)
//                           Text('Session: ${f['session']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                         Text('Date: ${f['created_date']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Feedback input & send button
//           Container(
//             color: Colors.black,
//             padding: const EdgeInsets.all(12),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Feedback Type
//                   DropdownButtonFormField<String>(
//                     value: selectedType,
//                     decoration: const InputDecoration(
//                       labelText: "Feedback Type",
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     items: const [
//                       DropdownMenuItem(value: 'job', child: Text('Job')),
//                       DropdownMenuItem(value: 'session', child: Text('Session')),
//                     ],
//                     onChanged: (val) {
//                       setState(() {
//                         selectedType = val;
//                         selectedJobId = null;
//                         selectedSessionId = null;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 8),
//
//                   // Job Dropdown
//                   if (selectedType == 'job')
//                     DropdownButtonFormField<String>(
//                       value: selectedJobId,
//                       decoration: const InputDecoration(
//                         labelText: "Select Job",
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                       items: jobs
//                           .map((j) => DropdownMenuItem(
//                         value: j['id'].toString(),
//                         child: Text(j['title']),
//                       ))
//                           .toList(),
//                       onChanged: (val) {
//                         setState(() => selectedJobId = val);
//                       },
//                     ),
//
//                   // Session Dropdown
//                   if (selectedType == 'session')
//                     DropdownButtonFormField<String>(
//                       value: selectedSessionId,
//                       decoration: const InputDecoration(
//                         labelText: "Select Session",
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                       items: sessions
//                           .map((s) => DropdownMenuItem(
//                         value: s['id'].toString(),
//                         child: Text(s['title']),
//                       ))
//                           .toList(),
//                       onChanged: (val) {
//                         setState(() => selectedSessionId = val);
//                       },
//                     ),
//
//                   const SizedBox(height: 8),
//
//                   // Feedback Text & Send
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: feedbackController,
//                           maxLines: 3,
//                           decoration: const InputDecoration(
//                             hintText: "Write your feedback here...",
//                             border: OutlineInputBorder(),
//                             fillColor: Colors.white,
//                             filled: true,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton(onPressed: _sendFeedback, child: const Text("Send")),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key, required this.title});
  final String title;

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  List<Map<String, dynamic>> feedbackList = [];
  List<Map<String, dynamic>> jobs = [];
  List<Map<String, dynamic>> sessions = [];

  bool _isLoading = true;
  bool _isSending = false;

  TextEditingController feedbackController = TextEditingController();
  String? selectedType;
  String? selectedJobId;
  String? selectedSessionId;

  @override
  void initState() {
    super.initState();
    fetchJobsAndSessions();
    fetchFeedback();
  }

  Future<void> fetchJobsAndSessions() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String baseUrl = sh.getString('url') ?? '';

    try {
      var jobResp = await http.get(Uri.parse('$baseUrl/user_jobs/'));
      if (jobResp.statusCode == 200) {
        var jobsData = jsonDecode(jobResp.body);
        if (jobsData['status'] == 'ok') {
          jobs = List<Map<String, dynamic>>.from(jobsData['data']);
        }
      }

      var sessionResp = await http.get(Uri.parse('$baseUrl/user_sessions/'));
      if (sessionResp.statusCode == 200) {
        var sessionsData = jsonDecode(sessionResp.body);
        if (sessionsData['status'] == 'ok') {
          sessions = List<Map<String, dynamic>>.from(sessionsData['data']);
        }
      }

      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load options: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> fetchFeedback() async {
    setState(() => _isLoading = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String baseUrl = sh.getString('url') ?? '';
    String lid = sh.getString('lid') ?? '';

    try {
      var response = await http.post(
        Uri.parse('$baseUrl/user_view_feedback/'),
        body: {'lid': lid},
      );
      var jsondata = json.decode(response.body);

      if (jsondata['status'] == 'ok') {
        setState(() {
          feedbackList = List<Map<String, dynamic>>.from(jsondata['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          feedbackList = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: "Error fetching feedback: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  void _sendFeedback() async {
    String feedbackText = feedbackController.text.trim();
    if (feedbackText.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your feedback",
        backgroundColor: Colors.orange,
      );
      return;
    }
    if (selectedType == null) {
      Fluttertoast.showToast(
        msg: "Please select feedback type",
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() => _isSending = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? baseUrl = sh.getString('url');
    String? lid = sh.getString('lid');

    if (baseUrl == null || lid == null) {
      setState(() => _isSending = false);
      Fluttertoast.showToast(
        msg: "Configuration error",
        backgroundColor: Colors.red,
      );
      return;
    }

    var body = {
      'lid': lid,
      'feedback_type': selectedType!,
      'feedback_text': feedbackText,
    };

    if (selectedType == 'job' && selectedJobId != null) {
      body['job_id'] = selectedJobId!;
    } else if (selectedType == 'session' && selectedSessionId != null) {
      body['session_id'] = selectedSessionId!;
    }

    try {
      var response = await http.post(
        Uri.parse('$baseUrl/user_send_feedback/'),
        body: body,
      );

      setState(() => _isSending = false);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'ok') {
          Fluttertoast.showToast(
            msg: 'Feedback submitted successfully',
            backgroundColor: Colors.green,
          );
          feedbackController.clear();
          setState(() {
            selectedType = null;
            selectedJobId = null;
            selectedSessionId = null;
          });
          await fetchFeedback();
        } else {
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? 'Failed to send feedback',
            backgroundColor: Colors.red,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Network Error: ${response.statusCode}',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
      );
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
        title: const Text(
          'Feedback',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.rate_review_rounded,
                        color: Color(0xFF14b8a6), size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Your Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d3748),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Help us improve by sharing your thoughts',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Feedback List
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF14b8a6),
              ),
            )
                : feedbackList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feedback_outlined,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "No Feedback Yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your submitted feedback will appear here",
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
              onRefresh: fetchFeedback,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: feedbackList.length,
                itemBuilder: (context, index) {
                  var f = feedbackList[index];
                  String type = f['feedback_type'].toString();
                  IconData typeIcon = type == 'job'
                      ? Icons.work_rounded
                      : Icons.school_rounded;
                  Color typeColor = type == 'job'
                      ? const Color(0xFF14b8a6)
                      : const Color(0xFF3b82f6);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: typeColor.withOpacity(0.2),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Icon(typeIcon,
                                    color: typeColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: typeColor,
                                      ),
                                    ),
                                    if (f['job'] != null)
                                      Text(
                                        'Job: ${f['job']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    if (f['session'] != null)
                                      Text(
                                        'Session: ${f['session']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                f['created_date'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            f['feedback_text'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF2d3748),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Feedback Input Section
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.add_comment_rounded,
                            color: Color(0xFF14b8a6), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Submit New Feedback',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2d3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Type Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: "Feedback Type",
                        prefixIcon: const Icon(Icons.category_rounded,
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
                      items: const [
                        DropdownMenuItem(
                          value: 'job',
                          child: Text('Job Feedback'),
                        ),
                        DropdownMenuItem(
                          value: 'session',
                          child: Text('Session Feedback'),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedType = val;
                          selectedJobId = null;
                          selectedSessionId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Job Dropdown
                    if (selectedType == 'job')
                      DropdownButtonFormField<String>(
                        value: selectedJobId,
                        decoration: InputDecoration(
                          labelText: "Select Job",
                          prefixIcon: const Icon(Icons.work_outline_rounded,
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
                        items: jobs
                            .map((j) => DropdownMenuItem(
                          value: j['id'].toString(),
                          child: Text(j['title']),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() => selectedJobId = val);
                        },
                      ),

                    // Session Dropdown
                    if (selectedType == 'session')
                      DropdownButtonFormField<String>(
                        value: selectedSessionId,
                        decoration: InputDecoration(
                          labelText: "Select Session",
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
                        items: sessions
                            .map((s) => DropdownMenuItem(
                          value: s['id'].toString(),
                          child: Text(s['title']),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() => selectedSessionId = val);
                        },
                      ),

                    const SizedBox(height: 12),

                    // Feedback Text & Send Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: feedbackController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Share your thoughts...",
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
                        SizedBox(
                          height: 80,
                          child: ElevatedButton(
                            onPressed: _isSending ? null : _sendFeedback,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14b8a6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSending
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  'Send',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }
}
