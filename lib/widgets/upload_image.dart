import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';

import 'constants.dart';
import 'custom_dialog.dart';
import 'dashboard.dart';

enum PhotoStatus { LOADING, ERROR, LOADED }
enum PhotoSource { FILE, NETWORK }

class ImagePickerWidget extends StatefulWidget {
  final String mobilenumber;
  final String password;
  ImagePickerWidget(this.mobilenumber, this.password);
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  int imag = 0;
  List<File> _photos = List<File>();
  List<String> _photosUrls = List<String>();
  SharedPreferences prefs;
  List<PhotoStatus> _photosStatus = List<PhotoStatus>();
  List<PhotoSource> _photosSources = List<PhotoSource>();
  List<GalleryItem> _galleryItems = List<GalleryItem>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              child: (Text(
            imag.toString() + '/5',
            style: TextStyle(fontSize: 18),
          ))),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddPhoto();
                }
                File image = _photos[index - 1];
                PhotoSource source = _photosSources[index - 1];
                return Stack(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.all(5),
                        height: 100,
                        width: 100,
                        color: kLightGray,
                        child: source == PhotoSource.FILE
                            ? Image.file(image)
                            : Image.network(_photosUrls[index - 1]),
                      ),
                    ),
                    Visibility(
                      visible: _photosStatus[index - 1] == PhotoStatus.LOADING,
                      child: Positioned.fill(
                        child: SpinKitWave(
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _photosStatus[index - 1] == PhotoStatus.ERROR,
                      child: Positioned.fill(
                        child: Icon(
                          Icons.error,
                          color: kErrorRed,
                          size: 35,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        padding: EdgeInsets.all(6),
                        alignment: Alignment.topRight,
                        child: DeleteWidget(
                          () => _onDeleteReviewPhotoClicked(index - 1),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(16),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              color: kOverallColor,
              child: Text('Login'),
              onPressed: () {
                if (_photosUrls.length > 0) {
                  imageCheck(context, this.widget.mobilenumber,
                      this.widget.password, _photosUrls, true);
                } else {
                  Toast.show('No image uploaded', context,
                      duration: Toast.LENGTH_LONG,
                      gravity: Toast.BOTTOM,
                      textColor: Colors.black,
                      backgroundColor: Colors.red[300]);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  imageCheck(BuildContext context, String mobile, String password, List url,
      bool upload) async {
    try {
      Response response = await put(
        kUrl + '/imageuploadcheck',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'imageuploaded': upload.toString()
        },
        body: jsonEncode(
            <String, dynamic>{'mobilenumber': mobile, 'imageurl': url}),
      ).timeout(const Duration(seconds: 10));
      String body = response.body;
      print(response.body);

      String status = json.decode(body)['message'];
      print(status);
      if (response.statusCode == 200) {
        loginMerchant(context, mobile, password);
      } else {
        Toast.show(
          "Some error occurred",
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.red[200],
        );
      }

      //call saving keys function

      print(body);
    } on TimeoutException catch (_) {
      Toast.show(
        "Check your internet connection",
        context,
        duration: 3,
        gravity: Toast.BOTTOM,
        textColor: Colors.black,
        backgroundColor: Colors.red[200],
      );
    } on SocketException catch (_) {
      Toast.show(
        "Check your internet connection",
        context,
        duration: 3,
        gravity: Toast.BOTTOM,
        textColor: Colors.black,
        backgroundColor: Colors.red[200],
      );
    }
  }

  loginMerchant(BuildContext context, String mobile, String password) async {
    try {
      Response response = await post(
        kUrl + '/merchantlogin',
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'mobilenumber': mobile,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));
      String body = response.body;
      String status = json.decode(body)['message'];
      print(status);
      if (status == 'successful login') {
        Toast.show(
          "Login Successful",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.green[200],
        );
        save(json.decode(body)['data']['merchantid']);
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          });
        });
      } else {
        Toast.show(
          "Icorrect username/password",
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.red[200],
        );
      }

      //call saving keys function

      print(body);
    } on TimeoutException catch (_) {
      Toast.show(
        "Check your internet connection",
        context,
        duration: 3,
        gravity: Toast.BOTTOM,
        textColor: Colors.black,
        backgroundColor: Colors.red[200],
      );
    } on SocketException catch (_) {
      Toast.show(
        "Check your internet connection",
        context,
        duration: 3,
        gravity: Toast.BOTTOM,
        textColor: Colors.black,
        backgroundColor: Colors.red[200],
      );
    }
  }

  void save(String merchantid) async {
    print(merchantid);
    print('hi');
    prefs = await SharedPreferences.getInstance(); //get instance of app memory
    final merchantkey = 'merchantid';
    //save keys in memory
    prefs.setString(merchantkey, merchantid);
    print(prefs.getString(merchantkey));
  }

  Future<bool> _onDeleteReviewPhotoClicked(int index) async {
    if (_photosStatus[index] == PhotoStatus.LOADED) {
      _photosUrls.removeAt(index);
    }
    _photos.removeAt(index);
    _photosStatus.removeAt(index);
    _photosSources.removeAt(index);
    _galleryItems.removeAt(index);
    setState(() {
      if (imag > 0) {
        imag -= 1;
      }
    });
    return true;
  }

  _buildAddPhoto() {
    return InkWell(
      onTap: () {
        if (imag < 5) {
          _onAddPhotoClicked(context);
        } else {
          Toast.show(
            "You have uploaded maximum pictures",
            context,
            duration: 3,
            gravity: Toast.BOTTOM,
            textColor: Colors.black,
            backgroundColor: Colors.red[200],
          );
        }
      },
      child: Container(
        margin: EdgeInsets.all(5),
        height: 100,
        width: 100,
        color: kDarkGray,
        child: Center(
          child: Icon(
            Icons.add_to_photos,
            color: kLightGray,
          ),
        ),
      ),
    );
  }

  _onAddPhotoClicked(context) async {
    Permission permission;

    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }

    PermissionStatus permissionStatus = await permission.status;
    print(permissionStatus);

    if (permissionStatus == PermissionStatus.restricted) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.permanentlyDenied) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.undetermined) {
      permissionStatus = await permission.request();

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.denied) {
      if (Platform.isIOS) {
        _showOpenAppSettingsDialog(context);
      } else {
        permissionStatus = await permission.request();
      }

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.granted) {
      print('Permission granted');
      File image = await ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);

      if (image != null) {
        int length;
        length = _photos.length + 1;
        String fileName = path.basename(image.path);
        String fileExtension = path.extension(image.path);

        _galleryItems.add(
          GalleryItem(
            id: Uuid().v1(),
            resource: image.path,
          ),
        );

        setState(() {
          _photos.add(image);
          _photosStatus.add(PhotoStatus.LOADING);
          _photosSources.add(PhotoSource.FILE);
        });
        String key = this.widget.mobilenumber + '/' + fileName;
        try {
          GenerateImageUrl generateImageUrl = GenerateImageUrl();
          await generateImageUrl.call(fileExtension, key);

          String uploadUrl;
          if (generateImageUrl.isGenerated != null &&
              generateImageUrl.isGenerated) {
            uploadUrl = generateImageUrl.uploadUrl;
          } else {
            throw generateImageUrl.message;
          }

          bool isUploaded = await uploadFile(context, uploadUrl, image);
          if (isUploaded) {
            setState(() {
              imag += 1;
              _photosUrls.add(generateImageUrl.downloadUrl);
              _photosStatus
                  .replaceRange(length - 1, length, [PhotoStatus.LOADED]);
            });
          }
        } catch (e) {
          print(e);
          setState(() {
            _photosStatus[length - 1] = PhotoStatus.ERROR;
          });
        }
      }
    }
  }

  Future<bool> uploadFile(context, String url, File image) async {
    try {
      UploadFile uploadFile = UploadFile();
      await uploadFile.call(url, image);

      if (uploadFile.isUploaded != null && uploadFile.isUploaded) {
        return true;
      } else {
        throw uploadFile.message;
      }
    } catch (e) {
      throw e;
    }
  }

  _showOpenAppSettingsDialog(context) {
    return CustomDialog.show(
      context,
      'Permission needed',
      'Photos permission is needed to select photos',
      'Open settings',
      openAppSettings,
    );
  }
}

class GalleryItem {
  GalleryItem({this.id, this.resource});

  final String id;
  String resource;
}

class GenerateImageUrl {
  bool success;
  String message;

  bool isGenerated;
  String uploadUrl;
  String downloadUrl;

  Future<void> call(String fileType, String key) async {
    try {
      var response = await post(
        kUrl + '/imageupload',
        headers: {
          'key': key,
          fileType: fileType,
        },
      );

      var result = jsonDecode(response.body);

      print(result);

      if (result['success'] != null) {
        success = result['success'];
        message = result['message'];

        if (response.statusCode == 201) {
          isGenerated = true;
          uploadUrl = result["uploadUrl"];
          downloadUrl = result["downloadUrl"];
        }
      }
    } catch (e) {
      throw ('Error getting url');
    }
  }
}

class UploadFile {
  bool success;
  String message;

  bool isUploaded;

  Future<void> call(String url, File image) async {
    try {
      var response = await put(url, body: image.readAsBytesSync());
      if (response.statusCode == 200) {
        isUploaded = true;
      }
    } catch (e) {
      throw ('Error uploading photo');
    }
  }
}

typedef Future<bool> OnDeleteClicked();

class DeleteWidget extends StatefulWidget {
  final OnDeleteClicked onDeleteClicked;

  DeleteWidget(this.onDeleteClicked);

  @override
  _DeleteWidgetState createState() => _DeleteWidgetState();
}

class _DeleteWidgetState extends State<DeleteWidget> {
  bool isDeleting = false;

  void stopDeleting() {
    setState(() {
      isDeleting = false;
    });
  }

  void startDeleting() {
    setState(() {
      isDeleting = true;
    });
  }

  _onDeleteWidgetClicked() async {
    print('DELETING');
    startDeleting();

    bool isDeleted = await widget.onDeleteClicked();

    stopDeleting();
    print('DELETED');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onDeleteWidgetClicked,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Visibility(
            visible: isDeleting,
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.redAccent),
                strokeWidth: 4.0,
              ),
            ),
          ),
          Visibility(
            visible: isDeleting == false,
            child: Icon(
              Icons.delete,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
