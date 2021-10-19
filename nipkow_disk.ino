#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <TaskScheduler.h>

#include<stdio.h>
#include<stdlib.h>

 #define led D8
 #define sensore D7
 #define enB  D1
 #define in3  D2
 #define outputA D3 //DT
 #define outputB D4 //CLK
  int aState;
 int aLastState;  
// WiFi
const char *ssid = ""; // Enter your WiFi name
const char *password = "";  // Enter WiFi password

// MQTT Broker
const char *mqtt_broker = "broker.hivemq.com";
const char *topic = "/mello/buffer";
const char *mqtt_username = "MelloMircoasd";
const char *mqtt_password = "public";
const int mqtt_port = 1883;

int buff[128];
int buff_length=8;

int contatore_buffer=0;
 boolean luce=false;
 int offset=0;
 float conta_tacche=0;
  Scheduler runner;
WiFiClient espClient;
PubSubClient client(espClient);

//void stampa(){
  //Serial.println(buff_length);
 // Serial.println(client.connected());  
//}
//Task printTask(1000*TASK_MILLISECOND, TASK_FOREVER, stampa);

void ICACHE_RAM_ATTR gestisci_luce()  
 { 
    if (conta_tacche==offset){
        luce=false;
      digitalWrite(led,LOW);
      }

  conta_tacche++;

  
  if (buff_length>0 && int(conta_tacche)==buff[buff_length-1-contatore_buffer]+offset ){
    luce=!luce;
    contatore_buffer++;
     
    if (luce==true){
       digitalWrite(led,HIGH);
  }else{
    digitalWrite(led,LOW);}
    }
  if (conta_tacche==128+offset){
      conta_tacche=offset;
      contatore_buffer=0;      
   }
   if (contatore_buffer==buff_length){
      contatore_buffer=0;
    }
  }

void setup() {
  buff[0]=128;
buff[1]=112;
buff[2]=96;
buff[3]=80;
buff[4]=64;
buff[5]=48;
buff[6]=32;
buff[7]=16;
  // Set software serial baud to 115200;
  Serial.begin(115200);
  pinMode(enB, OUTPUT);
  pinMode(in3, OUTPUT);
   pinMode(led,OUTPUT);
   pinMode(sensore,INPUT_PULLUP);
   Serial.begin (115200);
   digitalWrite(in3, HIGH);
   analogWrite(enB, 600);

   
    attachInterrupt(
            digitalPinToInterrupt(sensore),
            gestisci_luce,   
            RISING
           );
           
  // connecting to a WiFi network
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.println("Connecting to WiFi..");
  }
  Serial.println("Connected to the WiFi network");

  
  //connecting to a mqtt broker
  client.setServer(mqtt_broker, mqtt_port);
  client.setCallback(callback);
  while (!client.connected()) {
      String client_id = "esp8266-client-";
      client_id += String(WiFi.macAddress());
      Serial.printf("The client %s connects to mqtt broker\n", client_id.c_str());
      if (client.connect(client_id.c_str(), mqtt_username, mqtt_password)) {
          Serial.println("Connected to mqtt broker");
      } else {
          Serial.print("failed with state ");
          Serial.print(client.state());
          delay(500);
          
      }
  }

  client.subscribe(topic);
  
  // runner.init();
   //runner.addTask(printTask);
   //printTask.enable();
   aLastState = digitalRead(outputA);   
}

void callback(char *topic, byte *payload, unsigned int length) {
  Serial.print("Nuovo messaggio nel topic: ");
  Serial.println(topic);
  Serial.print("Messaggio:");

  int indice=1,numero=0;
   int n_elemento=0;
  for (int i = length-1; i >=0 ; i--) {
     
      if(payload[i]!=','){
      char cifra=(char) payload[i];
       numero+=(cifra-'0')*indice;
      indice*=10;
      
      }else{
        buff[n_elemento]=numero;
        n_elemento++;
        Serial.print(numero);
        Serial.print(" ");
        indice=1;
        numero=0;
        }
  }
  luce=false;
  buff_length=n_elemento;
  Serial.println(buff_length);
  Serial.println();
  Serial.println("-----------------------");
}

void loop() {
  client.loop();
  runner.execute();
  aState = digitalRead(outputA); //Legge lo stato corrente di  outputA
   if (aState != aLastState){     
     // se encoder è stato ruotato in senso orario
     if (digitalRead(outputB) != aState) { 
       offset ++;
     }else{ //se encoder è stato ruotato in senso antiorario
      offset--;
      }
   } 
   aLastState = aState; 
 
}
