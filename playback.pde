void received( String ip ) 
{  
  String delims = "[,]";
  String[] tokens = ip.split( delims );
  int[] cc = new int[3];
  for (int i = 1; i < tokens.length; i++)
  {
     cc[i-1] =  (int) ( 255 * Float.parseFloat( tokens[i] ) ); 
  } 
  
  ListOfIPs.add( tokens[0] ); // playback stores ip in list
  int currentIPIndex = 0;
  int index = 0;
  for (String s : ListOfIPs )
  {
     if ( s.equals( tokens[0] ) )
        currentIPIndex = index; 
      index++;
  }
  println(ListOfIPs.size() + " " + currentIPIndex );

  colors[0][currentIPIndex] = color( cc[0], cc[1], cc[2] );

  println( "receive: \"" + ip + "\"" );
}

void playback()
{
   if (playbackindex < table.getRowCount() )
   {
     TableRow r = table.getRow(playbackindex);
     float labeltime = r.getFloat("time") * 1000.0; // convert seconds to milliseconds
     r.getFloat("time2");
     String message = r.getString("ipaddress"); // ipaddress stored with colors
     
     if ( labeltime < millis() )
     {
       received(message); 
       playbackindex++;
       playback();   
     }
   }
}


/// SOME TESTS
/*
void keyPressed()
{
  String example = "0.12,0.111,0.3123";
  byte[] bytes = example.getBytes();

  if (key == 'r')
  { 
    receive(bytes, "1.1.1.1001912", 5894);
  }
}
*/
