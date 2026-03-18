//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:skill_connect_android/view_profile.dart';
//
// import 'approved_jobs.dart';
// import 'classes.dart';
// import 'complaints.dart';
// import 'feedback.dart';
// import 'jobs.dart';
// import 'login.dart';
// import 'main.dart';
//
// void main() {
//   runApp(const HomeNew());
// }
//
// class HomeNew extends StatelessWidget {
//   const HomeNew({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Home',
//       theme: ThemeData(
//
//         colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 18, 82, 98)),
//         useMaterial3: true,
//       ),
//       home: const HomeNewPage(title: 'Home'),
//     );
//   }
// }
//
// class HomeNewPage extends StatefulWidget {
//   const HomeNewPage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<HomeNewPage> createState() => _HomeNewPageState();
// }
//
// class _HomeNewPageState extends State<HomeNewPage> {
//
//
//   _HomeNewPageState() {
//     viewprofile();
//   }
//
//   String username_="";
//   String photo_="";
//
//   void viewprofile() async{
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//     String lid = sh.getString('lid').toString();
//
//     final urls = Uri.parse('$url/job_seeker_profile/');
//     try {
//       final response = await http.post(urls, body: {
//         'lid':lid
//
//       });
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status=='ok') {
//           String username=jsonDecode(response.body)['username'];
//           String photo=url+jsonDecode(response.body)['profile_photo'];
//
//           setState(() {
//             username_= username;
//             photo_= photo;
//           });
//
//
//
//
//
//         }else {
//           Fluttertoast.showToast(msg: 'Not Found');
//         }
//       }
//       else {
//         Fluttertoast.showToast(msg: 'Network Error');
//       }
//     }
//     catch (e){
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return WillPopScope(
//       onWillPop: () async{ return true; },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Color.fromARGB(255, 18, 82, 98),
//
//           title: Text(widget.title),
//         ),
//         // body:
//         // GridView.builder(
//         //     gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//         //       maxCrossAxisExtent: 210,
//         //       childAspectRatio: 10/10,
//         //       crossAxisSpacing: 10,
//         //       mainAxisSpacing: 10,
//         //
//         //     ),
//         //     padding: const EdgeInsets.all(8.0),
//         //
//         //     itemCount: uname_.length,
//         //     itemBuilder: (BuildContext ctx, index) {
//         //       return Container(
//         //           alignment: Alignment.center,
//         //           decoration: BoxDecoration(
//         //               color: Color.fromARGB(255, 18, 82, 98),
//         //               borderRadius: BorderRadius.circular(15)),
//         //           child:  Column(
//         //               children: [
//         //                 SizedBox(height: 5.0),
//         //                 InkWell(
//         //                   onTap: () async {
//         //                     final pref =await SharedPreferences.getInstance();
//         //                     pref.setString("did", id_[index]);
//         //                     // Navigator.push(
//         //                     //   context,
//         //                     //   MaterialPageRoute(builder: (context) => ViewSchedule()),);
//         //                   },
//         //                   child: CircleAvatar(
//         //                       radius: 50,backgroundImage: NetworkImage(photo_[index])),
//         //                 ),
//         //                 // SizedBox(height: 5.0),
//         //                 // CircleAvatar(radius: 50,backgroundImage: NetworkImage(photo_[index])),
//         //                 Column(
//         //                   children: [
//         //                     Padding(
//         //                       padding: EdgeInsets.all(1),
//         //                       child: Text(firstname_[index],style: TextStyle(color: Colors.white,fontSize: 18)),
//         //                     ),],
//         //                 ),
//         //
//         //                 Column(
//         //                   children: [
//         //                     Padding(
//         //                       padding: EdgeInsets.all(1),
//         //                       child: Text(lastname_[index],style: TextStyle(color: Colors.white)),
//         //                     ),
//         //                   ],
//         //                 ),
//         //               ]
//         //           )
//         //       );
//         //     }),
//
//
//         drawer: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               DrawerHeader(
//                 decoration: BoxDecoration(
//                   color: Color.fromARGB(255, 18, 82, 98),
//                 ),
//                 child:
//                 Column(children: [
//
//                   Text(
//                     'Skill Connect',
//                     style: TextStyle(fontSize: 20,color: Colors.white),
//
//                   ),
//                   CircleAvatar(radius: 29,backgroundImage: NetworkImage(photo_)),
//                   Text(username_,style: TextStyle(color: Colors.white)),
//
//
//                 ])
//                 ,
//               ),
//               ListTile(
//                 leading: Icon(Icons.home),
//                 title: const Text('Home'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => HomeNewPage(title: '',),));
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.person_pin),
//                 title: const Text(' View Profile '),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfilePage(title: '',),));
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.person_pin_outlined),
//                 title: const Text(' View Jobs '),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => ViewJobsPage(title: "Jobs",),));
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.person_pin_outlined),
//                 title: const Text(' Approved Jobs '),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => ApprovedJobsPage(title: "Approved Jobs",),));
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.book_outlined),
//                 title: const Text(' View Classes'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => ViewEducationSessionsPage(title: "Booking Details",),));
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.note_alt_rounded),
//                 title: const Text(' Complaints'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintPage(title: "Complaints",),));
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.note_alt_rounded),
//                 title: const Text(' Feedback '),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage(title: "Feedback",),));
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.logout, color: Colors.red),
//                 title: const Text('Log Out', style: TextStyle(color: Colors.red)),
//                 onTap: () async {
//                   SharedPreferences prefs = await SharedPreferences.getInstance();
//                   await prefs.clear();
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const MyLoginPage(title: ""),
//                     ),
//                   );
//                 },
//               ),
//
//
//
//
//             ],
//           ),
//         ),
//
//
//
//
//
//       ),
//     );
//   }
//
//
//
//
//
// }




import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/view_profile.dart';

import 'approved_jobs.dart';
import 'classes.dart';
import 'complaints.dart';
import 'feedback.dart';
import 'jobs.dart';
import 'login.dart';
import 'main.dart';

void main() {
  runApp(const HomeNew());
}

class HomeNew extends StatelessWidget {
  const HomeNew({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14b8a6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeNewPage(title: 'SkillConnect'),
    );
  }
}

class HomeNewPage extends StatefulWidget {
  const HomeNewPage({super.key, required this.title});
  final String title;

  @override
  State<HomeNewPage> createState() => _HomeNewPageState();
}

class _HomeNewPageState extends State<HomeNewPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _animationController;

  _HomeNewPageState() {
    viewprofile();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String username_ = "";
  String photo_ = "";

  void viewprofile() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/job_seeker_profile/');
    try {
      final response = await http.post(urls, body: {'lid': lid});
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String username = jsonDecode(response.body)['username'];
          String photo = url + jsonDecode(response.body)['profile_photo'];

          setState(() {
            username_ = username;
            photo_ = photo;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          Fluttertoast.showToast(msg: 'Not Found');
        }
      } else {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FDFA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF14b8a6),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  color: Color(0xFF14b8a6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'SkillConnect',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),

            ),
          ],
        ),
        drawer: _buildModernDrawer(),
        body: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF14b8a6),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            : RefreshIndicator(
          color: const Color(0xFF14b8a6),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            viewprofile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner WITHOUT Profile Picture
                FadeTransition(
                  opacity: _animationController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    )),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14b8a6), Color(0xFF0d9488)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF14b8a6).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '👋 Welcome Back!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            username_,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Find your dream job & enhance your skills',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick Actions Section
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Icon(Icons.flash_on_rounded, color: Color(0xFF14b8a6), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2d3748),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildQuickAction(
                        icon: Icons.work_outline_rounded,
                        label: 'Browse Jobs',
                        color: const Color(0xFF14b8a6),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14b8a6), Color(0xFF0d9488)],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewJobsPage(title: 'Jobs'),
                          ),
                        ),
                      ),
                      _buildQuickAction(
                        icon: Icons.verified_rounded,
                        label: 'Approved',
                        color: const Color(0xFF10b981),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10b981), Color(0xFF059669)],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApprovedJobsPage(title: 'Approved Jobs'),
                          ),
                        ),
                      ),
                      _buildQuickAction(
                        icon: Icons.school_rounded,
                        label: 'Classes',
                        color: const Color(0xFF3b82f6),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewEducationSessionsPage(title: 'Classes'),
                          ),
                        ),
                      ),
                      _buildQuickAction(
                        icon: Icons.account_circle_rounded,
                        label: 'Profile',
                        color: const Color(0xFF8b5cf6),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8b5cf6), Color(0xFF7c3aed)],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProfilePage(title: ''),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Features Section
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 28, 16, 12),
                  child: Row(
                    children: [
                      Icon(Icons.explore_rounded, color: Color(0xFF14b8a6), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Explore Features',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2d3748),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.business_center_rounded,
                  title: 'Job Opportunities',
                  description: 'Browse and apply for various job openings from top companies',
                  color: const Color(0xFF14b8a6),
                  imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=800',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewJobsPage(title: 'Jobs')),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.school_rounded,
                  title: 'Learning Sessions',
                  description: 'Join live classes with expert educators and enhance your skills',
                  color: const Color(0xFF3b82f6),
                  imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewEducationSessionsPage(title: 'Classes'),
                    ),
                  ),
                ),

                // Tips Section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFfef3c7), Color(0xFFfde68a)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf59e0b),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tips_and_updates_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pro Tip',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF78350f),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete your profile to get better job matches and increase your chances of getting hired!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.brown[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required Color color,
        required String imageUrl,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: color.withOpacity(0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            color: color,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                        ),
                      ),
                      child: Icon(icon, size: 80, color: color.withOpacity(0.5)),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2d3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Explore Now',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded, color: color, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF14b8a6),
              Color(0xFF0d9488),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF14b8a6),
                    Color(0xFF0d9488),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(photo_),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username_,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Job Seeker',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildDrawerItem(
              icon: Icons.home_rounded,
              title: 'Home',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.account_circle_rounded,
              title: 'My Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewProfilePage(title: '')),
                );
              },
            ),

            _buildSectionHeader('JOB PORTAL'),

            _buildDrawerItem(
              icon: Icons.work_rounded,
              title: 'Browse Jobs',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewJobsPage(title: 'Jobs')),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.verified_rounded,
              title: 'Approved Jobs',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApprovedJobsPage(title: 'Approved Jobs'),
                  ),
                );
              },
            ),

            _buildSectionHeader('LEARNING'),

            _buildDrawerItem(
              icon: Icons.school_rounded,
              title: 'Live Classes',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewEducationSessionsPage(title: 'Classes'),
                  ),
                );
              },
            ),

            _buildSectionHeader('SUPPORT'),

            _buildDrawerItem(
              icon: Icons.support_agent_rounded,
              title: 'Complaints',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintPage(title: 'Complaints')),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.rate_review_rounded,
              title: 'Feedback',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackPage(title: 'Feedback')),
                );
              },
            ),

            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.red.withOpacity(0.15),
                border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=>MyLogin()), (route) => false);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: Colors.white.withOpacity(0.15),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
