import 'package:flutter/material.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Waste Listing Form'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDEBAR
            Container(
              width: 180,
              color: Colors.grey.shade800,
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('vm',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 4),
                  Text('6789',
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 20),
                  Text('• Home', style: TextStyle(color: Colors.white)),
                  SizedBox(height: 8),
                  Text('• Dashboard', style: TextStyle(color: Colors.white)),
                  SizedBox(height: 8),
                  Text('• FAQs', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // MAIN FORM
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'List Your Farm Waste',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  const Text('Type of Waste'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField(
                    value: 'Stubble',
                    items: const [
                      DropdownMenuItem(
                          value: 'Stubble', child: Text('Stubble')),
                      DropdownMenuItem(
                          value: 'Crop Residue',
                          child: Text('Crop Residue')),
                      DropdownMenuItem(
                          value: 'Manure', child: Text('Manure')),
                      DropdownMenuItem(
                          value: 'Fruit & Vegetable Waste',
                          child: Text('Fruit & Vegetable Waste')),
                    ],
                    onChanged: (value) {},
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('Quantity (kg)'),
                  const SizedBox(height: 6),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('Location'),
                  const SizedBox(height: 6),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
  if (selectedWasteType == null) return;

  await FirestoreService().addWaste(
    farmerName: farmerNameController.text,
    farmerId: farmerIdController.text,
    wasteType: selectedWasteType!,
    quantityKg: int.parse(quantityController.text),
    pricePerKg: int.parse(priceController.text),
    location: locationController.text,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Waste listed successfully')),
  );
},

                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    child: const Text('Submit'),
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
