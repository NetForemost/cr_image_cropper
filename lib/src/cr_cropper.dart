import 'dart:io';

import 'package:cr_image_cropper/cr_image_cropper.dart';
import 'package:cr_image_cropper/src/pick_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

/// Cropper class that encapsulates image cropping logic.
/// If cropped image size is bigger than [maxSizeInBytes]
/// then [_compress] function is called.
class CrCropper {
  final imagePicker = ImagePicker();
  File? _croppedImage;

  /// Image cropping settings
  final AndroidUiSettings androidUiSettings;
  final IOSUiSettings iOSSettings;
  final CropAspectRatio? cropAspectRatio;
  final List<CropAspectRatioPreset> aspectRatioOptions;
  final CropStyle cropStyle;
  final ImageCompressFormat compressFormat;
  final int cropCompressQuality;
  final int maxHeight;
  final int maxWidth;

  /// Image compression settings
  final double? maxSizeInMB;
  late int maxSizeInBytes;
  final int compressionStep;

  CrCropper({
    required this.androidUiSettings,
    required this.iOSSettings,
    this.maxHeight = 2000,
    this.maxWidth = 2000,
    this.cropCompressQuality = 90,
    this.cropAspectRatio,
    this.aspectRatioOptions = const [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
    this.cropStyle = CropStyle.rectangle,
    this.compressFormat = ImageCompressFormat.jpg,
    this.maxSizeInMB,
    this.compressionStep = 10,
  }) {
    if (maxSizeInMB != null) {
      /// default value 10 MB
      maxSizeInBytes = (maxSizeInMB! * 1000000).toInt();
    } else {
      maxSizeInBytes = 10 * 1000000;
    }
  }

  /// [fullMetadataImagePicker] - Image picker plugin can request full metadata
  /// for media files (e.g. location). Defaults to false. If true, on iOS will
  /// ask for permission to access photo gallery.
  ///
  /// [useFilePicker] - use file picker for picking images and videos.
  /// on Android requires files permission on some Android versions,
  /// on iOS does not require permission.
  ///
  /// [allowFilePickerCompression] - file picker plugin can apply automatic
  /// compression for media files. Useful for picking iOS video and images
  /// in iOS specific format, compression will convert this files to more
  /// appropriate formats for all platforms.
  Future<File?> pickAndCropImage(
    ImageSource source, {
    bool fullMetadataImagePicker = false,
    bool useFilePicker = false,
    bool allowFilePickerCompression = true,
  }) async {
    if (useFilePicker && source == ImageSource.gallery) {
      return _pickFromFilePicker(
        allowCompression: allowFilePickerCompression,
      );
    }
    final image = await imagePicker.pickImage(
      source: source,
      requestFullMetadata: fullMetadataImagePicker,
    );
    if (image != null) {
      return cropImageAndMaybeCompress(image.path);
    }

    return null;
  }

  /// Pick image from Gallery and crop.
  ///
  /// We use [ImagePicker] inside [pickAndCropImage].
  /// Since we noticed that [ImagePicker] do not work correctly on iOS when we
  /// want to pick photo from gallery we decide to use [FilePicker] instead.
  Future<File?> _pickFromFilePicker({bool allowCompression = true}) async {
    final platformFile = await pickFile(
      type: FileType.image,
      allowCompression: allowCompression,
    );

    final filePath = platformFile?.path;
    if (filePath == null) {
      return null;
    }

    return cropImageAndMaybeCompress(filePath);
  }

  Future<File?> cropImageAndMaybeCompress(String imagePath) async {
    _croppedImage = await _crop(imagePath);
    if (_croppedImage == null) {
      return null;
    } else {
      final croppedSize = await _croppedImage!.length();
      if (croppedSize <= maxSizeInBytes) {
        return _croppedImage;
      } else {
        return compressImage(_croppedImage!);
      }
    }
  }

  /// Crops [image] file using native image cropper on Android and iOS
  Future<File?> _crop(String imagePath) => ImageCropper()
          .cropImage(
        aspectRatio: cropAspectRatio,
        sourcePath: imagePath,
        uiSettings: [androidUiSettings, iOSSettings],
        aspectRatioPresets: aspectRatioOptions,
        cropStyle: cropStyle,
        compressQuality: cropCompressQuality,
        compressFormat: compressFormat,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
      )
          .then((croppedFile) {
        final path = croppedFile?.path;
        if (path != null) {
          return File(path);
        }

        return null;
      });

  /// If [image.length] > [maxSizeInBytes] then [compressImage] is called
  /// Using [compressionStep] function compresses [image] till it's
  /// size will be smaller than [maxSizeInBytes].
  Future<File?> compressImage(File image) async {
    File? compressed;
    var quality = 100 - compressionStep;
    do {
      compressed = await FlutterNativeImage.compressImage(
        image.path,
        quality: quality,
        percentage: 100,
      );
      quality = quality - compressionStep;
    } while (((compressed.lengthSync()) > maxSizeInBytes));
    return compressed;
  }
}
