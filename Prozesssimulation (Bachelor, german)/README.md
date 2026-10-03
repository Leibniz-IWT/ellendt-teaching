# Prozesssimulation (Bachelor)

Willkommen bei den Unterlagen zur Lehrveranstaltung **Prozesssimulation (Bachelor)**.

Dieser Ordner enthält interaktive Jupyter Notebooks (`.ipynb`) und Datendateien zur Vorlesung. Die Notebooks verbinden die im Skript hergeleiteten Modelle mit ihrer praktischen Umsetzung in Python: Sie können die Modelle ausführen, Parameter verändern und die Ergebnisse direkt grafisch auswerten.

## 📂 Inhalte der Veranstaltung

Die Unterlagen sind in zwei Teile gegliedert. Klicken Sie auf einen Ordner, um die zugehörigen Notebooks zu sehen:

### 🐍 [Einführung in Python](./Einf%C3%BChrung%20in%20Python)

Vierteiliger Einstieg in die Programmierung mit Python — alle Beispiele stammen aus der Verfahrenstechnik. Empfohlen für alle, die noch keine Programmiererfahrung haben, bevor mit den Übungen begonnen wird.

* `01_python_erste_schritte.ipynb`
  * Notebooks und Kernel, Python als Taschenrechner, Variablen, Datentypen, f-Strings, Listen und Dictionaries
* `02_python_kontrollstrukturen_funktionen.ipynb`
  * Fallunterscheidungen (`if`), Schleifen (`for`, `while`), eigene Funktionen (z. B. Antoine-Gleichung), Fehlermeldungen lesen
* `03_python_numpy_und_plots.ipynb`
  * NumPy-Arrays, Rechnen mit ganzen Kurven, lineare Gleichungssysteme (Massenbilanz), technische Diagramme mit Matplotlib
* `04_python_messdaten_und_projekt.ipynb`
  * Messdaten aus CSV einlesen, gute Programmierpraxis, Abschlussprojekt Batch-Reaktor (Ausgleichsgerade, Bestimmtheitsmaß, Arrhenius)
* `messdaten_batchreaktor.csv`
  * Messdaten (Zeit, Konzentration) für das Abschlussprojekt in Teil 4

### 🧮 [Übungen](./%C3%9Cbungen)

Die Übungen begleiten die Kapitel des Vorlesungsskripts und bauen schrittweise aufeinander auf.

* `01_Intro.ipynb`
  * **Übung 1:** Grundlagen der Modellierung und Simulation — Einführung in Python/Jupyter und das Heron-Verfahren
* `02_ODE.ipynb`
  * **Übung 2:** Gewöhnliche Differentialgleichungen und explizite Lösungsverfahren — Sinkgeschwindigkeit eines Partikels in Wasser (Stokes, lineare ODE) und in Gas (Schiller-Naumann, nichtlineare ODE)
* `03_gekoppelte_ODE.ipynb`
  * **Übung 3:** Gekoppelte ODE-Systeme — ein fallender, abkühlender und erstarrender Metalltropfen, schrittweise aufgebaut
* `04_gekoppelte_Reaktormodellierung.ipynb`
  * **Übung 4:** Reaktormodellierung — isothermer und nicht-isothermer Batch-Reaktor, DAE-Systeme (Stoffmengenerhaltung, reversible Reaktion)
* `05_Bausteine_des_ADM1.ipynb`
  * **Übung 5:** Biochemische Systeme am Beispiel des ADM1 — Matrix-Notation, Monod-Kinetik, gekoppelte Prozesskaskade, DAE-System

---

## 🚀 So führen Sie die Notebooks aus

Zum Arbeiten mit den Dateien benötigen Sie eine Umgebung, in der Jupyter Notebooks (Python) laufen.

**Option 1: Lokal ausführen (empfohlen)**
1. Laden Sie dieses Repository herunter oder klonen Sie es auf Ihren Rechner.
2. Stellen Sie sicher, dass Python mit `jupyter` und den wissenschaftlichen Standardbibliotheken (`numpy`, `scipy`, `matplotlib`) installiert ist. Am einfachsten gelingt das mit der [Anaconda-Distribution](https://www.anaconda.com/download).
3. Öffnen Sie ein Terminal bzw. die Eingabeaufforderung, wechseln Sie in diesen Ordner und geben Sie ein:
   ```bash
   jupyter notebook
   ```

**Option 2: Im Browser ausführen (ohne Installation)**
* Laden Sie die gewünschte `.ipynb`-Datei herunter und öffnen Sie sie in [Google Colab](https://colab.research.google.com) über *Datei → Notebook hochladen*. Für Teil 4 der Python-Einführung muss zusätzlich die Datei `messdaten_batchreaktor.csv` hochgeladen werden.
