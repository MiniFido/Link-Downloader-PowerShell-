# Link-Downloader (PowerShell)

Et lille PowerShell-script der henter filer **én ad gangen** fra en liste med links og viser **status på én linje** med **%**, **hastighed** og **ETA**.

---

## ✨ Funktioner
- Læser links fra `links.txt` (én URL pr. linje)
- Downloader sekventielt til mappen `downloads/`
- Live status pr. fil:  
  ```
  XX%  hentet/total  MB/s  ETA mm:ss
  ```
- Ignorerer tomme linjer og linjer der starter med `#`
- Viser fejl for hver fil og fortsætter til næste

---

## 📂 Filstruktur
```
/
├─ Download-FromList.ps1   # Selve scriptet
├─ links.txt               # Liste med links (én pr. linje)
└─ downloads/              # Oprettes automatisk ved kørsel
```

---

## 📝 links.txt (format)
- Én URL pr. linje
- Tomme linjer og linjer der starter med `#` bliver ignoreret

**Eksempel**
```
# Eksempel
https://example.com/fil1.zip
https://example.com/billede.jpg
https://example.com/setup.exe
```

---

## ▶️ Sådan køres scriptet

### **A) Direkte i PowerShell**
1. Åbn **Windows Terminal** eller **PowerShell**
2. Gå til mappen med filerne:
   ```powershell
   cd "C:\sti\til\mappen"
   ```
3. Kør:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Download-FromList.ps1
   ```
> `-ExecutionPolicy Bypass` gør, at du kan køre scriptet uden at ændre systemindstillinger permanent.

---

### **B) Via dobbeltklik (.bat)**
Opret en fil ved navn `StartDownload.bat` i samme mappe:
```bat
@echo off
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0Download-FromList.ps1"
```
Dobbeltklik derefter `StartDownload.bat`.

---

## ⚙️ Indstillinger (øverst i scriptet)
```powershell
$ListPath = ".\links.txt"     # sti til link-listen
$OutDir   = ".\downloads"     # mappe til downloads
$BufferSz = 65536              # blokstørrelse (bytes) – 64 KB
```

---

## 📊 Eksempel på statuslinjer
**Når filstørrelse kendes:**
```
Henter: storfil.iso  37%  1,23 GB/3,35 GB  12,8 MB/s  ETA 02:45
```

**Når filstørrelse ikke kendes:**
```
Henter: data.dump  734 MB  9,4 MB/s
```

---

## ❓ Fejlfinding / FAQ
**“Kan ikke finde .\links.txt”**  
➡️ Læg `links.txt` i samme mappe som scriptet eller opdater `$ListPath`.

**Vinduet lukker med det samme**  
➡️ Brug `.bat`-filen ovenfor eller kør via terminal.

**Langsom hastighed**  
➡️ Kan skyldes serveren. Prøv at øge `$BufferSz` (f.eks. `131072`).

**Fil uden procent**  
➡️ Serveren sender ikke `Content-Length` – scriptet viser stadig hentede bytes + hastighed.

**Fejl på et link**  
➡️ Scriptet sletter delvise filer og fortsætter med næste link.

---

## 🚀 Mulige udvidelser
- Springe eksisterende filer over
- Genoptage afbrudte downloads (`Resume`)
- Gemme log med status for hver fil
- Parallel downloads (flere på én gang)

---

## 📄 Licens
Vælg en licens (f.eks. MIT) og tilføj `LICENSE`-fil i repo’et.
