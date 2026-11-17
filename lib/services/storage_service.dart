import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/picked_photo.dart';

/// Uploads photos to Cloudinary (free photo hosting).
// shortcut: photos a landlord removes stay on Cloudinary, because deleting needs a secret key that
// can't live in the app. Clean up from the Cloudinary website, or move deletes to a server later.
class StorageService {
  /// Uploads the new photos into [folder] and returns every photo's link, in the same order.
  /// Photos that are already uploaded keep their link.
  Future<List<String>> uploadAll(List<PickedPhoto> photos, String folder) {
    return Future.wait([
      for (final photo in photos)
        photo.isUploaded ? Future.value(photo.url!) : _upload(photo, folder),
    ]);
  }

  Future<String> _upload(PickedPhoto photo, String folder) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload'),
    )
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..fields['folder'] = folder
      ..files.add(http.MultipartFile.fromBytes('file', photo.bytes!, filename: 'photo.jpg'));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw Exception('Photo upload failed (${response.statusCode}): ${response.body}');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['secure_url'] as String;
  }
}
