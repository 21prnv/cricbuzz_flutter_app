import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> fixturesWithLocalAndVisitorTeams = [];
  int fetchedFixtureCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFixtures();
  }

  Future<void> fetchFixtures() async {
    final response = await http.get(
      Uri.parse(
          'https://cricket.sportmonks.com/api/v2.0/fixtures?api_token=5bIdKeCkxdgpLCIZom2QGcrzVtzkfuKRxlxKETTCOc5PAuGawNK0XNRmro6x'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final fixtures = data['data'].cast<Map<String, dynamic>>();

      for (final fixture in fixtures) {
        final localTeamId = fixture['localteam_id'];
        final localTeamData = await fetchLocalTeam(localTeamId);

        final visitorTeamId = fixture['visitorteam_id'];
        final visitorTeamData = await fetchVisitorTeam(visitorTeamId);

        final fixtureWithTeams = {
          'fixture': fixture,
          'localTeamData': localTeamData,
          'visitorTeamData': visitorTeamData,
        };

        setState(() {
          fixturesWithLocalAndVisitorTeams.add(fixtureWithTeams);
        });

        fetchedFixtureCount++;
        if (fetchedFixtureCount >= 10) {
          setState(() {
            isLoading = false;
          });
          break;
        }

        await Future.delayed(const Duration(milliseconds: 100));
      }
    } else {
      throw Exception('Failed to load fixtures');
    }
  }

  Future<dynamic> fetchLocalTeam(int localTeamId) async {
    final response = await http.get(
      Uri.parse(
          'https://cricket.sportmonks.com/api/v2.0/teams/$localTeamId?api_token=5bIdKeCkxdgpLCIZom2QGcrzVtzkfuKRxlxKETTCOc5PAuGawNK0XNRmro6x'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load local team data');
    }
  }

  Future<dynamic> fetchVisitorTeam(int visitorTeamId) async {
    final response = await http.get(
      Uri.parse(
          'https://cricket.sportmonks.com/api/v2.0/teams/$visitorTeamId?api_token=5bIdKeCkxdgpLCIZom2QGcrzVtzkfuKRxlxKETTCOc5PAuGawNK0XNRmro6x'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load visitor team data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 101, 101, 101),
            leadingWidth: 100,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Image.asset(
                'assets/cb_Logo.png',
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
            elevation: 0,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                margin: const EdgeInsets.only(right: 4),
                child: SizedBox(
                    height: 20,
                    child: InkWell(
                      onTap: () {
                        print('Button tapped');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Row(
                          children: const [
                            Text(
                              'Menu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Icon(
                              Icons.arrow_circle_down_outlined,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                decoration:
                    const BoxDecoration(color: Color.fromARGB(255, 22, 14, 67)),
                child: const Text(
                  'Matches',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: fixturesWithLocalAndVisitorTeams.length,
                        itemBuilder: (context, index) {
                          final fixtureWithTeams =
                              fixturesWithLocalAndVisitorTeams[index];
                          final fixture = fixtureWithTeams['fixture'];
                          final localTeamData =
                              fixtureWithTeams['localTeamData'];
                          final visitorTeamData =
                              fixtureWithTeams['visitorTeamData'];

                          final matchDescription = '${fixture['round']}';

                          final homeTeamCode = localTeamData != null
                              ? localTeamData['code']
                              : 'N/A';
                          final awayTeamName = visitorTeamData != null
                              ? visitorTeamData['name']
                              : 'N/A';
                          const inningsStatus = 'Innings Break';

                          return Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    matchDescription,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  Row(
                                    children: [
                                      Text(homeTeamCode),
                                      const SizedBox(width: 4),
                                    ],
                                  ),
                                  Text(
                                    awayTeamName,
                                  ),
                                  Text(
                                    fixture['note'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: fixture['status'] == 'Finished'
                                            ? Colors.blue
                                            : Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          )),
    );
  }
}
