import 'package:flutter/material.dart';

//This is the Loading Screen which we add as a waiting screen if the server is not reachable or is taking time to reach

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ConVo'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
