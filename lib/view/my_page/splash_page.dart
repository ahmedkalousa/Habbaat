import 'package:flutter/material.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/main_home_page.dart';



class splashPage extends StatefulWidget {
  const splashPage({super.key});

  @override
  State<splashPage> createState() => _splashPageState();
}

class _splashPageState extends State<splashPage> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return mainHomePage();
        },
      ));
    });
    return Scaffold(
      
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              SizedBox(
                height: 200,
                width: 200,
                child: Image.asset('images/logo-white.png')),
                Text('www.habbaat.net',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),)
            ],
          ),
        ),
      ),
    );
  }
}
