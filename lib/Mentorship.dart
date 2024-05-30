import 'dart:convert';
import 'package:hiremi/HomePage.dart';
import 'package:hiremi/PhonePePayment.dart';
import 'package:hiremi/api_services/base_services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
class Mentorship extends StatefulWidget {
  const Mentorship({super.key});

  @override
  State<Mentorship> createState() => _MentorshipState();
}


class _MentorshipState extends State<Mentorship> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AlreadyApplied();
    _loadUserEmail();
    fetchDiscount();
  }
  String loginEmail="";
  int Uid = 0;
  String DiscountedPrice="";
  String Discount="";
  String OriginalPrice="";
  // or whatever default value you want to assign
  bool hasAlreadyApplied = false;
  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');

    if (savedUsername != null && savedUsername.isNotEmpty) {
      setState(() {
        loginEmail = savedUsername;
      });

    }
  }
  Future<void> fetchDiscount() async {
    final response = await http.get(Uri.parse('http://13.127.81.177:8000/api/discount/'));

    if (response.statusCode == 200) {
      // Parse the response JSON
      final List<dynamic> data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        final Map<String, dynamic> discountData = data.last; // Access the last element in the list
        final int discount = discountData['discount'];
        final int originalPrice = discountData['original_price'];

        // Calculate discounted price
        final double discountPrice = originalPrice - (originalPrice * discount / 100);

        setState(() {
          DiscountedPrice = discountPrice.toString(); // Convert ID to String
          Discount=discount.toString();
          OriginalPrice=originalPrice.toString();
        });


      }

    }
  }
  Future<void> AlreadyApplied() async {
    try {
      final response = await http.get(Uri.parse('${ApiUrls.baseurl}api/mentorship/'));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        for (int index = 0; index < dataList.length; index++) {
          final Map<String, dynamic> data = dataList[index];

          final String userEmail = data['email'];

          if (userEmail == loginEmail) {
           setState(() {
             print("User has already applied. Email: $loginEmail");
             hasAlreadyApplied = true;
           });
            break;
          }
        }
      } else {
        print('Status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error in alreadyApplied: $e");
    }
  }
  Future<void> loadUserUid() async {
   // await _loadUserEmail();

    try {
      final response = await http.get(Uri.parse('${ApiUrls.baseurl}verified-emails/'));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        // Counter for verified records


        for (int index = 0; index < dataList.length; index++) {
          final Map<String, dynamic> data = dataList[index];

          final String userEmail = data['email'];
          final int UID = data['id'];


          if (userEmail == loginEmail ) {
            print(userEmail);
            print(UID);
           // await postVerifiedEmail();
           // await VerificationID2();
            Uid=UID;
            print(Uid);
            await applyNow();

            // Increment the counter for the next verified record

          }
        }
      }
      else {
        print('Status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error in fetchData in UID: $e');
    }
  }
  Future<void> applyNow() async {
    final apiUrl = '${ApiUrls.baseurl}api/mentorship/';

    try {
      // Make a PATCH request to update the "Applied" field
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'applied': true,
           'email':loginEmail,
           'uid':Uid,
          "candidate_status": "Pending",
        }),
      );

      if (response.statusCode == 201) {
        // Successfully updated the "Applied" field


        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => HomePage(sourceScreen: '', uid: '', username: '', verificationId: ''),
        //   ),
        // );
          print("Appliedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
        await ShowDialog();
        print('Applied successfully!');
        print('ApplyNow Response Code: ${response.statusCode}');
        print('ApplyNow Response Body: ${response.body}');
        // Add any additional logic or UI changes here
      }
      else {
        // Failed to update the "Applied" field
        print('Failed to apply: ${response.statusCode}');
        print("${response.body}");
        // Add error handling or show an error message
      }
    } catch (e) {
      // Handle exceptions
      print('Exception while applying: $e');
      if (e is http.ClientException) {
        // Print the response body if available
        print('Response body: ${e.message}');
      }
      // Add error handling or show an error message
    }
  }

  Future<void> ShowDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Blurred background
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("your_background_image_path"),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
                ),
              ),
            ),
            // Your dialog
            AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              content: WillPopScope(
                onWillPop: () async {
                  // Handle back button press here
                  // Returning true allows the dialog to be popped
                  // Returning false prevents the dialog from being popped
                  return true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Thank you for applying to the Hiremi Mentorship Program. Check your email for interview details and further instructions. Best of luck on your journey to career excellence with Hiremi!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "FontMain",
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Thank you for applying to Hiremi", // Your leading text
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "FontMain",
                          fontSize: 20,
                          color: Color(0xFFBD232B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConformationDialog() async {


    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Blurred background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5), // Adjust the opacity as needed
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            // AlertDialog on top of the blurred background
            WillPopScope(
              onWillPop: () async {
                // Handle back button press here
                // Returning true allows the dialog to be popped
                // Returning false prevents the dialog from being popped
                return true;
              },
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,// Set the background color to transparent
                actions: [
                  // Column(
                  //   children: [
                  //     Center(
                  //       child: RichText(
                  //         textAlign: TextAlign.center,
                  //         text: TextSpan(
                  //           style: TextStyle(
                  //             fontFamily: "FontMain",
                  //             fontSize: 15,
                  //             color: Colors.black, // Default color for other text
                  //           ),
                  //           children: [
                  //             TextSpan(
                  //               text: "You have applied for ",
                  //             ),
                  //             TextSpan(
                  //               text: Intern_Profile,
                  //               style: TextStyle(
                  //                 fontWeight: FontWeight.bold, // Make JobProfile text bold
                  //                 color: Color(0xFFBD232B), // Desired color for JobProfile text
                  //               ),
                  //             ),
                  //             TextSpan(
                  //               text: " internship position. We will update you after the interview.",
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(height: 20),
                  //   ],
                  // ),
                     Column(
                       children: [
                         SizedBox(height: 30,),
                         Center(
                        child: Text(
                          "Ready to begin your mentorship journey", // Your leading text
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "FontMain",
                            fontSize: 20,
                            color: Color(0xFFBD232B),
                          ),
                        ),
                      ),
                         SizedBox(height: 30,),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: [
                             ElevatedButton(
                               onPressed: () async {
                                 Navigator.pop(context);
                                 await loadUserUid();

                               },
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Color(0xFFF13640),
                                 minimumSize: Size(50, 5),
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(30),
                                 ),
                               ),
                               child: Text(
                                "Yes",
                                 textAlign: TextAlign.center,
                                 style: TextStyle(
                                   color: Colors.white,
                                   fontWeight: FontWeight.w700,
                                   fontSize: 22,
                                 ),
                               ),
                             ),
                             ElevatedButton(
                               onPressed: () async {
                                 Navigator.pop(context);
                               },
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.white,
                                 minimumSize: Size(50, 5),
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(30),
                                 ),
                               ),
                               child: Text(
                                  "No",
                                 textAlign: TextAlign.center,
                                 style: TextStyle(
                                   color: Color(0xFFF13640),
                                   fontWeight: FontWeight.w700,
                                   fontSize: 22,
                                 ),
                               ),
                             ),
                           ],
                         )
                       ],
                     )
                ],

              ),
            ),
          ],
        );
      },
    );


  }
  List<String> imagePaths = [
    'images/certificate.png', // Adjust the image paths as needed
    'images/certificate.png',
    'images/certificate.png',
  ];
  String getTextForIndex(int index) {
    if (index == 0) {
      return 'Only for college \nstudents!';
    } else if (index == 1) {
      return 'Become Job Ready';
    } else if (index == 2) {
      return 'Industry-Recognised\n Internship-Certificate';
    } else {
      return ''; // Default value or handle additional indices if needed
    }
  }
  String getAnotherTextForIndex(int index) {
    if (index == 0) {
      return 'All Candidate will be Provided with\na course completition & internship\ncertificate upon Succesfull\ncompletition of the mentorship';
    } else if (index == 1) {
      return 'Build an attractive resume/profile\n along with soft skills,training and\nmock interview';
    } else if (index == 2) {
      return 'Post membership completion,\n candidates will be given course\ncompletion and internship\ncertificates';
    } else {
      return ''; // Default value or handle additional indices if needed
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth=MediaQuery.of(context).size.width;
    double screenHeight=MediaQuery.of(context).size.height;
    print("Width is $screenWidth");
    print("Height is $screenHeight");
    return Scaffold(
      body: SafeArea(
       child: Stack(
           children:[
             SingleChildScrollView(
               child: Column(
                 children: [
                   InkWell(
                     onTap:(){
                       // Navigator.pushReplacement(
                       //   context,
                       //   MaterialPageRoute(
                       //     builder: (context) {
                       //       return HomePage(sourceScreen: "", uid: "", username: "", verificationId: "");
                       //     },
                       //   ),
                       // );
                       Navigator.pop(context);
                     },
                     child: Align(
                         alignment: Alignment.topLeft,
                         child: Image.asset('images/Back_Button.png')),
                   ),
                   SizedBox(height: screenHeight*0.02,),
                   Text("Why Hiremi Mentorship?",
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       fontFamily: 'FontMain',
                       fontSize: screenWidth < 411  ? 22 : 25,

                     ),),
                   SizedBox(height: screenHeight*0.027,),

                   Container(
                     height: screenHeight * 0.19,
                     child: ListView(
                       scrollDirection: Axis.horizontal,
                       children: List.generate(
                         3,
                             (index) => Padding(
                           padding: EdgeInsets.only(left: 28.0),
                           child: Stack(
                             children: [
                               ClipRRect(
                           borderRadius: BorderRadius.circular(15.0),
                                 child: Container(
                                   width: 350,
                                   height: 180,
                                   decoration: BoxDecoration(
                                     gradient: LinearGradient(
                                       begin: Alignment.topLeft,
                                       end: Alignment.bottomRight,
                                       colors: [Color(0xFFF13640), Color(0xFF8E3E42)],
                                       stops: [0.1454, 1.0],
                                     ),
                                   ),
                                 ),
                               ),
                               // Column(
                               //   children: [
                               //     SizedBox(height: screenHeight * 0.015),
                               //     Padding(
                               //       padding: const EdgeInsets.only(right: 60.0),
                               //       child: Text(
                               //         getTextForIndex(index),
                               //
                               //         style: TextStyle(
                               //           color: Colors.white,
                               //           fontSize: screenHeight < 700 ? 13.5 : 17,
                               //           fontFamily: 'FontMain',
                               //         ),
                               //       ),
                               //     ),
                               //     SizedBox(height: 7.5),
                               //     Padding(
                               //       padding: const EdgeInsets.only(left:38.0),
                               //       child: Text(
                               //         getAnotherTextForIndex(index),
                               //
                               //         style: TextStyle(
                               //           color: Colors.white,
                               //           fontSize: screenHeight < 700 ? 12.5 : 14.5,
                               //         ),
                               //       ),
                               //     ),
                               //   ],
                               // ),
                               Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   SizedBox(height: screenHeight * 0.015),
                                   Padding(
                                     padding: const EdgeInsets.only(
                                       left: 10,
                                       right: 80.0,
                                     ),
                                     child: Text(
                                       getTextForIndex(index),
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize:
                                         screenHeight < 700 ? 13.5 : 17,
                                         fontFamily: 'FontMain',
                                       ),
                                     ),
                                   ),
                                   const SizedBox(height: 7.5),
                                   Padding(
                                     padding: const EdgeInsets.only(
                                         left: 10, right: 80.0),
                                     child: Text(
                                       getAnotherTextForIndex(index),
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize:
                                         screenHeight < 700 ? 12.5 : 14.5,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                               Padding(
                                 padding: const EdgeInsets.only(left: 270, top: 30),
                                 child: Image.asset(imagePaths[index]),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                   ),


                   SizedBox(height: screenHeight*0.033,),
                   Padding(
                     padding: const EdgeInsets.only(left: 10.0),
                     child: Text("Mentorship",
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         fontFamily: 'FontMain',
                         fontSize:  screenWidth < 411  ? 22 : 25,

                       ),),
                   ),



                   SizedBox(height: screenHeight*0.026,),
                   // Text("Mentorship at Hiremi is a dynamic partnership designed to"
                   //     "foster professional and academic growth.It's a collaborative"
                   //     "relationship between experienced mentors and individuals"
                   //     "seeking guidance in their career or academic pursuits.",
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
                     child: Text("Mentorship at Hiremi is a dynamic partnership designed to promote professional and academic growth. It's a collaborative relationship between experienced mentors and college students seeking guidance in their career or academic pursuits.",
                       textAlign: TextAlign.start,
                       style:TextStyle(
                         fontWeight:FontWeight.w600,
                         fontSize:  screenWidth < 411   ? 12.5: 14,


                       ),
                     ),
                   ),
                   SizedBox(height: screenHeight*0.033,),
                   Padding(
                     padding: const EdgeInsets.only(left: 38.0),
                     child: Stack(
                       children: [
                         Container(
                           width: screenWidth*0.69, // Adjust the width as needed
                           height: screenHeight*0.28, // Adjust the height as needed
                           child: Card(
                               elevation: 9.0,
                               surfaceTintColor: Colors.transparent,// rgba(0, 0, 0, 0.25)
                               child: Column(
                                 children: [
                                   Padding(
                                     padding: const EdgeInsets.only(top: 24.0),
                                     child: Text("Standard",
                                       textAlign: TextAlign.center,
                                       style: TextStyle(
                                         fontFamily: 'FontMain',
                                         fontSize: screenWidth < 411   ? 19 : 22,
                                       ),),
                                   ),
                                   Padding(
                                     padding: const EdgeInsets.only(top: 24.0),
                                     child: Text("Rs $DiscountedPrice/Rs $OriginalPrice",
                                       textAlign: TextAlign.center,
                                       style: TextStyle(
                                         fontFamily: 'FontMain',
                                         fontSize: screenWidth < 411 ? 19 : 22,
                                       ),),
                                   ),
                                   SizedBox(height: screenHeight*0.02,),
                                   Padding(
                                     padding: const EdgeInsets.only(left: 10.0),
                                     child: Row(children: [
                                       ClipRRect(
                                         borderRadius: BorderRadius.circular(10.0),
                                         child: Container(
                                           height: screenHeight*0.0308,
                                           width: screenWidth*0.063,
                                           color: Colors.redAccent,
                                           child: Center(
                                             child: Container(
                                               height: screenHeight*0.0154,
                                               width: screenWidth*0.0315,
                                               decoration: BoxDecoration(
                                                 shape: BoxShape.circle,
                                                 color: Colors.white,
                                               ),
                                             ),
                                           ),
                                         ),
                                       ),
                                       SizedBox(width: screenWidth*0.048,),
                                       Text("Entire Academic\nSession+ one extra year",
                                         textAlign: TextAlign.center,
                                         style: TextStyle(
                                           fontFamily: 'FontMain',
                                           fontSize:  screenWidth < 411 ?10: 12,
                                         ),),

                                     ],),
                                   ),
                                   SizedBox(height: screenHeight*0.02,),

                                 ],
                               )
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.only(left: 220.0,bottom: 70),
                           child: Card(
                               elevation: 9.0,
                               surfaceTintColor: Colors.transparent,// rgba(0, 0, 0, 0.25)
                               child: Column(
                                 children: [
                                   Text("$Discount% OFF",
                                     textAlign: TextAlign.center,
                                     style: TextStyle(
                                       fontFamily: 'FontMain',
                                       fontSize:  screenWidth < 411 ?17: 21,
                                       color:  Color(0xFFF13640),
                                     ),),

                                 ],
                               )
                           ),
                         ),

                       ],
                     ),
                   ),
                   SizedBox(height: screenHeight*0.071,),
                   Text("Why Choose Hiremi Mentorship?",
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       fontFamily: 'FontMain',
                       fontSize:  screenWidth < 411 ? 16.65 : 20,
                     ),),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                     SizedBox(width: screenWidth*0.033,),
                     Image.asset('images/partnerpana.png'),
                     //SizedBox(width: screenWidth*0.011,),
                     Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text("1.Personalised Guidance :",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             fontFamily: 'FontMain',
                             color: Colors.redAccent,
                             fontSize:  screenWidth < 411  ? 9.2 : 13.5,

                           ),),
                         SizedBox(height: screenHeight*0.023,),
                         Text("Navigate your\ncareer with\npersonalized mentorship\ntailored to your\n goals and aspirations.",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             fontFamily: "FontMain",
                             fontSize: screenWidth < 411  ? 9.5 : 12,
                           ),),],
                     )
                   ],),
                   SizedBox(height: screenHeight*0.041,),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                     SizedBox(width: screenWidth*0.018,),
                     Column(
                       children: [
                         Text("2.Industry Insights :",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             fontFamily: 'FontMain',
                             color: Colors.redAccent,
                             fontSize: screenWidth < 411 ? 10 : 13.5,
                           ),),
                         SizedBox(height: screenHeight*0.023,),
                         Text("Gain valuable insights\ninto your chosen\nfield from experienced\nprofessionals.",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             fontFamily: "FontMain",
                             fontSize: screenWidth < 411 ? 9.4 : 12,
                           ),),],
                     ),
                     Image.asset('images/Cpana.png'),
                   ],),
                   SizedBox(height: screenHeight*0.035,),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                     SizedBox(width: screenWidth*0.033,),
                     Image.asset('images/Helping.png'),
                     SizedBox(width: screenWidth*0.024,),
                     Column(
                       children: [
                         Text("3.Skill Development :",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             fontFamily: 'FontMain',
                             color: Colors.redAccent,
                             fontSize:screenWidth < 411  ? 9.35 : 13.5,
                           ),),
                         SizedBox(height: 20,),
                         Text("Elevate your skill\nset with curated\nprograms designed\nto enhanceyour capabilities\nand make you\njob-ready."
                           ,
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             fontFamily: "FontMain",
                             fontSize:screenWidth < 411  ? 9 : 11,
                           ),),],
                     )
                   ],),
                   SizedBox(height: screenHeight*0.041,),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                     SizedBox(width: screenWidth*0.048,),
                     Column(
                       children: [
                         Text("4.Network Opportunities:",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             fontFamily: 'FontMain',
                             color: Colors.redAccent,
                             fontSize: screenWidth < 411 ? 9.5 : 13,
                           ),),
                         SizedBox(height: screenHeight*0.023,),
                         Text("Expand your professional\nnetwork with connections\nthat can influence\nyour career\ntrajectory.",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             fontFamily: "FontMain",
                             fontSize: screenWidth < 411  ? 8.2 : 12,
                           ),),],
                     ),
                     Image.asset('images/pana.png'),
                   ],),
                   SizedBox(height: screenHeight*0.041,),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                     SizedBox(width: screenWidth*0.09,),
                     Image.asset('images/Confidence.png'),
                     SizedBox(width: screenHeight*0.011,),
                     Column(

                       children: [
                         Text("5.Confidence building:",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             fontFamily: 'FontMain',
                             color: Colors.redAccent,
                             fontSize: screenWidth < 411 ? 9.3 : 13,
                           ),),
                         SizedBox(height: screenHeight*0.023,),
                         Text("Develop confidence in\nyour abilities with\nongoing support and\nconstructive feedback.",
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             fontFamily: "FontMain",
                             fontSize: screenWidth < 411 ? 9.3 : 12,
                           ),),],
                     )
                   ],),
                   SizedBox(height: screenHeight*0.0415,),
                   Padding(
                     padding: const EdgeInsets.only(right: 48.0),
                     child: Text("Who does it help?",
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         fontFamily: 'FontMain',
                         fontSize:screenWidth < 411 ? 24: 28,
                       ),),
                   ),
                   SizedBox(height: screenHeight*0.0415,),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Image.asset("images/JobSeeker.png"),
                      SizedBox(width: screenWidth*0.060,),
                       Column(
                         children: [
                           Padding(
                             padding: const EdgeInsets.only(right: 180.0),
                             child: Text("Job Seekers:",style: TextStyle(
                               color: Colors.redAccent,
                               fontFamily: 'FontMain',
                               fontSize: screenWidth < 411 ? 9: 12,
                             ),),
                           ),
                           Text("Individuals looking to enter\nthe jobmarket benefit from\nmentorship by gaining a\ncompetitive edge and understanding\nindustry expectations.",
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontFamily: "FontMain",
                               fontSize: screenWidth < 411 ? 9: 12,
                             ),)
                         ],
                       ),
                     ],
                   ),
                   SizedBox(height: screenHeight*0.0415,),
                   // Row(
                   //   mainAxisAlignment: MainAxisAlignment.center,
                   //   children: [
                   //     Image.asset("images/Medical.png"),
                   //     SizedBox(width: screenWidth*0.018,),
                   //     Column(
                   //       children: [
                   //         Padding(
                   //           padding: const EdgeInsets.only(right: 170.0),
                   //           child: Text("College Students:",
                   //             textAlign: TextAlign.center,
                   //             style: TextStyle(
                   //               color: Colors.redAccent,
                   //               fontFamily: 'FontMain',
                   //               fontSize: screenWidth < 411 ? 9: 12,
                   //             ),),
                   //         ),
                   //         Text("Mentorship aids students in navigating\ntheir academic journey, making\ninformed careerchoices, and\npreparing for the professional\nworld.",
                   //           textAlign: TextAlign.center,
                   //           style: TextStyle(
                   //             fontFamily: "FontMain",
                   //             fontSize: screenWidth < 411 ? 9: 11,
                   //           ),)
                   //       ],
                   //     ),
                   //   ],
                   // ),
                   SizedBox(height: screenHeight*0.03,),
                   // Row(
                   //   mainAxisAlignment: MainAxisAlignment.center,
                   //   children: [
                   //     Image.asset("images/Profe.png"),
                   //     SizedBox(width: screenWidth*0.0608,),
                   //     Column(
                   //       children: [
                   //         Padding(
                   //           padding: const EdgeInsets.only(right: 170.0),
                   //           child: Text("Professionals:",style: TextStyle(
                   //             color: Colors.redAccent,
                   //             fontFamily: 'FontMain',
                   //             fontSize: screenWidth < 411  ? 9: 13,
                   //           ),),
                   //         ),
                   //         Text("Even experienced professionals\nbenefit by receiving guidance on\ncareer advancement, leadership skills,\nand staying relevant in a rapidly\nchanging work environment.",
                   //           textAlign: TextAlign.center,
                   //           style: TextStyle(
                   //             fontFamily: "FontMain",
                   //             fontSize: screenWidth < 411 ? 9: 12,
                   //           ),)
                   //       ],
                   //     ),
                   //   ],
                   // ),

                   Text("How to Apply for Mentorship?",
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       fontFamily: 'FontMain',
                       fontSize: screenWidth < 411 ? 19: 23,
                     ),),
                   SizedBox(height: screenHeight*0.041,),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Column(
                         children: [
                           Image.asset("images/Rocket.png"),

                         ],
                       ),
                       // SizedBox(width: screenWidth*0.060,),
                       // Column(
                       //   children: [
                       //     Padding(
                       //       padding: const EdgeInsets.only(right: 170.0),
                       //       child: Text("Step 1:",style: TextStyle(
                       //         color: Colors.redAccent,
                       //         fontFamily: 'FontMain',
                       //         fontSize: screenWidth < 411  ? 11: 14,
                       //       ),),
                       //     ),
                       //     Text(" Tap on Apply\nLaunch the Hiremi app\nand head to the\nMentorship section.\nLook for the'Apply Now' option\nand tap on it to begin\nyour application process.",
                       //       textAlign: TextAlign.center,
                       //       style: TextStyle(
                       //         fontFamily: "FontMain",
                       //         fontSize: screenWidth < 411 ? 9: 11,
                       //       ),)
                       //   ],
                       // ),
                       Column(
                         children: [
                           // Heading before Step 1


                           // Step 1
                           Padding(
                             padding: const EdgeInsets.only(right: 170.0),
                             child: Text(
                               "Step 1:",
                               style: TextStyle(
                                 color: Colors.redAccent,
                                 fontFamily: 'FontMain',
                                 fontSize: screenWidth < 411 ? 11 : 14,
                               ),
                             ),
                           ),

                           // Description Text
                           Padding(
                             padding: const EdgeInsets.only(right: 170.0),
                             child: Text(
                               "Tap to Apply", // Your bold heading text
                               style: TextStyle(
                                 fontFamily: 'FontMain',
                                 fontSize: screenWidth < 411 ? 11 : 13,
                                 fontWeight: FontWeight.bold, // Set the font weight to bold
                               ),
                             ),
                           ),
                           Text(
                             "1.Launch the Hiremi appand\nhead to the Mentorship section.",
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontFamily: "FontMain",
                               fontSize: screenWidth < 411 ? 9 : 11,
                             ),
                           ),
                           SizedBox(height: 5,),
                           Text(
                             "2.Look for the apply now option \n and tap on it to begin your\n application process",
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontFamily: "FontMain",
                               fontSize: screenWidth < 411 ? 9 : 11,
                             ),
                           ),
                         ],
                       ),

                     ],
                   ),
                   Padding(
                     padding: const EdgeInsets.only(right: 80.0),
                     child: Image.asset("images/Line.png"),
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       SizedBox(width: screenWidth*0.024,),
                       Column(
                         children: [
                           Padding(
                             padding: const EdgeInsets.only(right: 170.0),
                             child: Text("Step 2:",style: TextStyle(
                               color: Colors.redAccent,
                               fontFamily: 'FontMain',
                               fontSize: screenWidth < 411 ? 9.5: 13,
                             ),),
                           ),
                           Padding(
                             padding: const EdgeInsets.only(right: 120.0),
                             child: Text(
                               "Q&A Session:", // Your bold heading text
                               style: TextStyle(
                                 fontFamily: 'FontMain',
                                 fontSize: screenWidth < 411 ? 11 : 13,
                                 fontWeight: FontWeight.bold, // Set the font weight to bold
                               ),
                             ),
                           ),
                           Text(
                             "1.Once your session is\nscheduled,you will receive a\n notification",
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontFamily: "FontMain",
                               fontSize: screenWidth < 411 ? 9 : 11,
                             ),
                           ),
                           SizedBox(height: 5,),
                           Text(
                             "2.During the session ,you'll\nhave to opportunity to\ndiscuss your queires and\ncareer aspiration with our\nexperienced mentors",
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontFamily: "FontMain",
                               fontSize: screenWidth < 411 ? 9 : 11,
                             ),
                           ),
                         ],
                       ),
                       SizedBox(width: screenWidth*0.036,),
                       Column(
                         children: [
                           Image.asset("images/Meeting.png"),

                         ],
                       ),
                     ],
                   ),
                   Padding(
                     padding: const EdgeInsets.only(right: 20.0),
                     child: Image.asset("images/Line2.png"),
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Column(
                         children: [
                           Image.asset("images/Flag.png"),

                         ],
                       ),
                       SizedBox(width: screenWidth*0.060,),
                       Column(
                         children: [
                           Padding(
                             padding: const EdgeInsets.only(right: 170.0),
                             child: Text("Step 3:",style: TextStyle(
                               color: Colors.redAccent,
                               fontFamily: 'FontMain',
                               fontSize: screenWidth < 411  ? 7.5: 11.4,
                             ),),
                           ),
                           Padding(
                             padding: const EdgeInsets.only(right: 70.0),
                             child: Text(
                               "Enroll in the program:", // Your bold heading text
                               style: TextStyle(
                                 fontFamily: 'FontMain',
                                 fontSize: screenWidth < 411 ? 11 : 13,
                                 fontWeight: FontWeight.bold, // Set the font weight to bold
                               ),
                             ),
                           ),
                           Text("1.After selection, gain exclusive\naccess to enroll in our mentorship\nprogram via the app by\ncompleting payment process.",
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontFamily: "FontMain",
                               fontSize: screenWidth < 411  ? 9.4: 11,
                             ),),
                           SizedBox(height: 5,),
                           Text("2.Get ready for a transformative\nexperience in skill development,\nreal-time project exposure, and\ncareer growth.",

                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontFamily: "FontMain",
                               fontSize: screenWidth < 411  ? 9.4: 11,
                             ),)
                         ],
                       ),
                     ],
                   ),
                   SizedBox(height: screenHeight*0.100,)

                 ],
               ),
             ),
             Positioned(
               bottom: 0,
               left: 0,
               right: 0,
               child: Container(
                 height: screenHeight*0.0711, // Adjust the height as needed
                 // Adjust the color as needed
                 child: Center(
                   child: ElevatedButton(
                     onPressed: () async {
                       await AlreadyApplied();

                       if (hasAlreadyApplied) {
                         // User has already applied, disable the button
                         return null;
                       } else {
                         // User has not applied, handle button click logic here
                       //  await loadUserUid();
                         await _showConformationDialog();
                         // await ShowDialog();
                       }
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: hasAlreadyApplied ? Colors.grey : const Color(0xFFF13640),
                       minimumSize: Size(250, 50),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(30),
                       ),
                     ),
                     child: Text(
                       hasAlreadyApplied ? "Already Applied" : "Apply Now",
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         color: hasAlreadyApplied ? Colors.white : Colors.white,
                         fontWeight: FontWeight.w700,
                         fontSize: 22,
                       ),
                     ),
                   ),
                 ),
               ),
             ),

           ],
       ),

      ),
    );
  }
}
