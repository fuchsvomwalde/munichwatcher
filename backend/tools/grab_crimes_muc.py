# coding: utf-8

from BeautifulSoup import BeautifulSoup
import urllib2
import re
import datetime
import json
from geopy.geocoders import Nominatim
import os

def get_soup(url):
    response = urllib2.urlopen(url)
    html = response.read()
    soup = BeautifulSoup(html)
    return soup


def parse_summary(url, incidents):
    """
    grab links to each "pressebericht" from overview page
    :param url:
    :return:
    """
    soup = get_soup(url)
    #print parsed_html.findAll("h1", {"class":"inhaltUeberschriftFolgenderAbschnitt"})[0].contents[0]
    detail_links = [(l.get("title"), l.get("href")) for l in soup.findAll("a", {"class": "inhaltDetaillink"})]


    for l in detail_links:
        #print l[0]
        parse_report(*l, incidents=incidents)
        # url = l[1]


json_fname = "incidents.json"

def fetch_reports():
    """get overview pages from search form"""
    m_search_tmpl = 'http://www.polizei.bayern.de/muenchen/news/presse/archiv/index.html?query=m%C3%BCnchen%20pressebericht&type=archiv&rubid=rub-4&period=select&periodto=&periodselect=All&periodfrom=&start={}'

    if os.path.exists(json_fname):
        os.remove(json_fname)

    incidents = []

    # all data is up to 34
    for i in range(34):
    #for i in range(1):
        url = m_search_tmpl.format(i*10)
        parse_summary(url, incidents)

    with open(json_fname, "w") as f:
        f.write(json.dumps(incidents, sort_keys=True,
                           indent=4, separators=(',', ': '), encoding="utf-8", ensure_ascii=False))
    #print incidents

categories = [u"raub", u"dieb", u"überfall"]


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


def extract_street(text):
    """
    Try to find the street
    :param text:
    :return:
    """
    streets = []
    with open("streetnames.txt", "r") as f:
        for street in f:
            streets.append(street.decode("utf-8").strip())
    for street in streets:

        street = street.replace(u"aße", "")
        if street in text:
            return street

    return False


def parse_report(title, url, incidents=None):
    #print "parsing report:", title
    soup = get_soup("http://www.polizei.bayern.de/" + url)

    if incidents is None:
        incidents = []

    article_headings = soup.findAll("div",
                                    {"class": "inhaltUeberschriftFolgeseiten2"})
    for head in article_headings:
        #print head
        text_field = head.nextSibling.nextSibling
        #print text_field

        for cat in categories:
            if cat in head.text.lower() or cat in text_field.text.lower():
                date = extract_date(text_field.text)
                street = extract_street(text_field.text)

                if street and date:

                    head_title = head.text
                    try:
                        head_title = head_title.split("\t")[1]
                    except IndexError:
                        pass

                    outstr = u"{}\t{}\t{}\t{}\n".format(cat, date, street, head_title)

                    lat, lon = translate_address(street + u" München")
                    incident = {"title": head_title.encode("utf-8"),
                                "time": date.encode("utf-8"),
                                "type": cat.encode("utf-8"),
                                "lat": lat,
                                "lng": lon}

                    with open("crimes.txt", "a") as f:
                        f.write(outstr.encode("utf-8"))

                    print u"Kategorie: {} - Date: {}, Street: {}  {}".format(cat, date, street, head_title)
                    print

                    incidents.append(incident)


def get_munich_streetnames():
    streetnames = []
    for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":

        soup = get_soup("http://stadt-muenchen.net/strassen/index.php?name={}".format(char))
        tsoup = soup.find("table", {"class": "full"})
        for row in tsoup.findAll("tr"):
            if row.find("th"):
                continue

            streetnames.append(row.find("td").text)

    with open("streetnames.txt", "w") as f:
        f.write(u"\n".join(streetnames).encode("utf-8"))
    return streetnames


def translate_address(addr):
    geolocator = Nominatim()
    location = geolocator.geocode(addr)
    #print(location.address)
    #print(location.latitude, location.longitude)
    return location.latitude, location.longitude


if __name__ == '__main__':
    #get_munich_streetnames()


    fetch_reports()

    #translate_address("Dinkelsbühler str. 30, münchen")

