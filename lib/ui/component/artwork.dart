import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'colors.dart';

class ArtWork extends StatelessWidget {
  const ArtWork({super.key, required this.path});
  final String path;
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.vertical,
      key: const Key('key'),
      onDismissed: (_) => Get.back(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CachedNetworkImage(
          imageUrl: path,
          imageBuilder: (context, imageProvider) => Center(
            child: Image(
              image: imageProvider,
            ),
          ),
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              color: redColor,
            ),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}

class ArtworkTile extends StatelessWidget {
  const ArtworkTile({
    super.key,
    required this.height,
    required this.width,
    required this.path,
     this.text = 'ArtWork',
  });

  final double height;
  final double width;
  final List path;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
          '  $text',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          constraints: BoxConstraints(
            maxHeight: height * 0.3,
          ),
          width: width,
          child: PageView.builder(
              // shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: path.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: path[index],
                  imageBuilder: (context, imageProvider) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: BoxConstraints(
                      maxHeight: height * 0.3,
                    ),
                    width: width,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(12)),
                    child: Card(
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: InkWell(
                          onTap: () {
                            showGeneralDialog(
                              barrierLabel: "Label",
                              barrierDismissible: false,
                              barrierColor: Colors.black.withOpacity(0.5),
                              transitionDuration:
                                  const Duration(milliseconds: 200),
                              context: context,
                              pageBuilder: (context, anim1, anim2) {
                                return ArtWork(
                                  path: path[index],
                                );
                              },
                              transitionBuilder:
                                  (context, anim1, anim2, child) {
                                return SlideTransition(
                                  position: Tween(
                                          begin: const Offset(0, 1),
                                          end: const Offset(0, 0))
                                      .animate(anim1),
                                  child: child,
                                );
                              },
                            );
                          },
                          child: Image(
                            image: imageProvider,
                          ),
                        ),
                      ),
                    ),
                  ),
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: redColor,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                );
              }),
        ),
      ],
    );
  }
}
