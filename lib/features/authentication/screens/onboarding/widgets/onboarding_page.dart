import 'package:flutter/material.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key, required this.image, required this.title, required this.subtitle,
  });

  final String image, title , subtitle;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Sizes.defaultSpace),
      child: Column(
        children: [
          Image(
            width: double.infinity ,
            height: 250,
            image: AssetImage(image),
          ),
          SizedBox(height: 60,),
          Text(
            title,
            style:
                TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: PColor.primary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Sizes.spaceBtwItems / 2,),
          Text(
            subtitle,
            style:
                TextStyle(fontSize: 13,color: PColor.subTitleColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}