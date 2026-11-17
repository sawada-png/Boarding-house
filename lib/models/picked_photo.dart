import 'dart:typed_data';

/// A photo in a form: either already uploaded ([url]) or just picked and not uploaded yet ([bytes]).
class PickedPhoto {
  const PickedPhoto.uploaded(String this.url)
      : bytes = null,
        mimeType = null;

  const PickedPhoto.local(Uint8List this.bytes, {this.mimeType})
      : url = null;

  final String? url;
  final Uint8List? bytes;
  final String? mimeType;

  bool get isUploaded => url != null;
}
