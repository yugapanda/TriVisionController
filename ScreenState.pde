class ScreenState {

  OscP5 oscP5;

  ScreenState(OscP5 oscP5) {

    this.oscP5 = oscP5;
  }

  void getScreenMovieList(NetAddress sendAddress, int number) {

    String ipAddress = NetInfo.getHostAddress();

    println(ipAddress);

    OscMessage message = new OscMessage("/movieList");

    message.add(number);
    message.add(ipAddress);
    message.add(controllerPort);


    oscP5.send(message, sendAddress);
  }
}


class IdAndMovieNameList {

  int id;

  ArrayList<String> names;

  IdAndMovieNameList(int id, ArrayList<String> names) {
    this.id = id;
    this.names = names;
  }
}