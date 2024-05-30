import 'package:flutter/material.dart';

class PaymentCompletionScreen extends StatefulWidget {
  final String sourceScreen;

  const PaymentCompletionScreen({Key? key, required this.sourceScreen}) : super(key: key);

  @override
  State<PaymentCompletionScreen> createState() => _PaymentCompletionScreenState();
}

class _PaymentCompletionScreenState extends State<PaymentCompletionScreen> {
  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.of(context).pop(); // This will pop the current screen
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF13640), Color(0xFF8E3E42)],
                      stops: [0.1454, 1.0],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 280.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("images/whitetick.png"),
                        Text(
                          "Payment successful",
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'FontMain',
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 1.6,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.white,
                      ],
                      stops: [0.1454, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                      Image.asset("images/greentick.png"),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Text(
                        "Thank You for your verification",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'FontMain',
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {

                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent,
                          textStyle: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'FontMain',
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
