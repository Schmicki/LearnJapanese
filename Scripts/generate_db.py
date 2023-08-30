import json

# load hiragana
file = open("hiragana.json", encoding="utf-8")
hiragana = json.load(file)
file.close()

# load katakana
file = open("katakana.json", encoding="utf-8")
katakana = json.load(file)
file.close()

# load radicals
file = open("radicals.json", encoding="utf-8")
radicals = json.load(file)
file.close()

# load kanji
file = open("kanji.json", encoding="utf-8")
kanji = json.load(file)
file.close()

# load vocabulary
file = open("vocabulary.json", encoding="utf-8")
vocabulary = json.load(file)
file.close()

# generate char dict
char_dict = {}

for i, h in enumerate(hiragana):
    char_dict[h["text"]] = [0, i]
    h["vocabulary"] = []

for i, k in enumerate(katakana):
    char_dict[k["text"]] = [1, i]
    k["vocabulary"] = []

for i, k in enumerate(kanji):
    char_dict[k["text"]] = [2, i]
    k["vocabulary"] = []

# generate radical dict
radical_dict = {}

for i, r in enumerate(radicals):
    radical_dict[r["reading"]] = i
    r["kanji"] = []

# generate vocabulary links
for i, v in enumerate(vocabulary):
    v["characters"] = []
    for c in v["text"]:
        id = char_dict.get(c)

        if id == None:
            id = char_dict.get(chr(ord(c) + 1))
        
        if id == None:
            continue

        v["characters"].append(id)

        if id[0] == 0:
            hiragana[id[1]]["vocabulary"].append(i)
        elif id[0] == 1:
            katakana[id[1]]["vocabulary"].append(i)
        elif id[0] == 2:
            kanji[id[1]]["vocabulary"].append(i)

# replace radical text
for i, k in enumerate(kanji):
    for x, r in enumerate(k["radicals"]):
        idx = radical_dict[r]
        k["radicals"][x] = idx
        radicals[idx]["kanji"].append(i)

# store hiragana
file = open("JapaneseDB.gd", "wt", encoding="utf-8")
file.write("extends Node\n\n")

file.write("var hiragana = ")
file.write(json.dumps(hiragana, indent=4, ensure_ascii=False))
file.write(",\n\n")

# store katakana
file.write("var katakana = ")
file.write(json.dumps(katakana, indent=4, ensure_ascii=False))
file.write(",\n\n")

# store radicals
file.write("var radicals = ")
file.write(json.dumps(radicals, indent=4, ensure_ascii=False))
file.write(",\n\n")

# store kanji
file.write("var kanji = ")
file.write(json.dumps(kanji, indent=4, ensure_ascii=False))
file.write(",\n\n")

# store vocabulary
file.write("var vocabulary = ")
file.write(json.dumps(vocabulary, indent=4, ensure_ascii=False))
file.write(",\n\n")