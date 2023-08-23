import 'package:cricbuzz/Tabs/featured_tab.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Color.fromARGB(255, 0, 146, 112),
          child: TabBar(indicatorColor: Colors.white, tabs: [
            Tab(
              child: Text('FEATURED'),
            ),
            Tab(
              child: Text('CRICBUZZ PLUS'),
            )
          ]),
        ),
        Expanded(
          child: TabBarView(children: [
            Container(
              child: FeaturedTab(),
            ),
            Container(
              child: Text('data'),
            )
          ]),
        )
      ],
    );
  }
}
