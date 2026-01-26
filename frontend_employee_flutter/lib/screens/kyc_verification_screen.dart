import 'package:flutter/material.dart';

class KycVerificationScreen extends StatefulWidget {
  @override
  _KycVerificationScreenState createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Worker Verification')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complete your KYC to start earning', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            _buildUploadItem('ID Proof (Front)', Icons.badge),
            _buildUploadItem('ID Proof (Back)', Icons.badge),
            _buildUploadItem('Police Clearance Certificate', Icons.verified_user),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/jobs'),
                child: Text('Submit Documents'),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE94560), padding: EdgeInsets.all(16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUploadItem(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFE94560)),
          SizedBox(width: 16),
          Text(title),
          Spacer(),
          Icon(Icons.upload_file, color: Colors.grey),
        ],
      ),
    );
  }
}
