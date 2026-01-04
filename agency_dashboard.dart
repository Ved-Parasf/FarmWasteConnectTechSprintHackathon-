import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgencyDashboard extends StatefulWidget {
  const AgencyDashboard({super.key});

  @override
  State<AgencyDashboard> createState() => _AgencyDashboardState();
}

class _AgencyDashboardState extends State<AgencyDashboard> {
  String selectedWasteType = 'All';
  RangeValues priceRange = const RangeValues(5, 200);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency Dashboard'),
        backgroundColor: Colors.blueGrey,
      ),

      // ✅ BODY STARTS HERE
      body: Row(
        children: [
          // ================= LEFT FILTER PANEL =================
          Container(
            width: 260,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                const Text('Waste Type'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedWasteType,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Stubble', child: Text('Stubble')),
                    DropdownMenuItem(
                        value: 'Crop Residue', child: Text('Crop Residue')),
                    DropdownMenuItem(value: 'Manure', child: Text('Manure')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedWasteType = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                const Text('Price Range (₹ / kg)'),
                RangeSlider(
                  min: 5,
                  max: 200,
                  divisions: 39,
                  values: priceRange,
                  labels: RangeLabels(
                    priceRange.start.round().toString(),
                    priceRange.end.round().toString(),
                  ),
                  onChanged: (values) {
                    setState(() {
                      priceRange = values;
                    });
                  },
                ),
              ],
            ),
          ),

          // ================= RIGHT CONTENT =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ HEADING
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Available Farm Waste Listings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ✅ LIST
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('farm_waste_listings')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading data'));
                      }

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      final filteredDocs = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        final price = (data['pricePerKg'] is int)
                            ? data['pricePerKg']
                            : int.tryParse(
                                    data['pricePerKg'].toString()) ??
                                0;

                        final wasteMatch = selectedWasteType == 'All' ||
                            data['wasteType'] == selectedWasteType;

                        final priceMatch = price >= priceRange.start &&
                            price <= priceRange.end;

                        return wasteMatch && priceMatch;
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return const Center(
                          child: Text('No listings match filters'),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data =
                              doc.data() as Map<String, dynamic>;
                          final bool isBooked =
                              data['isBooked'] ?? false;

                          return Card(
                            margin: const EdgeInsets.all(12),
                            child: ListTile(
                              leading: GestureDetector(
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection('farm_waste_listings')
                                      .doc(doc.id)
                                      .update({
                                    'isBooked': !isBooked,
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: isBooked
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              title: Text(
                                data['farmerName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Waste: ${data['wasteType']}'),
                                  Text(
                                      'Quantity: ${data['quantityKg']} kg'),
                                  Text(
                                      'Price: ₹${data['pricePerKg']} /kg'),
                                  Text(
                                      'Location: ${data['location']}'),
                                  const SizedBox(height: 6),
                                  Text(
                                    isBooked ? 'BOOKED' : 'NOT BOOKED',
                                    style: TextStyle(
                                      color: isBooked
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
