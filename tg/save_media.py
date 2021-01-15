#uncomment line below if you need proxy
#import socks
from telethon import TelegramClient, sync
#import logging

import os
import argparse
import re

usage='''
This script will download a telegram channel
'''
parser = argparse.ArgumentParser(usage=usage)

api_id=os.environ.get('TELEGRAM_API_ID')
api_hash=os.environ.get('TELEGRAM_API_HASH')

#logging.basicConfig(level=logging.DEBUG)

client = TelegramClient('test_session123123123',
    api_id, api_hash,
    # You may want to use proxy to connect to Telegram
    #proxy=(socks.SOCKS5, 'PROXYHOST', PORT, 'PROXYUSERNAME', 'PROXYPASSWORD')
)
client.start()
for message in client.iter_messages('CHATNAME/CHANNELNAME/USERNAME'):
    client.download_media(message)
