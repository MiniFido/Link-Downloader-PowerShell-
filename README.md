# Link-Downloader-PowerShell-
Et lille PowerShell-script der henter filer én ad gangen fra en liste med links og viser status på én linje med %, hastighed og ETA.

Funktioner

Læser links fra links.txt (én URL pr. linje).

Downloader sekventielt til mappen downloads/.

Live status pr. fil: XX% hentet/total MB/s ETA mm:ss.

Ignorerer tomme linjer og linjer der starter med #.

Viser tydelige fejl pr. fil og går videre til næste.

Krav

Windows med PowerShell (medfølger Windows 10/11).

Internetadgang til de angivne URLs.

Filstruktur
/
├─ Download-FromList.ps1   # Dit script (det i README)
├─ links.txt               # Liste med links (én pr. linje)
└─ downloads/              # Oprettes automatisk ved kørsel

links.txt (format)

Én URL pr. linje

Tomme linjer og linjer der starter med # bliver ignoreret

Eksempel

# Eksempel
https://example.com/fil1.zip
https://example.com/billede.jpg
https://example.com/setup.exe

Sådan køres scriptet
A) Direkte (højreklik ikke nødvendigt)

Åbn Windows Terminal eller PowerShell.

Gå til mappen med filerne:

cd "C:\sti\til\mappen"


Kør:

powershell -ExecutionPolicy Bypass -File .\Download-FromList.ps1


-ExecutionPolicy Bypass gør, at du kan køre scriptet uden at ændre systemets politik permanent.

B) Dobbeltklik via .bat (valgfrit)

Hvis du vil kunne starte ved dobbeltklik, læg denne fil som StartDownload.bat i samme mappe:

@echo off
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0Download-FromList.ps1"


Dobbeltklik derefter StartDownload.bat.

Hvad scriptet gør (kort teknisk)

Læser links.txt og filtrerer tomme linjer / kommentarer.

For hvert link:

Finder et filnavn ud fra URL’en (fallback til timestamp).

Opretter downloads/ hvis den ikke findes.

Downloader via System.Net.HttpWebRequest i blokke (64 KB).

Viser procent (hvis filstørrelse kendes), hentet/total, hastighed og ETA på samme linje.

Skriver en afsluttende linje med gennemsnitlig hastighed.

Rydder delvise filer ved fejl.

Eksempel på statuslinjer

Når filstørrelse kendes:

Henter: storfil.iso  37%  1,23 GB/3,35 GB  12,8 MB/s  ETA 02:45


Når filstørrelse ikke kendes:

Henter: data.dump  734 MB  9,4 MB/s

Fejlfinding (FAQ)

“Kan ikke finde .\links.txt”
Læg links.txt i samme mappe som scriptet eller angiv fuld sti i variablen $ListPath.

Vinduet lukker med det samme
Kør via terminal (se “Sådan køres scriptet”), eller brug .bat-filen ovenfor. Scriptet bruger Pause til sidst, så du kan se output.

Langsom hastighed
Hastighed afhænger af serveren. Du kan prøve at øge $BufferSz (f.eks. 131072 eller 262144) men effekten varierer.

Fil hentes uden procent
Serveren sender ikke Content-Length. Scriptet viser stadig hentede bytes og hastighed, men ikke %/ETA.

Fejl på et enkelt link
Scriptet viser fejl for den fil og fortsætter til næste. Den delvise fil slettes automatisk.

Download kræver login/cookies
Scriptet understøtter ikke auth/cookies/headers ud over standard User-Agent. For beskyttede downloads brug en dedikeret klient eller udvid scriptet.

Indstillinger (øverst i scriptet)
$ListPath = ".\links.txt"     # sti til link-listen
$OutDir   = ".\downloads"     # mappe til downloads
$BufferSz = 65536             # blokstørrelse (bytes) – 64 KB

Kendte begrænsninger / idéer til udvidelser

Genoptag ikke færdige downloads (Resume) er ikke implementeret.

Ingen parallel downloads (scriptet er med vilje sekventielt).

Ingen proxy-opsætning (kan tilføjes via WebProxy).

Muligt at tilføje:

Skip hvis fil findes (tjek på $outFile før download).

Resume med Range headers hvis serveren understøtter det.

Logfil (.log) med status for hver fil.

Licens

Vælg en licens (f.eks. MIT) og tilføj LICENSE i repo’et, hvis du vil tillade brug/ændringer frit.
