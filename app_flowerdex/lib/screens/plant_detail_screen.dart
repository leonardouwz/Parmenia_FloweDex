import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/plant.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  Future<void> _waterPlant(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('plants')
          .doc(plant.id)
          .update({
        'lastWatered': DateTime.now().millisecondsSinceEpoch,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Planta regada!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysSinceWatered = DateTime.now().difference(plant.lastWatered).inDays;
    final daysUntilNextWatering = plant.wateringFrequency - daysSinceWatered;

    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: plant.imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    plant.imageUrl,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.local_florist,
                  size: 80,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.label, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Especie: ${plant.species}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Riego cada ${plant.wateringFrequency} días'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado del Riego',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: plant.needsWatering ? Colors.red : Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Último riego: ${DateFormat('dd/MM/yyyy').format(plant.lastWatered)}',
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          plant.needsWatering ? Icons.warning : Icons.check_circle,
                          color: plant.needsWatering ? Colors.orange : Colors.green,
                        ),
                        SizedBox(width: 8),
                        Text(
                          plant.needsWatering
                              ? 'Necesita agua (hace $daysSinceWatered días)'
                              : 'Próximo riego en $daysUntilNextWatering días',
                          style: TextStyle(
                            color: plant.needsWatering ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (plant.notes.isNotEmpty) ...[
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(plant.notes),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _waterPlant(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.water_drop),
                label: Text('Regar Planta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}