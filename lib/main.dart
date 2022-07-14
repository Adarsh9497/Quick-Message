import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickmessage/sharedpref.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MySharedPref.init();

  runApp(const MyApp());
}

enum Mode {
  dark_mode,
  light_mode,
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ScreenUtilInit(
          designSize: const Size(1080, 1920),
          builder: (context, child) => const MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  late final TextEditingController _controller;
  Mode mode = Mode.light_mode;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    init();
  }

  Future<void> init() async {
    mode = MySharedPref.getMode();
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0xff515151),
      textColor: Colors.white,
      fontSize: 15.0,
    );
  }

  Color getColor() {
    return mode == Mode.light_mode
        ? Colors.grey.shade800
        : Colors.grey.shade200;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          mode == Mode.light_mode ? Colors.grey.shade100 : Colors.grey.shade900,
      appBar: AppBar(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 50.w,
          child: Image.asset(
            'asset/sent.png',
            scale: 11,
          ),
        ),
        title: Text(
          'Quick Message',
          style: TextStyle(
            color: Colors.green.shade700,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (mode == Mode.light_mode) {
                    MySharedPref.setMode(1);
                    mode = Mode.dark_mode;
                  } else {
                    MySharedPref.setMode(0);
                    mode = Mode.light_mode;
                  }
                });
              },
              icon: mode == Mode.light_mode
                  ? Icon(
                      Icons.dark_mode,
                      color: Colors.grey.shade800,
                    )
                  : const Icon(
                      Icons.light_mode,
                      color: Colors.white,
                    )),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: mode == Mode.light_mode
            ? Colors.grey.shade100
            : Colors.grey.shade900,
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 1),
          child: Container(
            height: 1,
            color: mode == Mode.light_mode
                ? Colors.grey.shade300
                : Colors.grey.shade800,
            width: double.infinity,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 100.h,
              ),
              Text(
                'Enter Mobile Number',
                textAlign: TextAlign.center,
                textScaleFactor: 1.0,
                style: TextStyle(
                  color: getColor(),
                  fontWeight: FontWeight.w500,
                  fontSize: 55.sp,
                ),
              ),
              SizedBox(
                height: 50.h,
              ),
              TextFormField(
                controller: _controller,
                textAlign: TextAlign.center,
                autofocus: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onEditingComplete: () {},
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
                keyboardType: TextInputType.number,
                style: TextStyle(
                  height: 1.5,
                  fontSize: 80.sp,
                  fontWeight: FontWeight.w500,
                  color: getColor(),
                  letterSpacing: 0.5,
                ),
                decoration: InputDecoration(
                  hintMaxLines: 1,
                  hintStyle: TextStyle(
                      color: mode == Mode.light_mode
                          ? Colors.grey.shade400
                          : Colors.grey.shade800),
                  hintText: '0000000000',
                  isDense: true,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                    });
                  },
                  child: Text('Clear')),
              SizedBox(
                height: 10.h,
              ),
              Text(
                'Please enter the mobile number of the user to whom you want to send whatsapp message',
                textScaleFactor: 1.0,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 37.sp,
                  color: getColor(),
                ),
              ),
              SizedBox(
                height: 100.h,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_controller.text.isEmpty) {
                      showToast('Number cannot be empty!');
                    } else if (_controller.text.length != 10) {
                      showToast('Enter 10-digit number');
                    } else {
                      final number = int.tryParse(_controller.text);
                      if (number == null) {
                        showToast('Invalid phone number');
                      } else {
                        await canLaunch("https://wa.me/+91${_controller.text}")
                            ? await launch(
                                "https://wa.me/+91${_controller.text}")
                            : showToast(
                                "Couldn't Launch Whatsapp",
                              );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 35.h)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.whatsapp,
                        size: 60.sp,
                        color: Colors.white,
                      ),
                      Text(
                        '  Whatsapp',
                        style: TextStyle(
                          fontSize: 55.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 100.h,
              ),
              GestureDetector(
                onTap: () async {
                  await canLaunch(
                          "https://www.linkedin.com/in/adarsh-soni-7892aa198")
                      ? await launch(
                          "https://www.linkedin.com/in/adarsh-soni-7892aa198")
                      : showToast(
                          "Couldn't launch url",
                        );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 50.w,
                    vertical: 30.h,
                  ),
                  child: RichText(
                    text: TextSpan(
                        text: 'Developed by ',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 35.sp,
                          color: getColor(),
                        ),
                        children: [
                          TextSpan(
                            text: 'Adarsh Soni',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 35.sp,
                              color: Colors.green,
                            ),
                          )
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
