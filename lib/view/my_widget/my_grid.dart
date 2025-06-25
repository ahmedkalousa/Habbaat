import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/util/constant.dart';

class MyGrid extends StatelessWidget {
  final int itemCount ;
  final String image;
  final String text;
  final String locationTitle;
  final Function() onPressed;
  final String rate;
  final ScrollPhysics physics;
  
  const MyGrid({
    super.key,
    required this.itemCount, 
    required this.image, 
    required this.text, 
    required this.locationTitle, 
    required this.onPressed, 
    required this.rate, 
    required this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return  Consumer<SpacesProvider>(
              builder: (context, value, child) {
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  physics: physics,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final isFav = value.isFavorite(index);
                    return Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            image,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.all(20),
                            child: GestureDetector(
                              onTap: () {
                                value.toggleFavorite(index);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  size: 30,
                                  color:  Colors.red[800],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            color: Colors.white.withOpacity(0.85),
                            height: 120,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    text,
                                    style: TextStyle(
                                      color: primaryColor1,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                    Text(
                                      locationTitle, 
                                      style: TextStyle(
                                        color: primaryColor1, 
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    Icon(Icons.location_on, color: primaryColor,),
                                  ],),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          style: ButtonStyle(
                                            backgroundColor: WidgetStatePropertyAll(
                                              primaryColor,
                                            ),
                                          ),
                                          onPressed: onPressed,
                                          child: const Text(
                                            'عرض المزيد',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                            ),
                                            Text(rate),
                                          ],
                                        ),
                                      ],
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
              },
            )
        ;
  }
}