import 'package:flutter/material.dart';

List Widgets = [
  'Option1'
  'Option2'
  'Option3'
  'Option4'
];



class SetupScreen extends StatelessWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Setup(),
    );
  }
}

class Setup extends StatelessWidget {
  const Setup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(

      children:<Widget>[
        GridView.builder(
          shrinkWrap: true,
          itemCount: Widgets.length,
          gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index){
            return Center(
              child: Text(Widgets[index])
            );
          },
        )
      ],
    );
  }
}
