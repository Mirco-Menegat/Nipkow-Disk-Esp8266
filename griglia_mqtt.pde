import mqtt.*;
import java.nio.charset.StandardCharsets;

MQTTClient client;
byte [] stringa=null;
boolean scorri=true;
int altezza =8;
int lunghezza=16;
color bianco=color (255);
color rosso=color (255,0,0);
color [] colori={bianco,rosso};
Square [] griglia=new Square[altezza*lunghezza];
int iterazione;
float time1=0;

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

void setup(){
  client = new MQTTClient(this);
  client.connect("mqtt://broker.hivemq.com", "processing");
  size(700,350);
  rectMode(CENTER);
  background(255);
  iterazione=-1;                              
  for(int i=height-height/altezza/2-4;i>0;i-=height/altezza){                    //Creo Griglia e la disegno
     for (float a=width/lunghezza/2+5;a<width;a=a+width/lunghezza){
        iterazione++;
        griglia[iterazione]=new Square(a,i,height/altezza,iterazione+1);
        griglia[iterazione].draw_Square();
        fill(0);
        text(iterazione+1,a,i);
        noFill();
    }
  }
  iterazione=-1;
}
int numero_lettera=0;                                                            //indice lettera nella parola
int lunghezza_lettera=0;                                                         //indice colonna della lettera
int Lettera[][]={{}}; 
int transla_count=0;                                                             //quando finisco di scrivere la parola conta le traslazioni finche non è sparita dallo schermo

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
                   griglia[Lettera[lunghezza_lettera][i]].col=rosso;
               }      
              
}
void draw(){
    if(millis()-time1>1000){                    
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
     draw_griglia();
     invia();
     transla(); 
     time1=millis();
     }else if(stringa==null){
         draw_griglia();
    }
   }
}

class Square{
PVector pos;
color col;
float lato;
int numero;
Square(float x,float y,float l,int num){
pos=new PVector(x,y);
lato=l;
col=bianco;
numero=num;
}
void draw_Square(){
fill(col);
square(pos.x,pos.y,lato);
}

void inverti(){
  if (col==bianco){
    col=rosso;
  }else{
    col=bianco;
  }
}

}

void mouseClicked(){
  if (stringa==null){ //Se non sto scrivendo nessuna parola posso disegnare 
      for(int i=0;i<altezza*lunghezza;i++){
        if(pow(griglia[i].pos.x-mouseX,2)<pow(griglia[i].lato/2,2)&& pow(griglia[i].pos.y-mouseY,2)<pow(griglia[i].lato/2,2)){
            griglia[i].inverti();
        }
      }
  }
}

void clientConnected() {
  println("client connected");
  client.subscribe("/mello/buffer/received");
}


void draw_griglia(){
 for(int i=height-height/altezza/2;i>0;i-=height/altezza){
  for (float a=width/lunghezza/2;a<width;a=a+width/lunghezza){
      iterazione++;
      griglia[iterazione].draw_Square();
      fill(0);
      text(iterazione+1,a,i);
      noFill();
  }
}
iterazione=-1;
}


void transla(){
 for (int i=0;i<altezza*lunghezza;i++){
    if (i%lunghezza!=lunghezza-1){
        griglia[i].col=griglia[i+1].col;
    }else{
        griglia[i].col=bianco;
    }
 }
}


void messageReceived(String topic, byte[] payload) {
  transla_count=0;
  lunghezza_lettera=0;
  numero_lettera=0;
  scorri=true;
  String s = new String(payload, StandardCharsets.UTF_8);
  s=s.toUpperCase();
  stringa=s.getBytes();
  for (int i=0;i<altezza*lunghezza;i++){
    griglia[i].col=bianco;
  }
  println("nuovo messaggio: " + topic + " - " + new String(stringa));
}

void connectionLost() {
  println("connection lost");
}

void invia(){
String codifica_stringa="";
if (griglia[0].col==rosso){
    codifica_stringa= codifica_stringa+",";
    codifica_stringa=codifica_stringa+Integer.toString(1);
}
for(int i=1;i<altezza*lunghezza;i++){
  if (griglia[i].col!=griglia[i-1].col){
    codifica_stringa=codifica_stringa+",";
    codifica_stringa=codifica_stringa+Integer.toString(i+1);}
}
 //println(codifica_stringa);
 //println();
 client.publish("/mello/buffer", codifica_stringa);
}

void keyPressed(){
  switch (key){
  case 's':if (stringa!=null){
           scorri=!scorri;}break;
  case 'c':
           stringa=null;
           scorri=false;
              for(int i=0;i<altezza*lunghezza;i++){
                griglia[i].col=bianco;
               }
               invia();
           break;
  case 'i':invia();break;
  }
}
