#!/usr/bin/env python

import codecs
import json
import re
import urllib.request

def get_only_in_map(map):
    return next(iter(map.values()))

def get_link(from_lang, site, article, to_lang):
    url = 'https://%s.%s.org/w/api.php?action=query&continue&format=json&prop=langlinks&titles=%s&lllang=%s' % (from_lang, site, urllib.parse.quote(article), to_lang)

    h = urllib.request.urlopen(url)
    uft8reader = codecs.getreader("utf-8")
    j = json.load(uft8reader(h))

    n = get_only_in_map(j['query']['pages'])['langlinks'][0]['*']

    return 'https://%s.%s.org/wiki/%s' % (to_lang, site, n)

def get_article(url):
    m = re.search(r'https?://(..)\.(.*)\.org/wiki/(.*)', url)
    return (m.group(1), m.group(2), m.group(3))

def to_lang(from_lang):
    return 'fr' if from_lang == 'en' else 'en'

(from_lang, site, article) = get_article(input())
print(get_link(from_lang, site, article, to_lang(from_lang)))

