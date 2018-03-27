# OpenContent Albo OnLine

Estensione per OpenPA che raccoglie utilità di gestione e visualizzazione di contenuti per l'albo on line

## Definizioni

### Albo On Line
Che cos'è l'albo on line?
Come si distingue dall'albo telematico?
(todo) 

### Attributi di tipo data

(todo: queste descrizioni sono state fatte per UPIPA)

 * __Data__: viene semplicemente mostrata e viene usata per dare il nome all'atto
 * __Data di archiviazione__ (a raggiungimento di questa data, l'atto in albo on-line è raggiungibile solo nel tab "archivio")
 * __Data di fine pubblicazione all'albo__ (a raggiungimento di questa data, la delibera/determina in albo on-line è raggiungibile solo nel tab "area riservata" che vedono solo gli amministratori del sito)
 * __Data fine pubblicazione nella sezione Amministrazione Trasparente__ (a raggiungimento di questa data, la delibera/determina nella trasparenza è visibile solo dagli amministratori del sito)

## Installazione

###Installare estensione 

Normale attivazione dell'estensione (in tutti i siteaccess del sito)

###Migrare i nome degli stati dall'albo telematico trentino se necessario con: 
 
```bash 
php extension/ocalboonline/bin/php/migrate_from_albotelematicotrentino.php -s<siteaccess> 
```

###Creare sezione Oggetti Scaduti (oggetti_scaduti) da backend oppure con

```bash 
php extension/ocalboonline/bin/php/create_section_oggetti_scaduti.php -s<siteaccess> 
```
 
###Impostare le regole per i cron in openpa.ini:
####Impostare le regole di change_state

Per ciascuna classe dell'albo occorre impostare una riga in Rules come nel seguente esempio su deteminazione

> __Occorre verificare gli identificatori degli attributi di ciscuna classe__
 
``` 
[ChangeState]
Rules[]
Rules[]=determinazione|cambia_stato_per_data_archiviazione,cambia_stato_per_data_finepubblicazione,cambia_stato_per_data_finepubblicazione_trasparenza
``` 

Le seguenti definizioni di regole sono riutilizzabili per tutte le classi specificate in Rules:

*La seguente regola impone: se lo stato è visibile e la data_archiviazione è inferiore a oggi alle ore 23:59:59 cambia lo stato in archiviato*
``` 
[ChangeStateRule-cambia_stato_per_data_archiviazione]
CurrentState=albo_on_line.visibile
DestinationState=albo_on_line.archiviato
Conditions[]
Conditions[]=data_archiviazione;lt;TODAY
``` 

*La seguente regola impone: se lo stato è archiviato e la data_finepubblicazione è inferiore a oggi alle ore 23:59:59 cambia lo stato in riservato*
``` 
[ChangeStateRule-cambia_stato_per_data_finepubblicazione]
CurrentState=albo_on_line.archiviato
DestinationState=albo_on_line.riservato
Conditions[]
Conditions[]=data_finepubblicazione;lt;TODAY
``` 


*La seguente regola impone: se lo stato è riservato e la data_finepubblicazione_trasparenza è inferiore a oggi alle ore 23:59:59 cambia lo stato in non_visibile*
``` 
[ChangeStateRule-cambia_stato_per_data_finepubblicazione_trasparenza]
CurrentState=albo_on_line.riservato
DestinationState=albo_on_line.non_visibile
Conditions[]
Conditions[]=data_finepubblicazione_trasparenza;lt;TODAY
```
 
####Impostare le regole di change_section

Per ciascuna classe dell'albo occorre impostare le configurazioni come nel seguente esempio su deteminazione

*La seguente regola impone: tutti gli oggetti sotto a RootNode che hanno la data_finepubblicazione_trasparenza maggiore di oggi vengono spostati in sezione oggetti_scaduti*
``` 
[ChangeSection]
ToSection[determinazione]=oggetti_scaduti
DataTime[determinazione]=data_finepubblicazione_trasparenza
RootNodeList[determinazione]=RootNode
``` 

