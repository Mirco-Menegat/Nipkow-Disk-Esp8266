#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <TaskScheduler.h>
#include<stdio.h>
#include<stdlib.h>
#include <PID_v1.h>
#include "WiFi_Credenziali.h"

#define led D8
#define sensore D7
#define enB  D1
#define in3  D2
#define outputA D3 //DT
#define outputB D4 //CLK


//PID
double Setpoint=580; ; //Rpm ideali
double RPM;
double Output=0 ;
double Kp=2, Ki=10, Kd=0;
double time0_RPM;
double time1_RPM;
PID myPID(&RPM, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);


//STATI DEL ROTARY ENCODER CORRENTE E PRECEDENTE  time0_encoder per gestire bounce
int aState;
int aLastState;
float time0_encoder=0;

// CREDENZIALI WIFI
const char *ssid = ssid_Wifi;
const char *password = password_Wifi;

// MQTT BROKER
const char *mqtt_broker = "broker.hivemq.com";
const char *topic = "/Nipkow_Disk-Esp8266/buffer";
const char *mqtt_username = "esp8266";
const char *mqtt_password = "public";
const int mqtt_port = 1883;

//BUFFER CORRENTE E BUFFER DI RISERVA
boolean sel_buff=false;                         //flag di selezione per selezionare il buffer corrente e quello di riserva
int buff0[128];
int buff_length=8;
int * buff_pointer=buff0;                        //puntatore al buffer corrente così da non dover spostare tutti gli elementi da un buffer all'altro ma solo il puntatore

int buff1[128];
int buff_length_riserva=8;
int nuovo_messaggio=false;                      //indica se è arrivato un nuovo messaggio mqtt

int contatore_buffer=0;                         //Indice elemento del buffer corrente
boolean luce=false;
int offset=0;
float conta_tacche=0;

Scheduler runner;
WiFiClient espClient;
PubSubClient client(espClient);

//Girando il potenziometro a destra o sinistra aumento o diminuisco rispettivamente l'offset, così da girare la finestra in senso orario o antiorario
void gestisci_rotary_encoder() {
    if (millis()-time0_encoder>10) {
        aState = digitalRead(outputA);
        if (aState != aLastState) {               //girando il potenziometro sposto la finestra a in senso orario o antiorario
            if (digitalRead(outputB) != aState ) { //Se ruoto il potenziometro in senso orario
                offset ++;
            } else { //Se ruoto il potenziometro in senso antiorario
                offset--;
            }
            time0_encoder=millis();
        }
    }
    aLastState = aState;
}

//Calcola RPM del disco
void calculate_RPM() {
    if (time1_RPM-time0_RPM!=0) {
        RPM=60000/(time1_RPM-time0_RPM);       //1 minuto/ il tempo che ci mette a fare un giro
    }
}

void stampa() {
    Serial.println(RPM);
}
Task printTask(5000*TASK_MILLISECOND, TASK_FOREVER, stampa);

//Inverte la luce da accesa a spenta o viceversa contatore_buffer diventa l'indice dell'elemento successivo
void inverti_luce(boolean _luce) {
    luce=!luce;
    if (contatore_buffer<buff_length-1) {
        contatore_buffer++;
    }
    switch(luce) {
    case false:
        digitalWrite(led,LOW);
        break;
    case true:
        digitalWrite(led,HIGH);
        break;
    }
}

//Inverte il buffer puntato da buff_pointer, quello di riserva diventa quello corrente e quello corrente diventa di riserva
void inverti_buffer() {
    buff_length=buff_length_riserva;
    switch(sel_buff) {
    case false:
        buff_pointer=buff0;
        break;
    case true:
        buff_pointer=buff1; ;
        break;
    }
}

//Controlla se il disco è all'inizio del giro, spegne la luce e memorizza il tempo di inizio per calcolare gli rpm
boolean check_inizio_giro() {
    if (conta_tacche==offset) {                        //Inizio il giro sempre con luce spenta
        time0_RPM=millis();
        luce=false;
        digitalWrite(led,LOW);
        return true;
    }
    return false;
}

//Controlla se il disco ha completato un giro, dopo aver memorizzato il tempo che ci ha messo a fare un giro calcola gli RPM, e riporta il disco in condizione iniziale
//Se è arrivato un nuovo messaggio mqtt inverti_buffer()
boolean check_fine_giro() {
    if (conta_tacche>=128+offset) {           //mi preparo a scrivere la nuova colonna solo quando ho finito tutto il giro
        time1_RPM=millis();
        calculate_RPM();
        conta_tacche=offset;
        contatore_buffer=0;
        if (nuovo_messaggio==true) {
            inverti_buffer();
        }
        return true;
    }
    return false;
}

//controllo se sono a inizio giro, aumento il conteggio delle tacche,se il conta_tacche coincide con con il prossimo elemento del buffer inverto la luce, controllo se ho finito
//il giro, se l'indice di elemento del buffer è >= della lunghezza del buffer lo riporto a 0.
void ICACHE_RAM_ATTR gestisci_luce() {
    check_inizio_giro();
    conta_tacche++;
    if (buff_length>0 && int(conta_tacche)==buff_pointer[buff_length-1-contatore_buffer]+offset ) { //Se il buffer non è vuoto e conta_tacche coincide con il prossimo elemento del buffer (conto dal fondo)
        inverti_luce(luce);
    }
    check_fine_giro();
    if (contatore_buffer>=buff_length) {
        contatore_buffer=0;
    }
}

void setup() {
    Serial.begin(115200);
    pinMode(enB, OUTPUT);
    pinMode(in3, OUTPUT);
    pinMode(led,OUTPUT);
    pinMode(sensore,INPUT_PULLUP);
    Serial.begin (115200);
    digitalWrite(in3, HIGH);

    attachInterrupt(
        digitalPinToInterrupt(sensore),
        gestisci_luce,
        RISING
    );
    // connecting to a WiFi network
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(400);
        Serial.println("Connecting to WiFi..");
    }
    Serial.println("Connected to the WiFi network");

    //connecting to a mqtt broker
    client.setServer(mqtt_broker, mqtt_port);
    client.setCallback(gestisci_nuovo_messaggio);
    while (!client.connected()) {
        String client_id = "esp8266-client-";
        client_id += String(WiFi.macAddress());
        Serial.printf("The client %s connects to mqtt broker\n", client_id.c_str());
        if (client.connect(client_id.c_str(), mqtt_username, mqtt_password)) {
            Serial.println("Connected to mqtt broker");
        } else {
            Serial.print("failed with state ");
            Serial.print(client.state());
            delay(100);

        }
    }

    client.subscribe(topic);

    runner.init();
    runner.addTask(printTask);
    printTask.enable();
    aLastState = digitalRead(outputA);

    myPID.SetMode(AUTOMATIC);
    //Adjust PID values
    myPID.SetTunings(Kp, Ki, Kd);
}


// Leggo il payload dal fondo e inserisco i numeri nel buffer di riserva, quando ho finito nuovo_messagio=true e scambio e indico che il buffer di riserva sarà il prossimo
//buffer corrente
void gestisci_nuovo_messaggio(char *topic, byte *payload, unsigned int length) {
    Serial.print("Nuovo messaggio nel topic: ");
    Serial.println(topic);
    Serial.print("Messaggio:");

    int indice=1,numero=0;
    int n_elemento=0;
    for (int i = length-1; i >=0 ; i--) {  //leggo il char * al contrario così da poter ricostruire i numeri ed inserirli nel buffer che non sto usando correntemente

        if(payload[i]!=',') {
            char cifra=(char) payload[i];
            numero+=(cifra-'0')*indice;
            indice*=10;

        } else {
            switch(sel_buff) {
            case true:
                buff0[n_elemento]=numero;
                break;
            case false:
                buff1[n_elemento]=numero;
                break;
            }
            n_elemento++;
            Serial.print(numero);
            Serial.print(" ");
            indice=1;
            numero=0;
        }
    }
    buff_length_riserva=n_elemento;

    Serial.println();
    Serial.println("-----------------------");
    nuovo_messaggio=true;
    sel_buff=!sel_buff;
}



void loop() {
    // atrent: in generale non mescolerei TaskScheduler con altri metodi di "tasking", avrei fatto tutto coi task

    myPID.Compute();
    analogWrite(enB,map(Output,0,255,0,1023));
    client.loop();
    runner.execute();
    gestisci_rotary_encoder();

}
