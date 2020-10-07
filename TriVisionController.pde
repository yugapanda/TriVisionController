import netP5.*;
import oscP5.*;

import java.net.InetAddress;

OscP5 oscP5;

int controllerPort = 12000;

ScreenState SS;

ArrayList<String> titles = new ArrayList<String>();
char[] keys = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
ArrayList<Boolean> play = new ArrayList<Boolean>();
ArrayList<IdAndMovieNameList> idAndMovieNameList = new ArrayList<IdAndMovieNameList>();
ArrayList<IpPortNumber> ipns;
int playNumber = -1;
Settings settings = new Settings();
float duration = 0;
float DURATION_ALL = 600;

void setup() {

  size(800, 800);

  oscP5 = new OscP5(this, controllerPort);

  SS = new ScreenState(oscP5);
  ipns = settings.getProp();
}


void draw() {

  background(0);
  
  stroke(255);
  noFill();
  rect(100, height - 100, DURATION_ALL,25);
  fill(255,0,0);
  noStroke();
  rect(100, height - 100, duration,25);



  for (IpPortNumber ipn : ipns) {

    text(ipn.number + "ip: " + ipn.ip + " port: " + ipn.port, width - 200, 50 + ipn.number * 50);
  }

  for (int i = 0; i<play.size(); i++) {

    fill(255, 255, 255);
    text(titles.get(i), 50, 35*i + 55);
    if (play.get(i)) {
      fill(255, 0, 0);
    } else {
      fill(255, 255, 255);
    }
    ellipse(25, 35*i + 50, 25, 25);
  }
  /*
  for (int idx = 0; idx < idAndMovieNameList.size(); idx++) {
   
   IdAndMovieNameList idAndMovie = idAndMovieNameList.get(idx);
   
   for (int idxMovie = 0; idxMovie < idAndMovie.names.size(); idxMovie++) {
   
   String name = idAndMovie.names.get(idxMovie);
   
   text(name, 50 + idx * 200, 50 + idxMovie * 50);
   }
   }
   */
}

private void playScene(int scene) {

  for (int i = 0; i<play.size(); i++) {


    if (scene == i && play.get(i) == false && play.size() > i) {

      OscMessage message = new OscMessage("/start");
      message.add(i);
      for (IpPortNumber ipn : ipns) {
        oscP5.send(message, new NetAddress(ipn.ip, ipn.port));
      }
      play.set(i, true);
    } else if (scene != i) {

      OscMessage message = new OscMessage("/end");
      message.add(i);
      for (IpPortNumber ipn : ipns) {
        oscP5.send(message, new NetAddress(ipn.ip, ipn.port));
      }
      play.set(i, false);
    }
  }
}


void keyPressed() {

  switch(key) {

  case 'l':
    //受信したときに再生indexを0に戻す
    playNumber = -1;
    // 各portにメッセージを送って動画のリストを取得
    for (IpPortNumber ipn : ipns) {
      println("ip: " + ipn.ip + "port: " + ipn.port);
      SS.getScreenMovieList(new NetAddress(ipn.ip, ipn.port), ipn.number);
    }
    break;

  case ' ':
    //スペースを押すと次の動画へ

    if (playNumber < play.size()) {
      playNumber++;
    }
    playScene(playNumber);
    break;


  case '0':
    // 0を押すと最初に戻る

    playNumber = -1;

    break;

  case 'e':

    // eを押すと終了
    playScene(-1);
    break;
    
    //cを押すとカメラの映像に切り替え

  case 'c':

    OscMessage message = new OscMessage("/camera");
    message.add(true);
    for (IpPortNumber ipn : ipns) {
      oscP5.send(message, new NetAddress(ipn.ip, ipn.port));
    }
    break;
  }
}



/**
 OSCから返事を受け取る
 */
void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/progress")) {
    float nowTime =  theOscMessage.get(0).floatValue();
    float allTime =  theOscMessage.get(1).floatValue();
    
    duration = (nowTime / allTime) * DURATION_ALL;
    println(nowTime);
    println(allTime);
    println(duration);
    
  }

  if (theOscMessage.checkAddrPattern("/movieList")) {



    int number = theOscMessage.get(0).intValue();
    Object[] args = theOscMessage.arguments();

    ArrayList<String> nameList = new ArrayList<String>();


    //名前のリストを構築
    for (int idx = 1; idx < args.length; idx++) {
      nameList.add((String)args[idx]);
    }
    //ナンバーと同じidがあれば削除
    for (int idx = 0; idx <idAndMovieNameList.size(); idx++) {

      if (idAndMovieNameList.get(idx).id == number) {
        idAndMovieNameList.remove(idx);
      }
    }

    idAndMovieNameList.add(new IdAndMovieNameList(number, nameList));

    play.clear();

    //playフラグを作る
    for (int idx = 1; idx < args.length; idx ++) {

      play.add(false);
    }

    titles.clear();

    for (String name : nameList) {
      titles.add(name);
    }
  }
}