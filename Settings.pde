
import java.util.Properties;
import java.io.FileInputStream;
import java.io.InputStream;

class Settings {


  ArrayList<IpPortNumber> getProp() {

    Properties properties = new Properties();

    String file = dataPath("settings.properties");
    ArrayList<IpPortNumber> ipn = new ArrayList<IpPortNumber>();


    try {
      InputStream inputStream = new FileInputStream(file);
      properties.load(inputStream);
      inputStream.close();

      ipn.add(new IpPortNumber(properties.getProperty("ip1"), int(properties.getProperty("port1")), 1));
      ipn.add(new IpPortNumber(properties.getProperty("ip2"), int(properties.getProperty("port2")), 2));
      ipn.add(new IpPortNumber(properties.getProperty("ip3"), int(properties.getProperty("port3")), 3));
    } 
    catch (Exception ex) {
      System.out.println(ex.getMessage());
    }
    
    return ipn;
  }
}

class IpPortNumber {

  String ip;
  int port;
  int number;

  IpPortNumber(String ip, int port, int number) {

    this.ip = ip;
    this.port = port;
    this.number = number;
  }
}