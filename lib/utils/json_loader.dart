import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';

/// Loads user data from a local JSON asset file.
Future<List<Map<String, dynamic>>> loadUsers() async {
  // 🧪 Optional Debug: Print all included assets
  try {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    log("✅ Included Assets:", name: "AssetLoader");
    log(manifestMap.keys.toString(), name: "AssetLoader");
  } catch (e) {
    log("❌ Failed to load AssetManifest.json", name: "AssetLoader");
  }

  // 📂 Attempt to load the users.json file
  try {
    final String jsonString = await rootBundle.loadString('assets/data/users.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    if (jsonList.isEmpty) {
      throw Exception("No user data found in users.json");
    }

    return jsonList.map((item) => item as Map<String, dynamic>).toList();
  } catch (e, stackTrace) {
    log("🚨 Error loading users.json: $e\n$stackTrace", name: "AssetLoader");
    throw Exception("Failed to load users.json: $e");
  }
}

Future<List<Map<String, dynamic>>> loadEqubGroups() async {
  try {
    final String jsonString =
    await rootBundle.loadString('assets/data/equb_groups.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => item as Map<String, dynamic>).toList();
  } catch (e) {
    log("🚨 Error loading equb_groups.json: $e", name: "AssetLoader");
    throw Exception("Failed to load equb_groups.json: $e");
  }
}