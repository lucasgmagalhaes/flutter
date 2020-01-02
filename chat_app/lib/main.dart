import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

final googleSignIn = GoogleSignIn();
final auth = FirebaseAuth.instance;

_ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null || (user = await googleSignIn.signInSilently()) == null) {
    user = await googleSignIn.signIn();
    if (await auth.currentUser() == null) {
      GoogleSignInAuthentication credentials =
          await googleSignIn.currentUser.authentication;
      await auth.signInWithCredential(GoogleAuthProvider.getCredential(
          idToken: credentials.idToken, accessToken: credentials.accessToken));
    }
  }
}

_handleSubmit(String text) async {
  await _ensureLoggedIn();
  _sendMessage(message: text);
}

_sendMessage({String message, String imgUrl}) {
  Firestore.instance.collection("messages").add({
    "text": message,
    "imageUrl": imgUrl,
    "senderName": googleSignIn.currentUser.displayName,
    "senderPhotoUrl": googleSignIn.currentUser.photoUrl
  });
}

class MyApp extends StatelessWidget {
  final ThemeData kIOSTheme = ThemeData(
      primarySwatch: Colors.orange,
      primaryColor: Colors.grey[100],
      primaryColorBrightness: Brightness.light);

  final ThemeData kDefaultTheme = ThemeData(
      primarySwatch: Colors.purple, accentColor: Colors.orangeAccent[400]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).platform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    String getSnapshotData(String dataName, dynamic snapshot, index) {
      return snapshot.data.documents[index].data[dataName];
    }

    return SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Chat App'),
            centerTitle: true,
            elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0 : 4,
          ),
          body: Column(children: <Widget>[
            Expanded(
                child: StreamBuilder(
              stream: Firestore.instance.collection("messages").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.none ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return ChatMessage(Message(
                          getSnapshotData('text', snapshot, index),
                          getSnapshotData('imageUrl', snapshot, index),
                          getSnapshotData('senderName', snapshot, index),
                          getSnapshotData('senderPhotoUrl', snapshot, index)));
                    });
              },
            )),
            Divider(
              height: 1,
            ),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: TextComposer(),
            )
          ]),
        ));
  }
}

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;
  final TextEditingController _controller = TextEditingController();

  _reset() {
    setState(() {
      _controller.clear();
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200])))
              : null,
          child: Row(
            children: <Widget>[
              Container(
                  child: IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: () async {
                  await _ensureLoggedIn();
                  File imgFile =
                      await ImagePicker.pickImage(source: ImageSource.camera);
                  if (imgFile == null) return;
                  StorageUploadTask task = FirebaseStorage.instance
                      .ref()
                      .child(googleSignIn.currentUser.id.toString() +
                          DateTime.now().millisecondsSinceEpoch.toString())
                      .putFile(imgFile);
                  StorageTaskSnapshot taskSnapshot = await task.onComplete;
                  String url = await taskSnapshot.ref.getDownloadURL();
                  _sendMessage(imgUrl: url);
                },
              )),
              Expanded(
                  child: TextField(
                controller: _controller,
                decoration:
                    InputDecoration.collapsed(hintText: 'Send a message'),
                onChanged: (text) {
                  setState(() {
                    this._isComposing = text.length > 0;
                  });
                },
                onSubmitted: (text) {
                  _handleSubmit(text);
                  _reset();
                },
              )),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? CupertinoButton(
                          child: Text('Send'),
                          onPressed: this._isComposing
                              ? () {
                                  _handleSubmit(_controller.text);
                                  _reset();
                                }
                              : null,
                        )
                      : IconButton(
                          icon: Icon(Icons.send),
                          onPressed: this._isComposing
                              ? () {
                                  _handleSubmit(_controller.text);
                                  _reset();
                                }
                              : null,
                        )),
            ],
          ),
        ));
  }
}

class Message {
  String text;
  String imageUrl;
  String senderName;
  String senderPhotoUrl;
  Message(this.text, this.imageUrl, this.senderName, this.senderPhotoUrl);
}

class ChatMessage extends StatelessWidget {
  final Message message;

  ChatMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(message.senderPhotoUrl),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(message.senderName,
                    style: Theme.of(context).textTheme.subhead),
                Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: message.imageUrl != null
                        ? Image.network(message.imageUrl, width: 250)
                        : Text(this.message.text))
              ],
            ),
          )
        ],
      ),
    );
  }
}
