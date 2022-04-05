
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/util/util.dart';

class Profile extends StatefulWidget {

  final routeName = '/profile';

  const Profile({Key? key}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {


  @override
  void initState() {
    super.initState();

  }
  
  Widget profileHeader() {
    return const Center( child: Text('Test'),);
  }

  Widget imageItem(String url, String title, String description){
    return GestureDetector(
      child: Image.network(url),
      onTap: (){
          navigateTo(context, Pug(imageUrl: url,imageTitle: title, imageDescription:description,imageLike: 15,));
      },
    );
  }

  Widget profileContent() {
    return GridView(gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
    ),
      children: [
        imageItem('https://picsum.photos/250?image=1','MY PUG 1', 'Lorem ipsum...'),
        imageItem('https://picsum.photos/250?image=2','MY PUG 2', 'Lorem ipsum...'),
        imageItem('https://picsum.photos/250?image=3','MY PUG 3', 'Lorem ipsum...'),
        imageItem('https://picsum.photos/250?image=4','MY PUG 4', 'Lorem ipsum...'),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
        backgroundColor: Colors.white,

        body:  Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            profileHeader(),
            Expanded(child: profileContent())
          ],
        ))

    );
  }
}
