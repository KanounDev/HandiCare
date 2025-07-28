import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> activitiesData = [];
  List<FlSpot> progressData = []; // For graph data

  @override
  void initState() {
    super.initState();
    _fetchActivitiesData();
  }

  // Récupérer et regrouper les données des activités
  Future<void> _fetchActivitiesData() async {
    FirebaseFirestore.instance
        .collection('activites')
        .get()
        .then((querySnapshot) {
      Map<String, List<int>> groupedProgress = {};
      querySnapshot.docs.forEach((doc) {
        String libelle = doc['libelle'];
        int progress = doc['progress'];
        if (!groupedProgress.containsKey(libelle)) {
          groupedProgress[libelle] = [];
        }
        groupedProgress[libelle]?.add(progress);
      });

      // Calcul de la moyenne de progression pour chaque activité
      List<Map<String, dynamic>> activityList = [];
      groupedProgress.forEach((libelle, progressList) {
        double avgProgress = progressList.fold(0, (sum, progress) => sum + progress) / progressList.length;
        activityList.add({
          'libelle': libelle,
          'avgProgress': avgProgress.toInt(),
        });
      });

      // Mise à jour des données des activités et du graphique
      setState(() {
        activitiesData = activityList;

        // Créer les points du graphique
        progressData = activityList.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value['avgProgress'].toDouble());
        }).toList();
      });
    }).catchError((error) {
      print("Erreur lors de la récupération des activités: $error");
    });
  }

  // Réinitialiser les activités en supprimant tout dans la collection 'activites'
  Future<void> _resetActivities() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('activites').get();
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      setState(() {
        activitiesData.clear();
        progressData.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toutes les activités ont été supprimées.')),
      );
    } catch (e) {
      print("Erreur lors de la suppression des activités: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression des activités.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord des Activités', style: TextStyle(fontSize: 20),),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 139, 222, 161),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: () {
              _resetActivities();
            },
            tooltip: 'Réinitialiser les activités',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Graphique des Résultats
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: progressData.isEmpty
                    ? const Center(child: Text('Aucune donnée disponible'))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: progressData,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Résumé des Activités :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: activitiesData.length,
                itemBuilder: (context, index) {
                  final activity = activitiesData[index];
                  return _buildActivityTile(activity['libelle'], '${activity['avgProgress']}%');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher une activité
  Widget _buildActivityTile(String activityName, String progress) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        leading: const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
        ),
        title: Text(
          activityName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Progrès: $progress',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }
}
