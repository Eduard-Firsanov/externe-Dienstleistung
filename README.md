# Externe Dienstleistung

Dieses Repository enthält eine ABAP-Entwicklung für externe Dienstleistungen im abapGit-Format.

## Inhalt

- `.abapgit.xml`: Repository-Metadaten für abapGit
- `src/`: ABAP-Objekte und zugehörige XML-Metadaten

## Verwendung

Das Repository ist so aufgebaut, dass die abapGit-Dateien direkt im Repository-Stamm liegen. Dadurch kann es in einem ABAP-System direkt über abapGit als Online-Repository verwendet oder lokal mit Git versioniert werden.

## Lokaler Workflow

Für die tägliche Entwicklung sollte genau eine lokale Arbeitskopie verwendet werden.

- Änderungen nur in der aktiven Arbeitskopie im vorgesehenen Entwicklungs-Workspace durchführen
- Keine parallelen Kopien desselben Repositories in verschiedenen Ordnern pflegen
- Vor `pull`, `commit` oder `push` immer kurz `git status` prüfen

## Standardablauf

Für normale Änderungen genügt dieser Ablauf:

1. `git pull`
2. ABAP-Objekte mit abapGit synchronisieren oder lokal ändern
3. `git status` prüfen
4. `git add .`
5. `git commit -m "Kurze Beschreibung der Änderung"`
6. `git push`

## Hinweis

In dieses Repository gehört nicht die ursprüngliche ZIP-Datei eines Exports, sondern nur deren entpackter abapGit-Inhalt.

## Repository-Struktur

```text
.
|-- .abapgit.xml
|-- src/
`-- README.md
```