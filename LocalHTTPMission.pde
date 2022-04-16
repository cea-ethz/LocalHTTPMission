import drop.*;
import test.*;

import java.io.File;
import java.net.NetworkInterface;
import java.nio.file.*;
import java.util.Enumeration;

import http.*;

import com.cage.zxing4p3.*;

ZXING4P zxing4p;

PImage  QRCode = null;;

SimpleHTTPServer server;

SDrop drop;

JSONObject json = null;

String localIp = "";
String missionName = "Drag a Mission JSON file onto this window";
int eventCount = 0;

void setup() {
  size(400, 300);
  // Create a server listening on port 8000
  // serving index.html,which is in the data folder
  server = new SimpleHTTPServer(this); 
  server.serve("mission.json");

  drop = new SDrop(this);
  
  zxing4p = new ZXING4P();

  NetworkInterface mainInterface = null;

  try {
    Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
    while (interfaces.hasMoreElements()) {
      NetworkInterface i = interfaces.nextElement();
      if (i.toString().contains("wlan1")) {
        mainInterface = i;
        break;
      }
    }
    localIp = mainInterface.getInterfaceAddresses().get(0).getAddress().toString();
    localIp = localIp.substring(1,localIp.length());
    
    QRCode = zxing4p.generateQRCode("http://" + localIp + ":8000/mission.json", 200, 200);
  }
  catch(Exception e) {
  }
}

public void draw() {
  background(255);
  fill(0);
  text("Server IP : " + localIp, 10, 20);
  text("Mission Name : " + missionName,10,40);
  text("Mission Has " + eventCount + " events",10,60);
  
  if (QRCode != null) {
     image(QRCode, (width / 2) - (QRCode.width / 2),height - QRCode.height); 
  }
}

void dropEvent(DropEvent dropEvent) {
  try {
    Path input = Paths.get(dropEvent.toString());
    Path output = Paths.get(dataPath("mission.json"));

    Files.copy(input, output, StandardCopyOption.REPLACE_EXISTING);
    json = loadJSONObject("mission.json");
    
    missionName = json.getString("mission_name");
    eventCount = json.getJSONArray("events").size();
  }
  catch(Exception e) {
    println(e);
  }
}
