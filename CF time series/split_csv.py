import csv

# Name der Eingabe-CSV-Datei
input_file = 'ninja_wind_country_NL_long-termfuture-merra-2_corrected.csv'

# Lesen der Eingabe-CSV-Datei
with open(input_file, 'r') as file:
    reader = csv.reader(file)
#    header = next(reader)  # Kopfzeile überspringen
    data = list(reader)

# Aufspalten der Daten nach Jahr
data_by_year = {}
for row in data:
    date_time = row[0].split()[0]  # Extrahiere das Datumsteil aus der ersten Spalte
    year = date_time.split('.')[-1]  # Extrahiere das Jahr aus dem Datumsteil
    if year not in data_by_year:
        data_by_year[year] = []
    data_by_year[year].append(row)

# Schreiben der Daten in separate CSV-Dateien pro Jahr
for year, rows in data_by_year.items():
    output_file = f'NL0_{year}.csv'
    with open(output_file, 'w', newline='') as file:
        writer = csv.writer(file)
#        writer.writerow(header)
        first_row = rows[0]
        writer.writerow(first_row)
        writer.writerows(rows[1:])
    print(f'Datei {output_file} erfolgreich erstellt.')


