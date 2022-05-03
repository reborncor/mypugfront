import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../components/design/design.dart';
import '../../models/MessageModel.dart';
import '../../response/conversationresponse.dart';
import '../../response/oldmessageresponse.dart';
import '../../util/util.dart';
import 'api.dart';

class Chat extends StatefulWidget {

  final routeName = '/chat';
  String receiverUsername = "";

  Chat({Key? key}) : super(key: key);

  Chat.withUsername({Key? key, required this.receiverUsername}) : super(key: key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late IO.Socket socket;
  late ConversationResponse response;
  late OldMessageResponse responseOldMessage;
  List<MessageModel> messages = [];
  TextEditingController messageToSend = TextEditingController();
  late String username;
  StreamController streamController = StreamController();
  late ScrollController scrollController;
  late MessageModel messageSent;
  late MessageModel newMessage;
  late int startInd;
  late int endInd;
  late ThemeModel themeNotifier;


  scrollListener(){
    // log("POSITION : "+scrollController.position.toString());
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        log("reach the bottom");
      });
    }
    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {
      fetchOldMessage();
      setState(() {
        log("reach the top");
      });
    }

  }
  goUp(){
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  goDown(){
    if(scrollController.hasClients){
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }
  }




  @override
  initState()  {
    startInd = 10;
    endInd = startInd+ 10;
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
    fetchUsername();
    fetchData();

    init();

    super.initState();

  }
  fetchUsername() async {
    username = await getCurrentUsername();
  }

  fetchOldMessage() async {
    var data = await getUserMessagePageable(widget.receiverUsername, startInd, endInd);
    responseOldMessage = data;
    messages.insertAll(0, responseOldMessage.oldmessages);
    startInd+=10;
    endInd+=10;
    streamController.add("event");
  }

  fetchData() async{
    var data = await getUserConversation(widget.receiverUsername);
    response = data;
    messages = response.conversation.chat;
    streamController.add(data);
  }
  addMessageToList(MessageModel messageModel){
    messages.add(messageModel);
    streamController.add("ok");
    goDown();
  }

  @override
  void dispose() {

    // socket.disconnect();
    // streamController.close();
    super.dispose();

  }
  init(){


    socket = socketService.getSocket();
    socket.on("messagesuccess",(data) => {
      log("Nouveau message"),
      if(data == "0"){
        addMessageToList(messageSent),
      }
      else{
        //TODO: Unsend message
      }

    });

    socket.on("instantmessage",(data) =>  {
      if(!mounted) print("NOT MOUNTED"),
      log("OK Instant Message"),
      newMessage = MessageModel.fromJsonData(data),
      addMessageToList(newMessage),

    });

  }

  sendMessage(String message){
    messageSent = MessageModel(time: "",content: message, senderUsername: username ,receiverUsername: widget.receiverUsername, id: "");
    socket.emit("message",messageSent.toJson());

  }


  Widget messageEditor(){
    return Row(
      children: <Widget>[
        Expanded(
            child: TextField(
              // style: TextStyle(color: themeNotifier.isDark ? Colors.white : Colors.black),
              controller: messageToSend,
              decoration: InputDecoration(
                suffixIcon: IconButton(onPressed: () {
                  sendMessage(messageToSend.text);
                  messageToSend.clear();
                }, icon: Icon(Icons.send, color : APPCOLOR)),
                enabledBorder: setOutlineBorder(1.5, 10.0, ),
                focusedBorder: setOutlineBorder(1.5, 10.0, ),
                border: setOutlineBorder(1.5, 10.0, ),
              ),

              onTap: (){
                goDown();
              },
            )),

      ],
    );
  }
  Widget itemMessage(MessageModel messageModel){
    return Padding(padding: EdgeInsets.all(8),
        child : Align(
            alignment:(messageModel.senderUsername == username) ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  minWidth: 100,
                  maxWidth: 300
              ),
              child: (messageModel.senderUsername != username) ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Image( image : AssetImage('asset/images/user.png',), width: 30, height: 30,),
                  Flexible(child: Card(
                    color: (messageModel.senderUsername == username) ? Colors.indigo[50] : Colors.white70 ,
                    child: Padding(child : Text(messageModel.content, style: TextStyle(color: themeNotifier.isDark ? Colors.black : Colors.black),), padding: const EdgeInsets.all(8),),),)
                ],
              ) :Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[

                  Flexible(child: Card(
                    color: (messageModel.senderUsername == username) ? Colors.indigo[50] : Colors.white70 ,
                    child: Container(
                      child:Padding(child : Text(messageModel.content, style: TextStyle(color: themeNotifier.isDark ? Colors.black : Colors.black)), padding: EdgeInsets.all(8),) ,
                    ),),)
                  ,
                  Image( image : AssetImage('asset/images/user.png',), width: 40, height: 40,),
                ],
              ),

            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {

        return Consumer<ThemeModel>(builder: (context,ThemeModel themeNotifier, child) {
          this.themeNotifier = themeNotifier;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: APPCOLOR ,

              title: Text(widget.receiverUsername),

            ),
            body: Container(decoration: BoxGradient(),
            child: Padding(padding: EdgeInsets.all(3), child: Container(child: StreamBuilder(
              stream: streamController.stream,
              builder: (context, snapshot) {
                if(snapshot.hasData){

                  return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child:ListView.builder(
                            reverse: false,
                            controller: scrollController,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,

                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return itemMessage(messages[index]);
                            },
                          ),),

                        Expanded(flex: 0,child: messageEditor())]

                  );
                }
                else{
                  return Center(

                      child: CircularProgressIndicator(color: APPCOLOR,)
                  );
                }
              },


            ),decoration: BoxCircular(themeNotifier),),),)

          );
        },);


  }

}

