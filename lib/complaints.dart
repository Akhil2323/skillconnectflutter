// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'home.dart';
//
//
// void main() {
//   runApp(const ComplaintScreen());
// }
//
// class ComplaintScreen extends StatelessWidget {
//   const ComplaintScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Complaints',
//       theme: ThemeData(
//         colorScheme:
//         ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 18, 82, 98)),
//         useMaterial3: true,
//       ),
//       home: const ComplaintPage(title: 'My Complaints'),
//     );
//   }
// }
//
// class ComplaintPage extends StatefulWidget {
//   const ComplaintPage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<ComplaintPage> createState() => _ComplaintPageState();
// }
//
// class _ComplaintPageState extends State<ComplaintPage> {
//   List<String> id_ = [];
//   List<String> complaint_ = [];
//   List<String> date_ = [];
//   List<String> reply_ = [];
//
//
//   TextEditingController complaintController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     user_view_complaints();
//   }
//
//   Future<void> user_view_complaints() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String urls = sh.getString('url') ?? '';
//     String lid = sh.getString('lid') ?? '';
//
//     String url = '$urls/job_seeker_view_complaints/';
//
//     var response = await http.post(Uri.parse(url), body: {'lid': lid});
//     var jsondata = json.decode(response.body);
//
//     if (jsondata['status'] == 'ok') {
//       List<String> id = [];
//       List<String> complaint = [];
//       List<String> date = [];
//       List<String> reply = [];
//
//
//       var arr = jsondata["data"];
//       for (var comp in arr) {
//         id.add(comp['id'].toString());
//         complaint.add(comp['complaint'].toString());
//         date.add(comp['date'].toString());
//         reply.add(comp['reply'].toString());
//
//       }
//
//       setState(() {
//         id_ = id;
//         complaint_ = complaint;
//         date_ = date;
//         reply_ = reply;
//
//       });
//     } else {
//       Fluttertoast.showToast(msg: 'No complaints found');
//       setState(() {
//         id_ = [];
//         complaint_ = [];
//         date_ = [];
//         reply_ = [];
//
//       });
//     }
//   }
//
//
//
//   void _sendData() async {
//     String complaintText = complaintController.text.trim();
//     if (complaintText.isEmpty) {
//       Fluttertoast.showToast(msg: "Please enter your complaint");
//       return;
//     }
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? url = sh.getString('url');
//     String? lid = sh.getString('lid');
//
//     if (url == null) {
//       Fluttertoast.showToast(msg: "URL not found in SharedPreferences");
//       return;
//     }
//
//     Uri apiUrl = Uri.parse('$url/job_seeker_send_complaint/');
//
//     var response = await http.post(apiUrl, body: {
//       'complaint': complaintText,
//       'lid': lid,
//     });
//
//     if (response.statusCode == 200) {
//       var jsonData = jsonDecode(response.body);
//       if (jsonData['status'] == 'ok') {
//         Fluttertoast.showToast(msg: 'Complaint sent successfully');
//         complaintController.clear();
//         await user_view_complaints();
//       } else {
//         Fluttertoast.showToast(msg: jsonData['message'] ?? 'Failed to send complaint');
//       }
//     } else {
//       Fluttertoast.showToast(msg: 'Network Error: ${response.statusCode}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => true,
//       child: Scaffold(
//         appBar: AppBar(
//           leading: BackButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           title: Text(widget.title),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: id_.isEmpty
//                   ? const Center(child: Text("No complaints to show"))
//                   : ListView.builder(
//                 itemCount: id_.length,
//                 itemBuilder: (context, index) {
//                   return Card(
//                     elevation: 5,
//                     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             complaint_[index],
//                             style: const TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.w500),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             'Date: ${date_[index]}',
//                             style: const TextStyle(
//                                 fontSize: 12, color: Colors.grey),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             'Reply: ${reply_[index].isEmpty ? "No reply yet" : reply_[index]}',
//                             style: const TextStyle(
//                                 fontSize: 14, fontStyle: FontStyle.italic),
//                           ),
//
//                           const SizedBox(height: 12),
//
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             // Fixed bottom complaint input & send button
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               color: Colors.grey.shade200,
//               child: SafeArea(
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: complaintController,
//                         maxLines: 3,
//                         decoration: const InputDecoration(
//                           hintText: "Write your complaint here...",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: _sendData,
//                       child: const Text("Send"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ComplaintScreen());
}

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complaints',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14b8a6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ComplaintPage(title: 'My Complaints'),
    );
  }
}

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key, required this.title});
  final String title;

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  List<String> id_ = [];
  List<String> complaint_ = [];
  List<String> date_ = [];
  List<String> reply_ = [];

  bool _isLoading = true;
  bool _isSending = false;

  TextEditingController complaintController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user_view_complaints();
  }

  Future<void> user_view_complaints() async {
    setState(() => _isLoading = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String urls = sh.getString('url') ?? '';
    String lid = sh.getString('lid') ?? '';

    String url = '$urls/job_seeker_view_complaints/';

    try {
      var response = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsondata = json.decode(response.body);

      if (jsondata['status'] == 'ok') {
        List<String> id = [];
        List<String> complaint = [];
        List<String> date = [];
        List<String> reply = [];

        var arr = jsondata["data"];
        for (var comp in arr) {
          id.add(comp['id'].toString());
          complaint.add(comp['complaint'].toString());
          date.add(comp['date'].toString());
          reply.add(comp['reply'].toString());
        }

        setState(() {
          id_ = id;
          complaint_ = complaint;
          date_ = date;
          reply_ = reply;
          _isLoading = false;
        });
      } else {
        setState(() {
          id_ = [];
          complaint_ = [];
          date_ = [];
          reply_ = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  void _sendData() async {
    String complaintText = complaintController.text.trim();
    if (complaintText.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your complaint",
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() => _isSending = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');

    if (url == null) {
      setState(() => _isSending = false);
      Fluttertoast.showToast(
        msg: "URL not found",
        backgroundColor: Colors.red,
      );
      return;
    }

    Uri apiUrl = Uri.parse('$url/job_seeker_send_complaint/');

    try {
      var response = await http.post(apiUrl, body: {
        'complaint': complaintText,
        'lid': lid,
      });

      setState(() => _isSending = false);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'ok') {
          Fluttertoast.showToast(
            msg: 'Complaint sent successfully',
            backgroundColor: Colors.green,
          );
          complaintController.clear();
          await user_view_complaints();
        } else {
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? 'Failed to send complaint',
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
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
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
                      Icon(Icons.support_agent_rounded,
                          color: Color(0xFF14b8a6), size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Support Center',
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
                    'Submit your complaints and track responses',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Complaints List
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF14b8a6),
                ),
              )
                  : id_.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text(
                      "No Complaints Yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your submitted complaints will appear here",
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
                onRefresh: user_view_complaints,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: id_.length,
                  itemBuilder: (context, index) {
                    bool hasReply = reply_[index].isNotEmpty &&
                        reply_[index] != 'null';

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
                              color: const Color(0xFFF0FDFA),
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
                                    color: const Color(0xFF14b8a6)
                                        .withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.report_problem_rounded,
                                    color: Color(0xFF14b8a6),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Complaint',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        date_[index],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2d3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: hasReply
                                        ? const Color(0xFF10b981)
                                        .withOpacity(0.1)
                                        : Colors.orange
                                        .withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    hasReply ? 'Replied' : 'Pending',
                                    style: TextStyle(
                                      color: hasReply
                                          ? const Color(0xFF10b981)
                                          : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Complaint Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  complaint_[index],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF2d3748),
                                    height: 1.5,
                                  ),
                                ),
                                if (hasReply) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10b981)
                                          .withOpacity(0.05),
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                        const Color(0xFF10b981)
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.reply_rounded,
                                              color:
                                              Color(0xFF10b981),
                                              size: 18,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Admin Reply',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.bold,
                                                color:
                                                Color(0xFF10b981),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          reply_[index],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF2d3748),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

            // Fixed bottom complaint input
            Container(
              padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_rounded,
                            color: Color(0xFF14b8a6), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Submit New Complaint',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2d3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: complaintController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Describe your issue here...",
                              filled: true,
                              fillColor: const Color(0xFFF0FDFA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: Colors.grey[300]!),
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
                            onPressed: _isSending ? null : _sendData,
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    complaintController.dispose();
    super.dispose();
  }
}
