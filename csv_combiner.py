import csv

def start():
    
    csv_file_count = int(input("How many csv files: "))
    percent = input("What percentage: ")

    master_dict = {}

    #for percent in range(0,110,10):
    total = 0
    for idx in range(csv_file_count):
        total += import_csv_file(f"data/data{percent}/save_game{idx}.csv")
    master_data[percent].append(total / csv_file_count)
    
    export_csv_file(master_dict, percent)
    
def export_csv_file(data, percent):
    with open(f"data/data{percent}/exported_{percent}.csv", "w") as file:
        writer = csv.writer(file)
        for percent in range(0,110,10):
            writer.writerow([data[percent]])

def import_csv_file(file_name):
    with open(file_name, "r") as file:
        reader = csv.reader(file)
        data = 0
        for line in reader:
            data += float(line)
        return data

if __name__ == "__main__":
    start()
