//import hypermedia.net.*;

import ddf.minim.*;

Minim minim;
AudioInput in;
AudioRecorder recorder;

UDP udp;  
HashMap ListOfIPs;
Table table;
color[][] colors = new color[64][48];
int index;

/*TODO*/
// decode string to color -- put it in the right part of the array
String playbackdatafile = "";
String playbackwavefile = "";

void setup() 
{
  size(640, 480);
  frameRate(30);  
  noStroke();

  minim = new Minim(this);
  in = minim.getLineIn();
  recorder = minim.createRecorder(in, "myrecording" + month() + "-" + day() + "-" + hour() + "-"  + minute() + "-" + second() + ".wav", true);

  ListOfIPs = new HashMap();

  if (true)
  {
    table = createTable();
    table.addColumn();
    table.addColumn();
    table.addColumn();
    String[] x = {
      "time", "time2", "ipaddress"
    } 
    ;
    table.setColumnTitles( x );

    udp = new UDP( this, 6000 );
    //udp.log( true );     // <-- printout the connection activity
    udp.listen( true );
  }
  else
  {
    table = loadTable(playbackdatafile, "tsv");
  }

  prepareExitHandler ();
  recorder.beginRecord();

  /*//------------  
   // TESTS
   ListOfIPs.put("1.1.1.1", "fadfkjkl");
   ListOfIPs.put("1.1.1.1", "fadfkjkl");
   colors[0][0] = color(random(255),random(255),random(255)); 
   */
}

void draw() 
{ 
  background(0);  
  //int numberOfIPs = max(ListOfIPs.size(),1);
  int numberOfIPs = ListOfIPs.size();

  for ( int i = 0; i < colors.length; i++)
  {
    for ( int j = 0; j < numberOfIPs; j++)
    {
      fill(colors[i][j]);
      rect(width-10-(i*10), j * height/numberOfIPs, 10, height/numberOfIPs);
    }
  }
  // shift the color registers over to simulate scrolling
  for ( int i = colors.length-1; i > 0; i--)
  {
    for ( int j = 0; j < colors[0].length; j++)
    {
      colors[i][j] = colors[i-1][j];
    }
  }
}

void stop()
{  
  saveTable(table, "data-" + month() + "-" + day() + "-" + hour() + "-"  + minute() + "-" + second() + ".txt", "tsv");
  recorder.endRecord();
  recorder.save();
  super.stop();
}

/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
void receive( byte[] data, String ip, int port ) 
{	
  String message = new String( data );

  TableRow newRow = table.addRow();
  newRow.setFloat( "time", millis()/1000.0 );
  newRow.setFloat( "time2", millis()/1000.0 );
  newRow.setString( "ipaddress", ip + "," + message ); 

  if ( null == ListOfIPs.get(ip) )
  {
    ListOfIPs.put(ip, message);
  }  

  String delims = "[,]";
  String[] tokens = message.split(delims);
  for (int i = 0; i < tokens.length; i++)
  {
    println(tokens[i]);
    int cc =  (int) ( 255 * Float.parseFloat( tokens[i] ) ); 
    println(cc);
  } 

  println( "receive: \"" + message+ "\" from " + ip + " on port " + port );
}

//https://forum.processing.org/topic/run-code-on-exit
// must add "prepareExitHandler();" in setup() for Processing sketches 
private void prepareExitHandler () 
{
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () {
      //System.out.println("SHUTDOWN HOOK");
      try {
        stop();
      } 
      catch (Exception ex) {
        ex.printStackTrace(); // not much else to do at this point
      }
    }
  }
  ));
}   

/// SOME TESTS
void keyPressed()
{
  String example = "0.12,0.111,0.3123";
  byte[] bytes = example.getBytes();

  if (key == 'r')
  { 
    receive(bytes, "1.1.1.10", 5894);
  }
}

