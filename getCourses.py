import pandas as pd

import os
with open(f"courses.txt") as f:
    for line in f.readlines():
        course = line.split(":")[0]
        os.system("go run main.go fetch " + course)
    
