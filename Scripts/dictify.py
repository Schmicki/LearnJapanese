import re
import json


def get_main_reading(readings : list):
    if readings[1][2] == "True":
        return "kun"
    elif readings[2][2] == "True":
        return "nan"
    else:
        return "on"


# dictify radicals
file = open("c:/users/nicke/desktop/radicals.json", encoding="utf-8")
data = json.load(file)
file.close()

dict = []

for r in data:
    dict.append({
        "text": r[1],
        "reading": r[2],
        "level": r[0]
    })
 
file = open("c:/users/nicke/desktop/radicals2.json", "wt", encoding="utf-8")
file.write(json.dumps(dict, indent=4, ensure_ascii=False))
file.close()

# dictify kanjis
file = open("c:/users/nicke/desktop/kanji-complete.json", encoding="utf-8")
data = json.load(file)
file.close()

dict = []

for k in data:
    dict.append({
        "text": k[1],
        "meanings": k[2],
        "readings": {
            "on": k[3][0][1],
            "kun": k[3][1][1],
            "nan": k[3][2][1],
        },
        "primary_reading": get_main_reading(k[3]),
        "radicals": k[4],
        "level": k[0]
    })
 
file = open("c:/users/nicke/desktop/kanji2.json", "wt", encoding="utf-8")
file.write(json.dumps(dict, indent=4, ensure_ascii=False))
file.close()

# dictify vocabulary
file = open("c:/users/nicke/desktop/vocabulary-complete.json", encoding="utf-8")
data = json.load(file)
file.close()

dict = []

for v in data:
    dict.append({
        "text": v[1],
        "meanings": v[2],
        "types": v[3],
        "reading": v[4],
        "level": v[0]
    })

file = open("c:/users/nicke/desktop/vocabulary2.json", "wt", encoding="utf-8")
file.write(json.dumps(dict, indent=4, ensure_ascii=False))
file.close()