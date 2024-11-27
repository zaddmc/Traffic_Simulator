import csv
import os

csv_files_2_generate = int(input("How many files to generate: "))


for percent in range(0,110,10):
    for idx in range(csv_files_2_generate):
        try:
            with open(f"data/data{percent:02}/save_game{idx}.csv", "w") as file:
                writer = csv.writer(file)
                writer.writerow([0])
        except:
            os.mkdir(f"data/data{percent:02}/")
            with open(f"data/data{percent:02}/save_game{idx}.csv", "w") as file:
                writer = csv.writer(file)
                writer.writerow([0])

