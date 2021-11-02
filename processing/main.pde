import mqtt.*;
import java.nio.charset.StandardCharsets;
int pausa_messaggio=1000;
byte [] stringa=null;
boolean scorri=true;
int altezza =8;
int lunghezza=16;
color bianco=color (255);
color rosso=color (255,0,0);
color [] colori={bianco,rosso};
int iterazione;
float time1=0;
int numero_lettera=0;                                                            //indice lettera nella parola
int lunghezza_lettera=0;                                                         //indice colonna della lettera
int transla_count=0;                                                             //quando finisco di scrivere la parola conta le traslazioni finche non è sparita dallo schermo
int Lettera[][]={{}}; 
MQTTClient client;
TEXTBOX userTB;

grid g;


int A[][]={{15,31,47,63,79,95,111,127},{63,127},{63,127},{15,31,47,63,79,95,111,127}};
int B[][]={{15,31,47,63,79,95,111,127},{15,79,127},{15,79,127},{15,31,47,63,95,111,127}};
int C[][]={{15,31,47,63,79,95,111,127},{15,127},{15,127},{15,127}};
int D[][]={{15,31,47,63,79,95,111,127},{15,127},{15,127},{31,47,63,79,95,111}};
int E[][]={{15,31,47,63,79,95,111,127},{15,63,127},{15,63,127},{15,127}};
int F[][]={{15,31,47,63,79,95,111,127},{63,127},{63,127},{127}};
int G[][]={{15,31,47,63,79,95,111,127},{15,127},{15,63,127},{15,31,47,63,127}};
int H[][]={{15,31,47,63,79,95,111,127},{63},{63},{15,31,47,63,79,95,111,127}};
int I[][]={{15,31,47,63,79,95,111,127}};
int J[][]={{15,31,47},{15},{15},{15,31,47,63,79,95,111,127}};
int K[][]={{15,31,47,63,79,95,111,127},{63,95},{47,111},{15,31,127}};
int L[][]={{15,31,47,63,79,95,111,127},{15},{15},{15}};
int M[][]={{15,31,47,63,79,95,111,127},{127},{95,111,127},{127},{15,31,47,63,79,95,111,127}};
int N[][]={{15,31,47,63,79,95,111,127},{111},{95},{79},{15,31,47,63,79,95,111,127}};
int O[][]={{15,31,47,63,79,95,111,127},{15,127},{15,127},{15,31,47,63,79,95,111,127}};
int P[][]={{15,31,47,63,79,95,111,127},{79,127},{79,127},{79,95,111,127}};
int Q[][]={{15,31,47,63,79,95,111,127},{15,127},{15,127},{15,31,47,63,79,95,111,127},{15}};
int R[][]={{15,31,47,63,79,95,111,127},{63,79,127},{47,79,127},{15,31,79,95,111,127}};
int S[][]={{15,79,95,111,127},{15,79,127},{15,79,127},{15,31,47,63,79,127}};
int T[][]={{127},{127},{15,31,47,63,79,95,111,127},{127},{127}};
int U[][]={{15,31,47,63,79,95,111,127},{15},{15},{15,31,47,63,79,95,111,127}};
int V[][]={{47,63,79,95,111,127},{31},{15},{31},{47,63,79,95,111,127}};
int W[][]={{15,31,47,63,79,95,111,127},{15},{15,31,47},{15},{15,31,47,63,79,95,111,127}};
int X[][]={{15,31,47,111,127},{63,95},{79},{63,95},{15,31,47,111,127}};
int Y[][]={{111,127},{95},{15,31,47,63,79},{95},{111,127}};
int Z[][]={{15,31,127},{15,47,127},{15,63,127},{15,79,127},{15,95,111,127}};
int NR[][]={{95,111},{127},{15,47,63,127},{79,127},{95,111}}; //carattere non riconosciuto -> ?

void update(){ //Preparo la griglia alla prossima colonna da inserire
         switch(stringa[numero_lettera]){
                case 'A':Lettera=A;break;
                case 'B':Lettera=B;break;
                case 'C':Lettera=C;break;
                case 'D':Lettera=D;break;
                case 'E':Lettera=E;break;
                case 'F':Lettera=F;break;
                case 'G':Lettera=G;break;
                case 'H':Lettera=H;break;
                case 'I':Lettera=I;break;
                case 'J':Lettera=J;break;
                case 'K':Lettera=K;break;
                case 'L':Lettera=L;break;
                case 'M':Lettera=M;break;
                case 'N':Lettera=N;break;
                case 'O':Lettera=O;break;
                case 'P':Lettera=P;break;
                case 'Q':Lettera=Q;break;
                case 'R':Lettera=R;break;
                case 'S':Lettera=S;break;
                case 'T':Lettera=T;break;
                case 'U':Lettera=U;break;
                case 'V':Lettera=V;break;
                case 'W':Lettera=W;break;
                case 'X':Lettera=X;break;
                case 'Y':Lettera=Y;break;
                case 'Z':Lettera=Z;break;
                default:Lettera=NR;break;
           }
        
              for(int i=0;i<Lettera[lunghezza_lettera].length;i++){
                   g.griglia[Lettera[lunghezza_lettera][i]].col=rosso;
               }      
              
}

void setup(){
 background(0,180,180);
  client = new MQTTClient(this);
  client.connect("mqtt://broker.hivemq.com", "processing");
  size(800,500);
 g =new grid(16,8);
 g.draw_griglia();
   userTB = new TEXTBOX();
   userTB.X = 250;
   userTB.Y = 430;
   userTB.W = 200;
   userTB.H = 35;


}

void draw(){
   
   if(millis()-time1>pausa_messaggio){       
     //background(180,180,40);
      if(scorri==true && stringa!=null){        
          if (transla_count==lunghezza-1){
              numero_lettera=0;
              lunghezza_lettera=0;
              transla_count=0;
          }
          if (numero_lettera<stringa.length){
              if (lunghezza_lettera<Lettera.length){
                  update();
                  lunghezza_lettera++;
              }else{
                  numero_lettera++;
                  lunghezza_lettera=0;
              }
          }else{
              transla_count++;
          }
     g.draw_griglia();
     invia();
     g.transla(); 
     time1=millis();
     }else if(stringa==null){
         g.draw_griglia();
    }
    fill(250, 250, 250);
   textSize(25);
   text("INVIA MESSAGGIO", 20, 455);
   userTB.DRAW();

   strokeWeight(3);
   textSize(12);
   }
   
  
   
}



void invia(){
String codifica_stringa="";
if (g.griglia[0].col==rosso){
    codifica_stringa= codifica_stringa+",";
    codifica_stringa=codifica_stringa+Integer.toString(1);
}
for(int i=1;i<g.altezza*g.larghezza;i++){
  if (g.griglia[i].col!=g.griglia[i-1].col){
    codifica_stringa=codifica_stringa+",";
    codifica_stringa=codifica_stringa+Integer.toString(i+1);}
}
 println(codifica_stringa);
 println();
 client.publish("/Nipkow_Disk-Esp8266/buffer", codifica_stringa);
}


void clientConnected() {
  println("client connected");
  client.subscribe("/Nipkow_Disk-Esp8266/processing");
}

void connectionLost() {
  println("connection lost");
}

void messageReceived(String topic, byte[] payload) {
  transla_count=0;
  lunghezza_lettera=0;
  numero_lettera=0;
  scorri=true;
  String s = new String(payload, StandardCharsets.UTF_8);
  s=s.toUpperCase();
  stringa=s.getBytes();
  for (int i=0;i<g.altezza*g.larghezza;i++){
    g.griglia[i].col=bianco;
  }
  println("nuovo messaggio: " + topic + " - " + new String(stringa));
}

void mousePressed() {
  
     userTB.PRESSED(mouseX, mouseY);
     if (stringa==null){
     for (int i=0;i<g.altezza*g.larghezza;i++){
    g.griglia[i].PRESSED(mouseX,mouseY);
     }}
}



void keyPressed() {
     if (userTB.KEYPRESSED(key, (int)keyCode)) {
        transla_count=0;
        lunghezza_lettera=0;
        numero_lettera=0;
        scorri=true;
        for (int i=0;i<g.altezza*g.larghezza;i++){
          g.griglia[i].col=bianco;
         }
         String s = new String(userTB.Text.getBytes(), StandardCharsets.UTF_8);
        s=s.toUpperCase();
        stringa=s.getBytes(); 
       println( userTB.Text);
       userTB.selected=false;
      }else if (userTB.selected==false){
      switch (key){
        case 's':if (stringa!=null){
           scorri=!scorri;}break;
        case 'c':
           stringa=null;
           scorri=false;
              for(int i=0;i<altezza*lunghezza;i++){
                g.griglia[i].col=bianco;
               }
               invia();
           break;
      case 'i':invia();break;
  }

      }
}


  
