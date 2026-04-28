# externe-Dienstleistung

## Ueberblick

Dieses Repository enthaelt die ABAP-Entwicklung `Externe Dienstleistung` im abapGit-Format. Die technische Wurzel ist `src/`; dort liegen die exportierten ABAP-Objekte und ihre XML-Metadaten.

## Technische Ablage

- `.abapgit.xml` enthaelt die Repository-Metadaten fuer abapGit.
- `src/package.devc.xml` beschreibt das Hauptpaket `Externe Dienstleistung`.
- `src/` enthaelt die versionierten ABAP-Objekte.

## Inhalt und Schwerpunkte

- Repository-Stamm bereits in abapGit-kompatibler Struktur
- ABAP-Objekte und zugehoerige XML-Metadaten direkt unter `src/`
- geeignet fuer die Nutzung als Online-Repository in abapGit und fuer lokale Git-Versionierung

## Arbeitsweise

Aenderungen sollten nur in einer aktiven Arbeitskopie vorgenommen werden. Fuer normale Aenderungen genuegt der Ablauf `git pull`, ABAP-Objekte synchronisieren oder anpassen, `git status` pruefen, dann `git add`, `git commit` und `git push`. In das Repository gehoert nur der entpackte abapGit-Inhalt, nicht die urspruengliche Export-ZIP-Datei.