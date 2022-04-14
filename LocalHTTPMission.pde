import drop.*;
import test.*;

import java.io.File;
import java.net.NetworkInterface;
import java.nio.file.*;
import java.util.Enumeration;

import http.*;

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
