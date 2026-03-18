
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skillconnect/view_profile.dart';

void main() {
  runApp(const MyEdit());
}

class MyEdit extends StatelessWidget {
  const MyEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14b8a6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MyEditPage(title: 'Edit Profile'),
    );
  }
}

class MyEditPage extends StatefulWidget {
  const MyEditPage({super.key, required this.title});

  final String title;

  @override
  State<MyEditPage> createState() => _MyEditPageState();
}

class _MyEditPageState extends State<MyEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  _MyEditPageState() {
    _get_data();
  }

  TextEditingController first_nameController = TextEditingController();
  TextEditingController last_nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController skillsController = TextEditingController();
  TextEditingController preferred_locationController = TextEditingController();

  File? _selectedImage;
  String photo = '';
  String? currentPhotoUrl;

  // Validation Functions
  String? _validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName must contain only letters';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  void _get_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/job_seeker_profile/');
    try {
      final response = await http.post(urls, body: {'lid': lid});
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String first_name = jsonDecode(response.body)['first_name'];
          String last_name = jsonDecode(response.body)['last_name'];
          String email = jsonDecode(response.body)['email'];
          String phone = jsonDecode(response.body)['phone'];
          String location = jsonDecode(response.body)['location'];
          String skills = jsonDecode(response.body)['skills'];
          String preferred_location = jsonDecode(response.body)['preferred_location'];
          String profilePhoto = url + jsonDecode(response.body)['profile_photo'];

          setState(() {
            first_nameController.text = first_name;
            last_nameController.text = last_name;
            emailController.text = email;
            phoneController.text = phone;
            locationController.text = location;
            skillsController.text = skills;
            preferred_locationController.text = preferred_location;
            currentPhotoUrl = profilePhoto;
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
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
                'Loading Profile...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Profile Photo Section
                  GestureDetector(
                    onTap: _checkPermissionAndChooseImage,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF14b8a6),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF14b8a6).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (currentPhotoUrl != null
                                ? NetworkImage(currentPhotoUrl!)
                                : null) as ImageProvider?,
                            child: _selectedImage == null && currentPhotoUrl == null
                                ? Icon(
                              Icons.person_rounded,
                              size: 70,
                              color: Colors.grey[400],
                            )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF14b8a6), Color(0xFF0d9488)],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    'Tap to change photo',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // First Name
                  _buildTextField(
                    controller: first_nameController,
                    label: 'First Name',
                    icon: Icons.person_outline_rounded,
                    validator: (value) => _validateName(value, 'First name'),
                  ),

                  // Last Name
                  _buildTextField(
                    controller: last_nameController,
                    label: 'Last Name',
                    icon: Icons.person_outline_rounded,
                    validator: (value) => _validateName(value, 'Last name'),
                  ),

                  // Email
                  _buildTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  // Phone
                  _buildTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),

                  // Location
                  _buildTextField(
                    controller: locationController,
                    label: 'Current Location',
                    icon: Icons.location_on_outlined,
                    validator: (value) => _validateRequired(value, 'Location'),
                  ),

                  // Skills
                  _buildTextField(
                    controller: skillsController,
                    label: 'Skills (comma separated)',
                    icon: Icons.stars_outlined,
                    validator: (value) => _validateRequired(value, 'Skills'),
                  ),

                  // Preferred Location
                  _buildTextField(
                    controller: preferred_locationController,
                    label: 'Preferred Job Location',
                    icon: Icons.map_outlined,
                    validator: (value) => _validateRequired(value, 'Preferred location'),
                  ),

                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _send_data,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14b8a6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF14b8a6)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF14b8a6), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  void _send_data() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
        msg: 'Please fill all fields correctly',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String fname = first_nameController.text;
    String lname = last_nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String place = locationController.text;
    String skills = skillsController.text;
    String preferred_location = preferred_locationController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/job_seeker_edit_profile/');
    try {
      final response = await http.post(urls, body: {
        "lid": lid,
        "photo": photo,
        'first_name': fname,
        'last_name': lname,
        'email': email,
        'phone': phone,
        'location': place,
        'skills': skills,
        'preferred_location': preferred_location,
      });

      setState(() {
        _isSaving = false;
      });

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          Fluttertoast.showToast(
            msg: 'Profile Updated Successfully!',
            backgroundColor: Colors.green,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProfilePage(title: "My Profile"),
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Update failed. Please try again.',
            backgroundColor: Colors.red,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Network Error',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _chooseAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        String encodedImage = base64Encode(_selectedImage!.readAsBytesSync());
        photo = encodedImage;
      });
    }
  }

  Future<void> _checkPermissionAndChooseImage() async {
    final PermissionStatus status = await Permission.photos.request();
    if (status.isGranted) {
      _chooseAndUploadImage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Permission Required'),
            ],
          ),
          content: const Text(
            'Please grant photo access permission from app settings to change your profile picture.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFF14b8a6))),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    first_nameController.dispose();
    last_nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    skillsController.dispose();
    preferred_locationController.dispose();
    super.dispose();
  }
}
