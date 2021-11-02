public class Square{
 public  PVector pos;
 public  float l;
 public  int num;
 public color col;
Square(float x, float y, float _l,int _num){
  pos=new PVector(x,y);
  l=_l;
  num=_num;
  col=bianco;
}

void draw_Square(){
fill(col);
square(pos.x,pos.y,l);
fill(0);
text(num,pos.x+l/2,pos.y+l/2);
}

private boolean overBox(int x, int y) {
      if (x >= pos.x && x <= pos.x + l) {
         if (y >= pos.y && y <= pos.y + l) {
            return true;
         }
      }
      
      return false;
   }
   
   void PRESSED(int x, int y) {
      if (overBox(x, y)) {
         if (col==rosso){
         col=bianco;
         }else{
         col=rosso;
         }
      }
   }
}

public class grid{
public int altezza;
public int larghezza;
public Square [] griglia;
public int l=50;
grid(int _larghezza,int _altezza){
larghezza=_larghezza;
altezza=_altezza;
int count=0;
griglia=new Square[altezza*larghezza];
for (int i=altezza-1;i>=0;i--){
  for (int a=0;a<larghezza;a++){
    griglia[count]=new Square(a*l,i*l,l,count+1);
    count++;
  }
}
}

void draw_griglia(){
  int count=0;
for (int i=0;i<altezza;i++){
  for (int a=0;a<larghezza;a++){
    griglia[count].draw_Square();
    count++;
  }
}
}
void transla(){
 for (int i=0;i<altezza*larghezza;i++){
    if (i%larghezza!=larghezza-1){
        griglia[i].col=griglia[i+1].col;
    }else{
        griglia[i].col=bianco;
    }
 }
}


}
