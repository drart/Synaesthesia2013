import hypermedia.net.*;
import java.util.*; // Java Set<> and LinkedHashSet<>
import ddf.minim.*;

/// set variables to "" for recording or fill in with filenames for playback
String playbackdatafile = "";
String playbackwavefile = "";

Minim minim;
AudioInput in;
AudioRecorder recorder;
AudioPlayer player;

UDP udp;  
Set<String> ListOfIPs;
Table table;
color[][] colors = new color[64][48];
int index;
int playbackindex;
String filewritesuffix = month() + "-" + day() + "-" + hour() + "-"  + minute() + "-" + second();

void setup() 
{
  size(640, 480);
  frameRate(20);  
  noStroke();

  minim = new Minim(this);

  ListOfIPs = new LinkedHashSet();
  
  if (playbackdatafile.equals(""))
  {
    table = createTable();
    table.addColumn();
    table.addColumn();
    table.addColumn();
    String[] x = { "time", "time2", "ipaddress" };
    table.setColumnTitles( x );

    udp = new UDP( this, 9999 );
    //udp.log( true );     // <-- printout the connection activity
    udp.listen( true );
    
    in = minim.getLineIn();
    recorder = minim.createRecorder(in, "sound-" + filewritesuffix + ".wav", true);
    recorder.beginRecord();
  }
  else
  {
    table = loadTable(playbackdatafile, "header,tsv");
    player = minim.loadFile(playbackwavefile);
    player.play();
  }

  prepareExitHandler ();
}

void draw() 
{ 
  background(0);  
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
  
  int i = 1;
  for (String s : ListOfIPs )
  {
    fill(255);
    text (s, 30, i * height/numberOfIPs);
    i++;
  }
  
  if ( !playbackdatafile.equals("") )
    playback();
}

void stop()
{ 
  if ( playbackdatafile.equals("") )
  {
    saveTable(table, "data-" + filewritesuffix + ".txt", "tsv");
    recorder.endRecord();
    recorder.save();
  }
  
  super.stop();
}

void receive( byte[] data, String ip, int port ) 
{	
  String message = new String( data );

  TableRow newRow = table.addRow();
  newRow.setFloat( "time", millis()/1000.0 );
  newRow.setFloat( "time2", millis()/1000.0 );
  newRow.setString( "ipaddress", ip + "," + message ); 
  
  ListOfIPs.add(ip);
  int currentIPIndex = 0;
  int index = 0;
  for (String s : ListOfIPs )
  {
     if ( s.equals( ip ) )
        currentIPIndex = index; 
      index++;
  }

  String delims = "[,]";
  String[] tokens = message.split( delims );
  int[] cc = new int[3];
  for (int i = 0; i < tokens.length; i++)
  {
     cc[i] =  (int) ( 255 * Float.parseFloat( tokens[i] ) ); 
  } 
  
  colors[0][currentIPIndex] = color( cc[0], cc[1], cc[2] );

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

