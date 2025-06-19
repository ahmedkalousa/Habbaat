import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/util/constant.dart';

class FavoritePage extends StatefulWidget {
  static const id = '/FavoritePage';

  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'المفضلة',
          style: TextStyle(
            fontSize: 30,
            color: Colors.black,
          ),
        ),
      ),
      body: Consumer<SpacesProvider>(
        builder: (context, provider, child) {
          final favoriteSpaces = provider.spaces.where((space) => provider.isFavorite(space.id)).toList();
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (favoriteSpaces.isEmpty) {
            return const Center(child: Text('لا توجد بيانات متاحة'));
          }
          if (provider.error != null) {
            return Center(child: Text('خطأ: \u001b[31m[31m${provider.error}\u001b[0m'));
          }
          return GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: favoriteSpaces.length,
            itemBuilder: (context, index) {
              final itemIndex = favoriteSpaces[index];
              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'images/4.jpeg',
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
                          provider.toggleFavorite(itemIndex.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withOpacity(0.6),
                          ),
                          child: Icon(
                            Icons.favorite,
                            size: 30,
                            color: Colors.red[800],
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
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'النص الإفتراضي',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        primaryColor,
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: const Text('عرض المزيد', style: TextStyle(color: Colors.white)),
                                  ),
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                      ),
                                      Text('4.8'),
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
      ),
    );
  }
}