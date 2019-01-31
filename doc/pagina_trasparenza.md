### Visualizzazione elementi in pagina_trasparenza

 * Se il remote_id è mappato come 'rappresentazione_grafica' viene mostrato il grafico 'design:openpa/full/parts/amministrazione_trasparente/grafico_enti_partecipati.tpl'
 * Se è presente e popolato l'attributo ezpage **fields_blocks**: vengono mostrati i blocchi configurati
   
   * altrimenti: 
     
     * Se è presente e popolato l'attributo ezstring **fields**: viene mostrata la tabella secondo quantp specificato nell'attributo
        
        * altrimenti (fallback) vengono mostrati i figli 
          * con visualizzazione tabellare, se il remote_id è mappato come 'consulenti_e_collaboratori', 'incarichi_amminsitrativi_di_vertice', 'dirigenti', 'tassi_di_assenza', 'incarichi_conferiti', 'atti_di_concessione'
          * come lista, negli altri casi

 * Se ci sono altri contenuti figli della pagina di classe non compresa tra pagina_trasparenza, nota_trasparenza, folder e le classi ricavate da fields_blocks e fields: viene mostrato un alert per l'editor è una tabella di Ulteriori documenti
 
 
Per la mappatura dei remote_id usare `[Trasparenza]RemoteIdMap[<remote_id>]=rappresentazione_grafica` in openpa.ini

Riferimento per la configurazione della stringa *fields*: `[group_by:<identifier>|]<class>|<identifier>[,<identifier>]|<depth>`