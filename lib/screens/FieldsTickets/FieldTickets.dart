import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:todo/screens/FieldsTickets/AssignedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/AcceptedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/EnRouteFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/ArrivedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/LoadingFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/SolvedFieldTicket.dart';
import 'package:todo/screens/FieldsTickets/ReportedFieldTicket.dart';
import 'package:todo/screens/config/config_service.dart';

class FieldTicketScreen extends StatefulWidget {
  final String token;

  const FieldTicketScreen({Key? key, required this.token}) : super(key: key);

  @override
  _FieldTicketScreenState createState() => _FieldTicketScreenState();
}

class _FieldTicketScreenState extends State<FieldTicketScreen> {
  bool isLoading = false;
  int assignedCount = 0;
  int acceptedCount = 0;
  int enRouteCount = 0;
  int arrivedCount = 0;
  int loadingCount = 0;
  int solvedCount = 0;
  int reportedCount = 0;

  @override
  void initState() {
    super.initState();
    fetchTicketCounts(); // Appel initial pour récupérer les compteurs
  }

  Future<void> fetchTicketCounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.93.54:4000/api/ticket/count/${widget.token}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            assignedCount = responseData['assigned'];
            acceptedCount = responseData['accepted'];
            enRouteCount = responseData['enRoute'];
            arrivedCount = responseData['arrived'];
            loadingCount = responseData['loading'];
            solvedCount = responseData['solved'];
            reportedCount = responseData['reported'];
            isLoading = false;
          });
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to load ticket counts: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching ticket counts: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await fetchTicketCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Process Tickets',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Color.fromRGBO(209, 77, 90, 1),
        toolbarHeight: 60,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const SizedBox(
                      height: 70), // espace entre l'AppBar et la première ligne
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildTicketCard(
                          'Assigned Tickets',
                          assignedCount,
                          Colors.blue,
                          Icons.assignment,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldAssignedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTicketCard(
                          'Accepted Tickets',
                          acceptedCount,
                          Colors.pink,
                          Icons.check_circle,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldAcceptedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildTicketCard(
                          'En Route Tickets',
                          enRouteCount,
                          Colors.yellow,
                          Icons.directions,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldEnRouteScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTicketCard(
                          'Arrived Tickets',
                          arrivedCount,
                          Colors.purple,
                          Icons.location_on,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldArrivedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildTicketCard(
                          'Loading Tickets',
                          loadingCount,
                          Colors.orange,
                          Icons.hourglass_empty,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldLoadingScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTicketCard(
                          'Solved Tickets',
                          solvedCount,
                          Colors.green,
                          Icons.check_circle_outline,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldSolvedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width:
                            200, // Ajuste la largeur du bouton "Reported Tickets"
                        child: buildTicketCard(
                          'Reported Tickets',
                          reportedCount,
                          Colors.grey,
                          Icons.report_problem,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FieldReportedScreen(
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildTicketCard(String title, int count, Color color, IconData icon,
      VoidCallback onPressed) {
    return Container(
      height: 140, // Ajuste la hauteur des cartes
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
