import csv

csv_files_2_generate = int(input("How many files to generate: "))

for percent in range(0,110,10):
    for idx in range(csv_files_2_generate):
        with open(f"data/save_game{idx}-{percent}.csv", "w") as file:
            writer = csv.writer(file)
            writer.writerow([0])
