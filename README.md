# post_md_public_immage

Archivio pubblico di immagini e asset per post e documenti Markdown, sincronizzato in tempo reale con GitHub:
`https://github.com/iomarco74/post_md_public_immage`

---

## ⚡ Come funziona la sincronizzazione automatica

Lo script [`sync_watch.ps1`](file:///c:/Users/Administrator/Documents/Github/post_md_public_immage/sync_watch.ps1) monitora costantemente questa cartella. Non appena incolli, salvi, modifichi o elimini qualsiasi immagine o file:
1. Attende 3 secondi (debouncing per consentire il completamento della scrittura del file).
2. Esegue un `git pull --rebase` per evitare conflitti con modifiche su GitHub.
3. Esegue `git add .` e `git commit -m "Auto-sync: <data-ora>"`.
4. Esegue il `git push origin main` su GitHub.
5. Scrive lo storico delle operazioni su [`sync_watch.log`](file:///c:/Users/Administrator/Documents/Github/post_md_public_immage/sync_watch.log).

---

## 🚀 Istruzioni d'uso

Troverai nella cartella diversi file eseguibili con un doppio clic:

| File | Descrizione |
| :--- | :--- |
| **`avvia_visibile.bat`** | Avvia la sincronizzazione aprendo una finestra del terminale (utile per visualizzare in tempo reale i log). |
| **`avvia_background.vbs`** | Avvia la sincronizzazione **completamente in background** (nessuna finestra o prompt visibile). |
| **`ferma_sync.bat`** | Termina e arresta il processo di sincronizzazione in background. |
| **`attiva_avvio_automatico_windows.bat`** | Configura l'avvio automatico del monitoraggio ogni volta che accedi a Windows. |
| **`disattiva_avvio_automatico_windows.bat`** | Rimuove l'avvio automatico da Windows. |

---

## 📝 Come usare le immagini nei tuoi post Markdown
Una volta copiata un'immagine (es. `mia-immagine.png`) in questa cartella:
- Nel giro di 3-5 secondi sarà disponibile online su GitHub.
- Puoi incorporarla nei tuoi post Markdown usando l'URL pubblico:
  ```markdown
  ![Descrizione](https://raw.githubusercontent.com/iomarco74/post_md_public_immage/main/mia-immagine.png)
  ```
  oppure tramite CDN jsDelivr:
  ```markdown
  ![Descrizione](https://cdn.jsdelivr.net/gh/iomarco74/post_md_public_immage@main/mia-immagine.png)
  ```
