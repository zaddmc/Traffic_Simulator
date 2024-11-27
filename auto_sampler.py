import subprocess
import threading
#subprocess.run(["ls", "-a"])
#subprocess.run(["ls", "-a"])



def start_thead(percent):
    for i in range(10):
        subprocess.run(["godot", "-q", "--path", "./", f"{i}", f"{percent:02}"])
        print(f"percent: {percent:02} finished run: {i}")
    return


threads_as = []
for percent in range(0,110,10):
    threads_as.append(threading.Thread(target=start_thead, args=(percent,)))

for thread in threads_as:
    thread.start()

