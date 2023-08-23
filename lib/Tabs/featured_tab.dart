import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeaturedTab extends StatefulWidget {
  const FeaturedTab({Key? key}) : super(key: key);

  @override
  State<FeaturedTab> createState() => _FeaturedTabState();
}

class _FeaturedTabState extends State<FeaturedTab> {
  late Future<List<Map<String, dynamic>>> futureMatchData;
  PageController _pageController = PageController();
  int _currentPage = 0;
  int itemToRemoveIndex =
      4; // Index of the item to be removed (5th item) ncz it showing null to 5th item

  @override
  void initState() {
    super.initState();
    futureMatchData = fetchMatchData();
    _pageController = PageController(initialPage: _currentPage);
  }

  // Function to fetch match data from the API
  Future<List<Map<String, dynamic>>> fetchMatchData() async {
    final response = await http.get(Uri.parse(
        'https://api.cricapi.com/v1/currentMatches?apikey=c588d0d7-5bc3-4565-97a7-e047c8da2968&offset=0'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final matches = data['data'] as List<dynamic>;
      final matchDataList = matches.cast<Map<String, dynamic>>();
      return matchDataList;
    } else {
      throw Exception('Failed to load match data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureMatchData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available.'));
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 173,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length - 1,
                  itemBuilder: (context, index) {
                    final filteredMatches = List.from(snapshot.data!);
                    filteredMatches.removeAt(itemToRemoveIndex);
                    final match = filteredMatches[index];

                    return SizedBox(
                      width: 290,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        child: Card(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 240,
                                          child: Text(
                                            match['name'],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        Icon(Icons.notifications_none)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Image.network(
                                                match['teamInfo'][0]['img']
                                                    .toString(),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              match['teamInfo'][0]['shortname']
                                                  .toString(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 90,
                                        ),
                                        Text(
                                          '${match['score'][0]['r']} - ${match['score'][0]['w']} (${match['score'][0]['o']})',
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Image.network(
                                                match['teamInfo'][1]['img']
                                                    .toString(),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              match['teamInfo'][1]['shortname']
                                                  .toString(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 90,
                                        ),
                                        Text(
                                          '${match['score'][1]['r']} - ${match['score'][1]['w']} (${match['score'][1]['o']} )',
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 240,
                                      child: Text(
                                        match['status'],
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 7),
                                color: Color.fromARGB(255, 237, 237, 237),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Visibility(
                                      visible: match['fantasyEnabled'] == true,
                                      child: Row(
                                        children: [
                                          Text('Fantasy'),
                                          SizedBox(width: 9),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: match['bbbEnabled'] == true,
                                      child: Row(
                                        children: [
                                          Text('Table'),
                                          SizedBox(width: 9),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: match['hasSquad'] == true,
                                      child: Row(
                                        children: [
                                          Text('Squad'),
                                          SizedBox(width: 9),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: match['matchStarted'] == true,
                                      child: Row(
                                        children: [
                                          Text('Match Started'),
                                          SizedBox(width: 9),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: match['matchEnded'] == false,
                                      child: Row(
                                        children: [
                                          Text('Match Not Ended'),
                                          SizedBox(width: 9),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  snapshot.data!.length - 1,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPage ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? Colors.grey
                          : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: () {
              //       setState(() {
              //         futureMatchData = fetchMatchData();
              //       });
              //     },
              //     child: Text('Refresh Data'),
              //   ),
              // ),
            ],
          );
        }
      },
    );
  }
}
