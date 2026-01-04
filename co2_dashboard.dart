import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CO2ImpactDashboard extends StatelessWidget {
  const CO2ImpactDashboard({super.key});

  // CO2 factors (kg CO2 saved per kg waste)
  static const Map<String, double> carbonFactors = {
    'Stubble': 1.5,
    'Crop Residue': 1.2,
    'Manure': 0.8,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CO₂ Impact Dashboard'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('farm_waste_listings')
            .where('isBooked', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          double totalCO2Saved = 0;
          double stubbleCO2 = 0;
          double residueCO2 = 0;
          double manureCO2 = 0;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            final String wasteType = data['wasteType'];
            final int quantity =
                int.tryParse(data['quantityKg'].toString()) ?? 0;

            final double factor = carbonFactors[wasteType] ?? 0;
            final double saved = quantity * factor;

            totalCO2Saved += saved;

            if (wasteType == 'Stubble') stubbleCO2 += saved;
            if (wasteType == 'Crop Residue') residueCO2 += saved;
            if (wasteType == 'Manure') manureCO2 += saved;
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🌱 Environmental Impact Summary',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'This dashboard estimates environmental impact based on booked farm waste that would otherwise be burned or dumped',
                ),

                const SizedBox(height: 25),

                _impactCard(
                  title: 'Stubble',
                  value: stubbleCO2,
                  factor: carbonFactors['Stubble']!,
                ),

                _impactCard(
                  title: 'Crop Residue',
                  value: residueCO2,
                  factor: carbonFactors['Crop Residue']!,
                ),

                _impactCard(
                  title: 'Manure',
                  value: manureCO2,
                  factor: carbonFactors['Manure']!,
                ),

                const SizedBox(height: 25),

                Divider(color: Colors.grey.shade400),

                const SizedBox(height: 10),

                Center(
                  child: Column(
                    children: [
                      const Text(
                        '🌍 Total CO₂ Emissions Saved',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${totalCO2Saved.toStringAsFixed(2)} kg CO₂',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _impactCard({
    required String title,
    required double value,
    required double factor,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.eco, color: Colors.green),
        title: Text(title),
        subtitle: Text('CO₂ saving factor: $factor kg/kg'),
        trailing: Text(
          '${value.toStringAsFixed(2)} kg',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
