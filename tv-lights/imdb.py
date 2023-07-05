import urllib.parse
import json

import requests
from bs4 import BeautifulSoup

API_KEY = 'ca887d21'

def query_imdb_page(title):
    url = 'http://www.omdbapi.com/?apikey=' + API_KEY + '&t=' + urllib.parse.quote(title)
    print(url)
    result = requests.get(url)
    result_json = json.loads(result.text)
    return result_json['imdbID']

def get_imdb_poster(imdb_id):
    url = 'https://www.imdb.com/title/' + imdb_id

    #
    # user-agent header prevents 403 error
    #
    result = requests.get(url, headers={'user-agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36'})
    if result.status_code == 200:
        soup = BeautifulSoup(result.text, 'html.parser')
        poster = soup.select('a.ipc-lockup-overlay div')
        print(poster)

if __name__ == '__main__':
    imdb_id = query_imdb_page("Brooklyn nine-nine")
    get_imdb_poster(imdb_id)
