// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:work_spaces/util/constant.dart';
// import 'package:work_spaces/view/my_page/main_home_page.dart';



// class splashPage extends StatefulWidget {
//   const splashPage({super.key});

//   @override
//   State<splashPage> createState() => _splashPageState();
// }

// class _splashPageState extends State<splashPage> {
//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(context, MaterialPageRoute(
//         builder: (context) {
//           return mainHomePage();
//         },
//       ));
//     });
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       builder: (context, child) {
//         return Scaffold(
//           backgroundColor: primaryColor,
//           body: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   SizedBox(height: 10.h),
//                   Center(
//                     child: SizedBox(
//                       height: 200.h,
//                       width: 200.w,
//                       child: Image.asset('images/logo-white.png')),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 24.0),
//                     child: Text('www.habbaat.net',style: TextStyle(color: Colors.white,fontSize: 16,),),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
