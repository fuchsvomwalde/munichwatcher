# coding: utf-8

from BeautifulSoup import BeautifulSoup
import urllib2
import re
import datetime
import json
import geopy
import os
import base64
import cPickle as pickle
from geopy.distance import distance


def b64url(url):
    if not os.path.exists("html_data"):
        os.mkdir("html_data")

    return os.path.normpath(os.path.join("html_data", base64.b64encode(url)[-20:] + ".html"))


def get_soup(url, fetch=False):
    """
    get the beautiful soup from an URL
    :param url:
    :param fetch:
    :return:
    """

    if fetch:
        response = urllib2.urlopen(url)
        html = response.read()

    else:
        with open(b64url(url), "r") as f:
            html = f.read()

    soup = BeautifulSoup(html)

    if fetch:
        try:
            with open(b64url(url), "w") as f:
                f.write(html)
        except IOError:
            print "IOError"
            pass

    return soup


def parse_summary(url, incidents, fetch=False):
    """
    grab links to each "pressebericht" from overview page
    :param url:
    :return:
    """

    soup = get_soup(url, fetch)

    detail_links = [(l.get("title"), l.get("href"))
                    for l in soup.findAll("a", {"class": "inhaltDetaillink"})]

    for l in detail_links:
        parse_report(*l, incidents=incidents, fetch=fetch)

json_fname = "incidents.json"


def fetch_reports(fetch=False):
    """get overview pages from search form"""
    m_search_tmpl = 'http://www.polizei.bayern.de/muenchen/news/presse/archiv/index.html?query=m%C3%BCnchen%20pressebericht&type=archiv&rubid=rub-4&period=select&periodto=&periodselect=All&periodfrom=&start={}'

    del_files = ["crimes.txt", json_fname]

    for f in del_files:
        if os.path.exists(f):
            os.remove(f)

    incidents = []

    # all data is up to 34
    for i in range(34):
    #for i in range(1):
        url = m_search_tmpl.format(i*10)
        parse_summary(url, incidents, fetch)

    pickle.dump( incidents, open(json_fname + "pickle", "wb"))

    with open(json_fname, "w") as f:
        f.write(json.dumps(incidents, sort_keys=True,
                           indent=4, separators=(',', ': '),
                           #encoding="utf-8", ensure_ascii=False)
                           ))
    #print incidents

crime_categories = {u"Raub": [u"raub",
                              u"räub"],
                    u"Diebstahl": ["Dieb",
                                   "Diebin",
                                   "Eigentumsdelikt",
                                   "einbruch",
                                   "einbrech",
                                   "stiehl",
                                   "stehl"],
                    u"Sexuelle Gewalt": ["vergewalt",
                                         "sexuell",
                                         u"sexuelle Nötigung"],
                    u"Körperverletzung": [u"körperverl",
                                          "schlag",
                                          u"schlägerei",
                                          "attackier"]}

crime_excludes = ["Terminhinweis", "herzlich", "eingeladen", "Hubschrauber"]

def extract_date(text):
    """
    exctract first found date
    :param text:
    :return:
    """
    patn = re.compile("\d{2}.\d{2}.\d{4}")
    for match in patn.findall(text):
        #print "found date:", match
        date = datetime.datetime.strptime(match, "%d.%m.%Y")
        return str(date.date())

    return False


def extract_address(text, title):
    """
    Try to find the street
    :param text:
    :return:
    """
    streets = []

    addr = None

    # load munich streetnames
    with open("streetnames.txt", "r") as f:
        for street in f:
            streets.append(street.decode("utf-8").strip())

    # check if one of the streetnames of munich is found in the text
    for street in streets:
        if street.replace(u"aße", "") in text:
            addr = street

    # no streetname found, try to get the district out of the title
    if not addr:
        if u"\u2013" in title:
            addr = title.split(u"\u2013")[-1]
        elif "-" in title:
            addr = title.split("-")[-1]
        elif "in" in title:
            addr = title.split("in")[-1]

    if addr:
        lat, lon, address = translate_address(u"München " + addr, True)
    else:
        lat, lon = 0, 0

    return lat, lon, addr


def parse_report(title, url, incidents=None, fetch=False):
    soup = get_soup("http://www.polizei.bayern.de/" + url, fetch)

    if incidents is None:
        incidents = []

    article_headings = soup.findAll("div",
                                    {"class": "inhaltUeberschriftFolgeseiten2"})
    for head in article_headings:
        #print head
        text_field = head.nextSibling.nextSibling
        #print text_field

        head_title = head.text
        full_text = text_field.text

        # clean up title
        try:
            head_title = head_title.split("\t", 1)[1]
        except IndexError:
            pass

        # remove leading 1234.
        try:
            int(head_title.split(".", 1)[0])
            head_title = head_title.split(".", 1)[1]
        except ValueError:
            pass

        # remove leading 1234:
        try:
            int(head_title.split(".", 1)[0])
            head_title = head_title.split(".", 1)[1]
        except ValueError:
            pass

        head_title = head_title.strip()

        skip_article = False

        for excl in crime_excludes:
            if excl.lower() in head_title.lower() \
                    or excl.lower() in full_text.lower():
                skip_article = True

                print u"Skip article, exclude ({:s}): {:s} ".format(excl, head_title)
                break

        if skip_article:
            continue

        # go through all crime categories
        for cat, values in crime_categories.items():

            for search_val in values:

                # check if one value of a category is in text or heading
                if search_val in head_title.lower() \
                        or search_val in full_text.lower():
                    date = extract_date(full_text)
                    lat, lon, addr = extract_address(full_text, head_title)

                    if lat and lon and date:

                        outstr = u"{}\t{}\t{}\t{}\n".format(cat, date, addr,
                                                            head_title)

                        if not head_title:
                            print "ERROOOOOR no head_title", head.text

                        incident = {"title": head_title.encode("utf-8"),
                                    "time": date.encode("utf-8"),
                                    "type": cat.encode("utf-8"),
                                    "lat": lat,
                                    "lng": lon,
                                    "adress": addr,
                                    "full_text": full_text}

                        with open("crimes.txt", "a") as f:
                            f.write(outstr.encode("utf-8"))

                        incidents.append(incident)

                    else:
                        skip_article = True
                        if not addr:
                            print "Skip article no street found", head_title
                        if not date:
                            print "Skip article no date found", head_title

                    break

            if skip_article:
                break


def get_munich_streetnames():
    """
    get a list with all munich streetnames
    :return:
    """

    streetnames = []
    for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":

        soup = get_soup("http://stadt-muenchen.net/strassen/index.php?name={}".format(char), fetch=True)
        tsoup = soup.find("table", {"class": "full"})
        for row in tsoup.findAll("tr"):
            if row.find("th"):
                continue

            street = row.find("td").text

            # exclude Street "Grund"
            if street not in ["Grund"]:
                streetnames.append(street)

    with open("streetnames.txt", "w") as f:
        f.write(u"\n".join(streetnames).encode("utf-8"))

    return streetnames


def convert_min_sec_to_lat_lon(sec_lat, sec_long):

    def conversion(old):
        direction = {'N': 1,
                     'S': -1,
                     'E': 1,
                     'W': -1}
        new = old.replace(u'°', ' ').replace('\'', ' ').replace('"', ' ').replace("`", "").replace(u"\u2032", "")
        new = new.split()
        #print "new coords", new, direction

        if not new:
            print "got no coordinates"
            return 0

        new_dir = new.pop()

        return (float(new[0])+float(new[1])/60.0+float(new[2])/3600.0) * direction[new_dir]

    return conversion(sec_lat),  conversion(sec_long)


def translate_address(addr, fetch):

    if fetch:
        geolocator = geopy.Nominatim()
        #geolocator = geopy.GoogleV3()
        location = geolocator.geocode(addr, timeout=10)

        if location is None:
            print "Error, did not find lat,long for addr:", addr
            return 0, 0, ""

        # with open("lat_lon_cache.txt", "a") as f:
        #     f.write((addr + "\t" + str(location.latitude) + "\t" + str(location.longitude) + "\n").encode("utf-8"))

        lat = location.latitude
        lon = location.longitude

        munich = 48.1372719, 11.5754815
        d = distance(munich, (lat, lon)).kilometers

        # check if it is in munich range
        km_distance = 20
        if d > km_distance:
            print u"Error, location {} more than {}km away from munich ({}km)".format(addr, km_distance, d)

            lat, lon = 0, 0

        return float(lat), float(lon), location.address
    else:
        with open("lat_lon_cache.txt", "r") as f:

            for l in f:
                if addr in l:
                    return l.split("\t")[1], l.split("\t")[2]


def add_cam_lat_lon():

    #cam_fname = "cameradata.json"
    cam_fname = "camdataUbahnPR"

    with open(cam_fname, "r") as f:
        #dat = _to_unicode(f.read())
        dat = f.read()

        #data = json.loads(dat.decode("utf-8"), encoding="utf-8")
        data = json.loads(dat)
        #data = smpljson.loads(dat)
        #data = json.loads(dat.decode("utf-8"))

        #print dat
        #print data
        #return
        #data = json.loads(f.read(), encoding="utf-8")

    new_dat = []
    for d in data:

        if d["lat"] and d["lng"]:
            #addr = d["lat"] + d["lng"]
            lat, lng = convert_min_sec_to_lat_lon(d["lat"], d["lng"])

            d["lat"] = lat
            d["lng"] = lng
            #g = geopy.Nominatim()
            # print "reverse addr:", g.reverse((lat, lng))
            # addr = "{}, {}".format(lat, lng)

            if not d["adress"]:
                if "U-Bahnhof" in d["owner"]:
                    #print "set Ubahn adress to", d["owner"]
                    d["adress"] = d["owner"]
            new_dat.append(d)
        else:

            # skip
            #if not d["adress"]:
            #    continue

            addr = u"München " + d["adress"]

            #print d
            try:
                #print d["adress"]
                lat, lng, address = translate_address(addr, True)
                d["lat"] = lat
                d["lng"] = lng

                if not d["adress"]:
                    print "no address but owner:", d
                new_dat.append(d)
            except AttributeError:
                print "Error:", d

    #print data

    with open("lat_lng_" + cam_fname, "w") as f:
        f.write(json.dumps(new_dat, sort_keys=True,
                           indent=4, separators=(',', ': ')))


def pickle_to_json(fname):
    incidents = pickle.load(open(fname, "rb"))

    with open(json_fname, "w") as f:
        f.write(json.dumps(incidents, sort_keys=True,
                           indent=4, separators=(',', ': '),
                           #encoding="utf-8", ensure_ascii=False
        ))



if __name__ == '__main__':

    #pickle_to_json("incidents.jsonpickle")
    #get_munich_streetnames()
    #fetch_reports(fetch=True)
    add_cam_lat_lon()

# TODO dump htmls only once to work offline
# TODO fix "Grund
#    -> removed due to wrong data