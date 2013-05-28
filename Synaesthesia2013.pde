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
// lerpcolor through array when added

void setup() 
{
  size(640,480);
  frameRate(30);  
  noStroke();

  minim = new Minim(this);

  in = minim.getLineIn();
  // create a recorder that will record from the input to the filename specified, using buffered recording
  // buffered recording means that all captured audio will be written into a sample buffer
  // then when save() is called, the contents of the buffer will actually be written to a file
  // the file will be located in the sketch's root folder.
  recorder = minim.createRecorder(in, "myrecording.wav", true);

  ListOfIPs = new HashMap();
  
  if (true)
  {
    table = createTable();
    table.addColumn();
    table.addColumn();
    String[] x ={"time","ipaddress"} ;
    table.setColumnTitles( x );
    
    udp = new UDP( this, 6000 );
    //udp.log( true );     // <-- printout the connection activity
    udp.listen( true );
  }
  else
  {
     table = loadTable("SOMESTRING", "tsv");
  }
  
  prepareExitHandler ();
  recorder.beginRecord();
  colors[0][0] = color(random(255),random(255),random(255)); 
}



void draw() 
{ 
  background(0);
  
  fill( colors[0][0] );
  int numberOfIPs = max(ListOfIPs.size(),1);
  
  /*
  for (int i = 0; i < numberOfIPs; i++)
  {
      rect(width-(frameCount%width),0, 10,height/numberOfIPs);    
  }
  */
  
  for ( int i = 0; i < colors.length; i++)
  {
    fill(colors[i][0]); /// change to index and j counter
    rect(width-10-(i*10), 0, 10, height/numberOfIPs);
  }
}

void stop()
{  
    /// test write
    TableRow newRow = table.addRow();
    newRow.setInt("time", millis() );
    newRow.setString("ipaddress", "test" ); 
    
    saveTable(table, "data.txt", "tsv");
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
// void receive( byte[] data ) { 			// <-- default handler
void receive( byte[] data, String ip, int port ) {	// <-- extended handler
  
  
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  //data = subset(data, 0, data.length-2);
  String message = new String( data );
  
   TableRow newRow = table.addRow();
   newRow.setString(null, ip );
   newRow.setInt(null, millis() ); 
  
  if( null != ListOfIPs.get(ip) )
  { 
      ListOfIPs.put(ip,message);
         
  }  
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
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
        } catch (Exception ex){
          ex.printStackTrace(); // not much else to do at this point
        }
              
      }
    }));
}   



