import urllib3
import time
import re


def html_get_end(html : str, start : int, type : str) -> int:
    index = html.find(type, start)
    depth = 1

    while depth > 0:
        index = html.find(type, index + 1)

        if index == -1:
            return -1
        elif html[index - 2] == "<" and html[index - 1] == "/":
            depth -= 1
        elif html[index - 1] == "<":
            depth += 1

    return html.find(">", index) + 1


def html_get_element(html : str, offset : int, type : str, attributes : str):
    start = html.find("<" + type + " " + attributes, offset)

    if start == -1:
        return None

    end = html_get_end(html, start, type)

    if end == -1:
        return None

    return html[start : end]


def html_get_element_content(html : str, offset : int, type : str, attributes : str = ""):
    element = html_get_element(html, offset, type, attributes)
    start = element.find(">")

    if start == -1:
        return None

    end = element.rfind("</")

    if end == -1:
        return None
    return element[start + 1 : end]


def html_get_elements(html : str, offset : int, type : str, attributes : str):
    elements = []
    index = offset

    while True:
        start = html.find("<" + type + " " + attributes, index)

        if start == -1:
            break

        end = html_get_end(html, start, type)

        if end == -1:
            break

        elements.append(html[start : end])
        index = end

    return elements


def get_char_grid_item(item : str):
    start : int = item.find("href=\"") + 6
    end : int = item.find("\"", start)
    link = "https://www.wanikani.com" + item[start : end]

    start : int = item.find("<span class=\"character-item__characters\" lang=\"ja\">") + 51
    end : int = item.find("</", start)
    char = item[start : end]

    start : int = item.find("<li class='character-item__info-reading' lang=\"ja\">") + 51
    end : int = item.find("</", start)
    reading = item[start : end].replace("\n", "")
    reading = re.sub("\s+", "", reading)
    reading = re.sub("\s+$", "", reading)

    start : int = item.find("<li class='character-item__info-meaning'>") + 41
    end : int = item.find("</", start)
    meaning = item[start : end].replace("\n", "")
    meaning = re.sub("^\s+", "", meaning)
    meaning = re.sub("\s+$", "", meaning)

    if char.startswith("<img"):
        char = "img=" + meaning.lower()
    
    return [link, char, reading, meaning]


def get_component_list_item(item : str):
    start : int = item.find("href=\"") + 6
    end : int = item.find("\"", start)
    link = "https://www.wanikani.com" + item[start : end]
    char = html_get_element_content(item, 0, "span", "class=\"component-character__characters")
    meaning = html_get_element_content(item, 0, "span", "class='component-character__meaning")
    return [link, char, meaning]


def get_radical(html : str):
    radical = {}
    kanji = []

    # get level
    element = html_get_element_content(html, 0, "a", "class=\"page-header__icon page-header__icon--level\"")
    radical["level"] = element

    # get char
    element = html_get_element_content(html, 0, "span", "class=\"page-header__icon page-header__icon--radical\"")
    radical["char"] = element

    # get text
    element = html_get_element_content(html, 0, "span", "class='page-header__title")
    radical["text"] = element

    # for chars in radical
    for c in html_get_elements(html, 0, "li", "class='character-grid__item character-grid__item--kanji"):
        char = get_char_grid_item(c)
        kanji.append(char)
    
    radical["kanji"] = kanji

    return radical


def get_kanji(html : str):
    kanji = {}
    radicals = []
    readings = []
    vocabulary = []

    # get level
    element = html_get_element_content(html, 0, "a", "class=\"page-header__icon page-header__icon--level\"")
    kanji["level"] = element

    # get char
    element = html_get_element_content(html, 0, "span", "class=\"page-header__icon page-header__icon--kanji\"")
    kanji["char"] = element

    # get meanings and type
    meanings = html_get_elements(html, 0, "div", "class='subject-section__meanings'")
    primary = html_get_element_content(meanings[0], 0, "p")

    if len(meanings) == 1:
        kanji["meanings"] = [primary]
    else:
        alternatives = html_get_element_content(meanings[1], 0, "p")
        kanji["meanings"] = [primary] + alternatives.split(", ")

    # for radicals in kanji
    for r in html_get_elements(html, 0, "li", "class='components-list__item components-list__item--radical"):
        component = get_component_list_item(r)
        radicals.append(component[2])

    kanji["radicals"] = radicals

    # for readings in kanji
    for r in html_get_elements(html, 0, "div", "class=\"subject-readings__reading"):
        title = html_get_element_content(r, 0, "h3").replace("\n", "")
        items = html_get_element_content(r, 0, "p").replace("\n", "")
        items = re.sub("\s+", "", items)
        items = re.sub("\s+$", "", items)
        items = items.split(",")
        primary = r.find("--primary")
        readings.append([title, items, primary != -1])

    kanji["readings"] = readings

    # for chars in kanji
    for c in html_get_elements(html, 0, "li", "class='character-grid__item character-grid__item--vocabulary"):
        char = get_char_grid_item(c)
        vocabulary.append(char)
    
    kanji["vocabulary"] = vocabulary

    return kanji


def get_vocabulary(html : str):
    vocabulary = {}
    kanji = []

    # get level
    element = html_get_element_content(html, 0, "a", "class=\"page-header__icon page-header__icon--level\"")
    vocabulary["level"] = element

    # get text
    element = html_get_element_content(html, 0, "span", "class=\"page-header__icon page-header__icon--vocabulary\"")
    vocabulary["char"] = element

    # get meanings and type
    meanings = html_get_elements(html, 0, "div", "class='subject-section__meanings'")
    primary = html_get_element_content(meanings[0], 0, "p")
    alternatives = html_get_element_content(meanings[1], 0, "p")

    if html_get_element_content(meanings[1], 0, "h2") == "Word Type":
        vocabulary["meanings"] = [primary]
        type = alternatives
    else:
        vocabulary["meanings"] = [primary] + alternatives.split(", ")
        type = html_get_element_content(meanings[2], 0, "p")

    vocabulary["type"] = type.split(", ")

    # get romaji
    element = html_get_element_content(html, 0, "div", "class=\"reading-with-audio__reading")
    vocabulary["reading"] = element

    # for chars in vocabulary
    for c in html_get_elements(html, 0, "li", "class='character-grid__item character-grid__item--kanji"):
        char = get_char_grid_item(c)
        kanji.append(char)
    
    vocabulary["kanji"] = kanji

    return vocabulary


def get_chars(html : str):
    chars = []

    # for levels in html
    for l in html_get_elements(html, 0, "section", "class=\"character-grid"):
        start = l.find("id='level-") + 10
        end = l.find("'", start)
        level = int(l[start : end])

        # for chars in level
        for c in html_get_elements(l, 0, "li", "class='character-grid__item character-grid__item"):
            char = get_char_grid_item(c)
            char.insert(0, str(level))
            chars.append(char)

    return chars


def my_list_str(list : list):
    pass


radical_urls = [
    "https://www.wanikani.com/radicals?difficulty=pleasant",
    "https://www.wanikani.com/radicals?difficulty=painful",
    "https://www.wanikani.com/radicals?difficulty=death",
    "https://www.wanikani.com/radicals?difficulty=hell",
    "https://www.wanikani.com/radicals?difficulty=paradise",
    "https://www.wanikani.com/radicals?difficulty=reality"
]

kanji_urls = [
    "https://www.wanikani.com/kanji?difficulty=pleasant",
    "https://www.wanikani.com/kanji?difficulty=painful",
    "https://www.wanikani.com/kanji?difficulty=death",
    "https://www.wanikani.com/kanji?difficulty=hell",
    "https://www.wanikani.com/kanji?difficulty=paradise",
    "https://www.wanikani.com/kanji?difficulty=reality"
]

vocabulary_urls = [
    "https://www.wanikani.com/vocabulary?difficulty=pleasant",
    "https://www.wanikani.com/vocabulary?difficulty=painful",
    "https://www.wanikani.com/vocabulary?difficulty=death",
    "https://www.wanikani.com/vocabulary?difficulty=hell",
    "https://www.wanikani.com/vocabulary?difficulty=paradise",
    "https://www.wanikani.com/vocabulary?difficulty=reality"
]

# Creating a PoolManager instance for sending requests.
http = urllib3.PoolManager()

file = open("c:/users/nicke/desktop/radicals.json", "wt", encoding="utf-8")
file.write("[\n")

for url in radical_urls:
    while True:
        # Sending a GET request and getting back response as HTTPResponse object.
        resp : urllib3.HTTPResponse = http.request("GET", url)
        time.sleep(0.33)

        if (resp.status == 200):
            print("request successful", url)
            break
        
        print("request failed", url)
    
    html = str(resp.data, encoding="utf-8")
    text : str = ""
    resp.close()

    for c in get_chars(html):
        text += "\t["
        text += c[0] + ", "
        text += "\"" + c[2] + "\", "
        text += "\"" + c[4] + "\"],\n"
    
    file.write(text)

file.seek(file.tell() - 3)
file.write("\n]\n")
file.close()

file = open("c:/users/nicke/desktop/kanji.json", "wt", encoding="utf-8")
file.write("[\n")

for url in kanji_urls:
    while True:
        # Sending a GET request and getting back response as HTTPResponse object.
        resp : urllib3.HTTPResponse = http.request("GET", url)
        time.sleep(0.33)

        if (resp.status == 200):
            print("request successful", url)
            break
        
        print("request failed", url)
    
    html = str(resp.data, encoding="utf-8")
    text : str = ""
    resp.close()

    for c in get_chars(html):
        text += "\t["
        text += c[0] + ", "
        text += "\"" + c[2] + "\", "
        text += "\"" + c[3] + "\", "
        text += "\"" + c[4] + "\"],\n"
    
    file.write(text)

file.seek(file.tell() - 3)
file.write("\n]\n")
file.close()

file = open("c:/users/nicke/desktop/vocabulary.json", "wt", encoding="utf-8")
file.write("[\n")

for url in vocabulary_urls:
    while True:
        # Sending a GET request and getting back response as HTTPResponse object.
        resp : urllib3.HTTPResponse = http.request("GET", url)
        time.sleep(0.33)

        if (resp.status == 200):
            print("request successful", url)
            break
        
        print("request failed", url)
    
    html = str(resp.data, encoding="utf-8")
    text : str = ""
    resp.close()

    for c in get_chars(html):
        text += "\t["
        text += c[0] + ", "
        text += "\"" + c[2] + "\", "
        text += "\"" + c[3] + "\", "
        text += "\"" + c[4] + "\"],\n"
    
    file.write(text)

file.seek(file.tell() - 3)
file.write("\n]\n")
file.close()

file = open("c:/users/nicke/desktop/kanji-complete.json", "wt", encoding="utf-8")
file.write("[\n")

for url in kanji_urls:
    while True:
        # Sending a GET request and getting back response as HTTPResponse object.
        resp : urllib3.HTTPResponse = http.request("GET", url)
        time.sleep(0.33)

        if (resp.status == 200):
            print("request successful", url)
            break
        
        print("request failed", url)
    
    html = str(resp.data, encoding="utf-8")
    text : str = ""
    resp.close()

    for c in get_chars(html):
        while True:
            # Sending a GET request and getting back response as HTTPResponse object.
            resp : urllib3.HTTPResponse = http.request("GET", c[1])
            time.sleep(0.33)

            if (resp.status == 200):
                print("request successful", c[1])
                break
        
            print("request failed", resp.status, url)

        k = get_kanji(str(resp.data, encoding="utf-8"))
        resp.close()
        
        meanings = []
        readings = []
        radicals = []

        for m in k["meanings"]:
            meanings.append("\"" + m + "\"")

        for r in k["readings"]:
            readings_txt = ", ".join("\"{}\"".format(i) for i in r[1])
            readings.append("\t\t\t[\"{}\", [{}], \"{}\"]".format(r[0], readings_txt, r[2]))

        for r in k["radicals"]:
            radicals.append("\"" + r + "\"")
        
        text += "\t[\n"
        text += "\t\t" + k["level"] + ",\n"
        text += "\t\t\"" + k["char"] + "\",\n"
        text += "\t\t[" + ", ".join(meanings) + "],\n"
        text += "\t\t[\n" + ",\n".join(readings) + "\n\t\t],\n"
        text += "\t\t[" + ", ".join(radicals) + "]\n"
        text += "\t],\n"
    
    file.write(text)

file.seek(file.tell() - 3)
file.write("\n]\n")
file.close()

file = open("c:/users/nicke/desktop/vocabulary-complete.json", "wt", encoding="utf-8")
file.write("[\n")

for url in vocabulary_urls:
    while True:
        # Sending a GET request and getting back response as HTTPResponse object.
        resp : urllib3.HTTPResponse = http.request("GET", url)
        time.sleep(0.33)

        if (resp.status == 200):
            print("request successful", url)
            break
        
        print("request failed", url)
    
    html = str(resp.data, encoding="utf-8")
    text : str = ""
    resp.close()

    for c in get_chars(html):
        while True:
            # Sending a GET request and getting back response as HTTPResponse object.
            resp : urllib3.HTTPResponse = http.request("GET", c[1])
            time.sleep(0.33)

            if (resp.status == 200):
                print("request successful", c[1])
                break
        
            print("request failed", resp.status, c[1])
    
        v = get_vocabulary(str(resp.data, encoding="utf-8"))
        resp.close()
        
        meanings = []
        types = []

        for m in v["meanings"]:
            meanings.append("\"" + m + "\"")

        for t in v["type"]:
            types.append("\"" + t + "\"")

        text += "\t[\n"
        text += "\t\t" + v["level"] + ",\n"
        text += "\t\t\"" + v["char"] + "\",\n"
        text += "\t\t[" + ", ".join(meanings) + "],\n"
        text += "\t\t[" + ", ".join(types) + "],\n"
        text += "\t\t\"" + v["reading"] + "\"\n"
        text += "\t],\n"
    
    file.write(text)

file.seek(file.tell() - 3)
file.write("\n]\n")
file.close()
