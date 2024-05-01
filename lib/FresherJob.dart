import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiremi/CongratulationScreen.dart';
import 'package:hiremi/HomePage.dart';
import 'package:hiremi/JobDescription.dart';
import 'package:hiremi/api_services/user_services.dart';
//import 'package:hiremi/jon_description_screen.dart';
import 'package:hiremi/models/fresher_job_model.dart';
import 'package:hiremi/signin.dart';
import 'package:hiremi/utils/api.dart';
import 'package:hiremi/utils/my_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FresherJobScreen extends StatefulWidget {
  const FresherJobScreen({super.key});

  @override
  State<FresherJobScreen> createState() => _FresherJobScreenState();
}

class _FresherJobScreenState extends State<FresherJobScreen> {

  List<FresherJobModel> fresherJobList=[];
  Map<int, bool> jobStatusMap = {};
  @override
  void initState() {
    super.initState();
    // OnlyApplyOneJob();
     fetchDataFromApi();
    _loadUserEmail();
   // _checkAppliedJobs(); //
    //checkIfApplied();
    //_loadStatus2();
    //fetchAppliedJobs();
  }
  List<int> appliedJobIds = [];
  List<int> otherJobIds = [];
  String loginEmail="";
  bool AlreadyApplied = false;
  bool alreadyApplied = false;

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');

    if (savedUsername != null && savedUsername.isNotEmpty) {
      setState(() {
        loginEmail = savedUsername;
      });
      print("login mail is  $loginEmail");
    }
  }
  Future<void> fetchDataFromApi() async {
      final response = await http.get(Uri.parse('${ApiUrls.baseurl}api/fresherjob/'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        fresherJobList = responseData
            .map((data) => FresherJobModel.fromJson(data))
            .toList();
      });
      print("Fresher Job List Length: ${fresherJobList.length}");
    } else {
      throw Exception('Failed to load data from the API');
    }
  }
  Future<void> OnlyApplyOneJob()async{
    print("OnlyApplyOneJob");
     try{
       final response = await http.get(Uri.parse('${ApiUrls.baseurl}job-applications/'));


       if (response.statusCode == 200) {
          final List<dynamic> dataList = json.decode(response.body);

          // Counter for verified records


          for (int index = 0; index < dataList.length; index++) {
            final Map<String, dynamic> data = dataList[index];

            final String userEmail = data['email'];


            if (userEmail == loginEmail) {
               await OnlyApplyOneJobDialogBox();
               print("I am in if section");
               break;
              // Increment the counter for the next verified record
            }
            else
              {
                print("Hello i am in else section");
               print(loginEmail);
              }
          }
        }
        else {
          print('Status code: ${response.statusCode}');
          throw Exception('Failed to load data');
        }
     }
     catch(e){
       print("Error in OnlyApplyOneJooooooooob :$e");
     }
  }
  Future<void> _checkAppliedJobs() async {
    try {
      final response = await http.get(Uri.parse('${ApiUrls.baseurl}job-applications/'));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        for (int index = 0; index < dataList.length; index++) {
          final Map<String, dynamic> data = dataList[index];
          int id_for_joballpication=data['id'];
          final String appliedUserEmail = data['email'];
          final String appliedJobProfile = data['job_profile'];
          final String appliedCompanyName = data['company_name'];
          print(appliedJobProfile);
          if (appliedUserEmail == loginEmail) {

            print("Checking applied job: Email: $appliedUserEmail, Job Profile: $appliedJobProfile, Company Name: $appliedCompanyName");

            // If the user has applied for this job, find the corresponding job in fresherJobList
            final appliedJob = fresherJobList.firstWhere(
                  (job) => job.jobProfile == appliedJobProfile && job.companyName == appliedCompanyName,
              orElse: () => FresherJobModel(), // Return an empty job if not found
            );

            if (appliedJob.id != null) {
              setState(() {
                jobStatusMap[appliedJob.id!] = true;
                print('Updated jobStatusMap: $jobStatusMap');// Update job status to true
              });
              print("Response body:${response.body}");
              print('Applied Job ID is: ${appliedJob.id}');
             print("Applied job  is $appliedJob");
              print("Status of jobStatusMap is$jobStatusMap");
              print('Status code: ${response.statusCode}');
              }
            else
              {
                print(appliedJob);
                print('Applied Job ID is: ${appliedJob.id}');
                print("Response body:${response.body}");
                print("Status of jobStatusMap is$jobStatusMap");
                print('Status code: ${response.statusCode}');
              }
            // if (appliedJob.jobProfile != null && appliedJob.companyName != null) {
            //   setState(() {
            //     final key = '${appliedJob.jobProfile}-${appliedJob.companyName}';
            //     setState(() {
            //       jobStatusMap[key] = true;
            //     });
            //     print('Updated jobStatusMap: $jobStatusMap'); // Update job status to true
            //   });
            //   print("Response body:${response.body}");
            //   print("Status of jobStatusMap is$jobStatusMap");
            //   print('Status code: ${response.statusCode}');
            // }
            // else{
            //   print("Not working properly");
            //   print("Response body:${response.body}");
            //   print('Status code: ${response.statusCode}');
            //   print("${appliedJob.jobProfile}-${appliedJob.companyName}");
            // }
          }
        }
      } else {
        print('Status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error in _checkAppliedJobs: $e");
    }
  }


  Future<bool> checkIfApplied(String userEmail, String jobProfile, String companyName) async {
    try {
      final response = await http.get(Uri.parse('${ApiUrls.baseurl}job-applications/'));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        for (int index = 0; index < dataList.length; index++) {
          final Map<String, dynamic> data = dataList[index];
          final String appliedUserEmail = data['email'];
          final String appliedJobProfile = data['job_profile'];
          final String appliedCompanyName = data['company_name'];

          if (appliedUserEmail == userEmail && appliedJobProfile == jobProfile && appliedCompanyName == companyName) {
            return true;
          }
        }
        return false; // User hasn't applied for this job
      } else {
        print('Status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error in checkIfApplied: $e");
      return false;
    }
  }

  Future<bool> OnlyApplyOneJobDialogBox() async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            actions: [
              Column(
                children: [
                  SizedBox(height: 30,),
                  Center(
                    child: Text(
                      "Your can only apply one job",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "FontMain",
                        fontSize: 18,
                        color: Color(0xFFBD232B),
                      ),
                    ),
                  ),
                  SizedBox(height: 35,),

                  ElevatedButton(
                    onPressed: () async{
                      // Handle onTap
                      // var sharedPref=await SharedPreferences.getInstance();
                      // sharedPref.setBool(CongratulationScreenState.KEYLOGIN, false);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(sourceScreen: '', uid: '', username: '', verificationId: '')),
                            (Route<dynamic> route) => false, // This line removes all routes from the stack
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF13640),
                      minimumSize: Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "HomePage",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return result ?? false; // Return false if the dialog is dismissed without pressing 'OK'
  }
  @override
  Widget build(BuildContext context) {

    print('Applied Job IDs: $appliedJobIds');
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await fetchDataFromApi();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return HomePage(
                            sourceScreen: '',
                            uid: '',
                            username: '',
                            verificationId: '',
                          );
                        },
                      ),
                    );
                  },
                  child: Image.asset('images/Back_Button.png'),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Fresher's Jobs",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "FontMain",
                        fontSize: 25,
                      ),
                    ),
                    Image.asset(
                      'images/Saly-1 (2).png',
                      width: 180,
                      height: 160,
                      fit: BoxFit.cover,
                    )
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 380,
                        height: 620,
                        child: fresherJobList.isNotEmpty
                            ? ListView.builder(
                          itemCount: fresherJobList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final job = fresherJobList[index];

                            return Column(
                              children: [
                                Card(
                                  color: const Color(0xFFF8F8F8),
                                  surfaceTintColor: Colors.transparent,
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          'Company: ${job.companyName}',
                                          style: TextStyle(
                                            fontFamily: 'FontMain',
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          'Location: ${job.jobLocation}',
                                          style: TextStyle(
                                            fontFamily: 'FontMain',
                                          ),),
                                      ),
                                      ListTile(
                                        title: Text(
                                          'CTC: ${job.jobCtc} LPA',
                                          style: TextStyle(
                                            fontFamily: 'FontMain',
                                          ),
                                        ),
                                      ),


                                      Padding(
                                        padding: const EdgeInsets.only(left:200.0),
                                        child: Container(
                                          width: 155, // Set width as per your requirement
                                          height: 40, // Set height as per your requirement
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFBD232B)), // Red background color
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // White text color
                                            ),
                                            onPressed: () async {
                                              bool applied = await checkIfApplied(loginEmail, job.jobProfile!, job.companyName!);
                                              if (applied) {
                                                // If already applied, show a message
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('You have already applied for this job.'),
                                                  ),
                                                );
                                              } else {
                                                // Otherwise, navigate to the job details page
                                                final int jobIndex = fresherJobList.indexOf(job);
                                                print("Selected Job Index: $jobIndex");
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => JobDescription(
                                                      jobIndex: jobIndex,
                                                      id: job.id!,
                                                      jobProfile: job.jobProfile!,
                                                      jobLocation: job.jobLocation!,
                                                      jobCtc: job.jobCtc!,
                                                      companyName: job.companyName!,
                                                      education: job.education!,
                                                      jobDescreption: job.jobDescription!,
                                                      termsAndConditions: job.termsAndConditions!,
                                                      skillRequired: job.skillsRequired!,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  'View details',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 73,
                                ),
                              ],
                            );
                          },
                        )

                            : Padding(
                              padding: const EdgeInsets.only(bottom: 75.0),
                              child: Center(
                                child: Text(
                              'No vacancies are available',
                              style: TextStyle(
                                fontFamily: 'FontMain',
                                fontSize: 18,
                              ),
                                ),
                              ),),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}

