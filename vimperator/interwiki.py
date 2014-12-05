#!/usr/bin/env python

import codecs
import json
import re
import urllib.request
import sys

def get_only_in_map(map):
    return next(iter(map.values()))

wikipedia_re = r'https?://..\.wikipedia.org/wiki/.*'
wiktionary_re = r'https?://..\.wiktionary.org/wiki/.*'
def wiki(url):
    def get_article(url):
        m = re.search(r'https?://(..)\.(.*)\.org/wiki/(.*)', url)
        return (m.group(1), m.group(2), m.group(3))

    def lang(from_lang):
        return 'fr' if from_lang == 'en' else 'en'

    def get_link(from_lang, site, article):
        to_lang = lang(from_lang)
        url = 'https://%s.%s.org/w/api.php?action=query&continue&format=json&prop=langlinks&titles=%s&lllang=%s' % (from_lang, site, urllib.parse.quote(article), to_lang)

        h = urllib.request.urlopen(url)
        uft8reader = codecs.getreader("utf-8")
        j = json.load(uft8reader(h))

        n = get_only_in_map(j['query']['pages'])['langlinks'][0]['*']

        return 'https://%s.%s.org/wiki/%s' % (to_lang, site, n)

    (from_lang, site, article) = get_article(url)
    return get_link(from_lang, site, article)

xkcd_re = r'https?://xkcd.com/.*'
def xkcd(url):
    number = re.search(r'https?://xkcd.com/(.*)/', url)

    if number:
        return 'http://explainxkcd.com/%s/' % (number.group(1))
    else:
        return 'http://explainxkcd.com/'

boost_re = r'http://www.boost.org/doc/libs/.*'
def boost(url):
    what = re.match(r'http://www.boost.org/doc/libs/[\d_]*/(.*)', url)

    return 'http://www.boost.org/doc/libs/release/' + what.group(1)

python_re = r'https?://docs.python.org/.*'
def python(url):
    version = sys.version_info
    what = re.match(r'https?://docs.python.org/[\d.]*/(.*)', url)

    return 'https://docs.python.org/%s.%s/%s' % (version[:2] + (what.group(1),))

map = {
    wikipedia_re: wiki,
    wiktionary_re: wiki,
    xkcd_re: xkcd,
    boost_re: boost,
    python_re: python,
}

url = input()
for expr in map:
    if re.search(expr, url):
        print(map[expr](url))

