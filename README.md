# Nipkow-Disk-Esp8266
## Descrizione 
Rivisitazione del disco di Nipkow usando Esp8266. Il disco è in grado di proiettare immagini statiche o un testo scorrevole tramite mqtt.
È stato inserito un rotary encoder siccome solo un ottavo del disco proietta l'immagine corretta, attraverso il rotary encoder possiamo spostare la finestra in modo da averla nella giusta posizione.
Il sensore a infrarossi rileva il passaggio di 128 tacche nere e bianche poste dietro al disco. Un ottavo di queste 128 tacche determinano la risoluzione della larghezza della finestra mentre i numero di fori la risoluzione della sua altezza, quindi il disco ha una risoluzione di 16*8. I buchi e lo spazio tra una tacca e l'altra sono della dimensioni di 3 mm.
L'immagine o la scritta sono contemporaneamente proiettate sul disco e sull'interfaccia grafica in processing.
Se non è proiettata alcuna scritta, cliccando le caselle sull'interfaccia posso disegnare un'immagine.
Premendo alcuni tasti dall'interfaccia ho le seguenti funzionalità:
* 's': se è proiettata una scritta ferma/attiva lo scorrimento della stessa
* 'c': cancella lo schermo
* 'i': se non è proiettata alcuna scritta codifica l'immagine e invia messaggio mqtt all'esp8266 che la proietta sul disco.
## Materiale
* ESP8266
* Disco di Nipkow
* Motore DC 7.5V
* Motor Driver L298N
* led RGB
* Rotary Encoder
* Sensore Infrarossi

## Software ausiliario
* Processing
