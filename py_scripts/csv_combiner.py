import csv

def start(percent_ = 0, csv_file_count_ = 0):
    
    csv_file_count = int(input("How many csv files: ")) if csv_file_count_ == 0 else csv_file_count_
    percent = input("What percentage: ") if percent_ == 0 else percent_

    master_dict = {i : 0 for i in range(csv_file_count)}

    for idx in range(csv_file_count):
        master_dict[idx] = import_csv_file(f"data/data{percent}/save_game{idx}.csv")
    
    result = []
    for vals in master_dict.values():
        for idx, val in enumerate(vals):
            try:
                result[idx] += val
            except:
                result.append(val)
    
    for idx, value in enumerate(result):
        result[idx] = value/(csv_file_count)

    export_csv_file(result, percent)
    
def export_csv_file(data, percent):
    with open(f"data/Data_combined/exported_{percent}.csv", "w") as file:
        writer = csv.writer(file)
        for val in data:
            writer.writerow([val])

def import_csv_file(file_name):
    with open(file_name, "r") as file:
        reader = csv.reader(file)
        data = []
        rows = 0
        for line in reader:
            data.append(float(line[0]))
        return data

def starter():
    temp_csv_input = input("How Many csv files: ")
    csv_file_count = int(temp_csv_input) if temp_csv_input != "" else 10
    temp_percent = input("What Percent to do: ")
    percent = temp_percent if temp_percent != "" else range(0,110,10)

    if type(percent) is str:
        start(percent, csv_file_count)
    else:
        for per in percent:
            start(f"{per:02}", csv_file_count)


if __name__ == "__main__":
    starter()
