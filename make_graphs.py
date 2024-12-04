import csv
import matplotlib.pyplot as plt
import math

def main():
    data = []
    colors = [(1,0,0),(0.8,0,0),[0.6,0.0,0.2],[0.4,0.0,0.0],[0.0,1,0.0],[0.0,0.8,0.0],[0.0,0.6,0.0],[0.0,0.4,0.0],[0.0,0.0,1.0],[0.0,0.0,0.6],[0.0,0.0,0.4]]
    labels = ["0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"]
    for x in range (0,11):
        try:
            with open(f"data/Data_combined/exported_{x}0.csv","r") as file:
                reader: csv.reader = csv.reader(file)
                temp_data = []
                for row in reader:
                    temp_data.append(float(row[0]))
                data.append(temp_data)
        except:
            print("eeexxx")
    x_akse = range(1, len(data[0])+1) 
    for step in range(len(data)):
        plt.plot(x_akse, data[step], color=colors[step], label = labels[step])
    plt.xlabel("Full cross rotations")
    plt.ylabel("Total - cars ")
    plt.title("Histogram of cars")
    plt.axis()
    plt.grid()
    plt.xticks(range(1, 10))
    # plt.ylim(150,250)
    # plt.xlim(6,10)
    # plt.ylim(170,245)
    # plt.xlim(8,10)
    plt.legend(reverse = True)
    plt.show()
    p = data[len(data)-1][9]
    print(p-1.96 * math.sqrt((p*(1-p))/10),p+1.96 * math.sqrt((p*(1-p)/n)))






if __name__ == "__main__":
    main()
