from sys import exit
from bitcoin.core.script import *
from bitcoin.wallet import CBitcoinSecret

from lib.utils import *
from lib.config import (my_private_key, my_public_key, my_address,
                        faucet_address, network_type)
from Q1 import send_from_P2PKH_transaction


# Generirajte privatne kljuceve od klijenata koristeci `lib/keygen.py`
# i dodajte ih ovdje.
cust1_private_key = CBitcoinSecret(
    'cVo6GJVumuXkR9LTzGzLFdQvsqag79ULY62jKpgjpdcZW9cYFnpu')
cust1_public_key = cust1_private_key.pub
cust2_private_key = CBitcoinSecret(
    'cUxosVpDQyNy85YCycAw7ugaLgHUkTHAkZdojqaR9pj8LGzbG8Sg')
cust2_public_key = cust2_private_key.pub
cust3_private_key = CBitcoinSecret(
    'cUukxGmivUbWDwgzDzLhLin3rW7ut6nfCtdkaKys3EtKRuFeYmfD')
cust3_public_key = cust3_private_key.pub
mypublic = my_private_key.pub


######################################################################
# TODO: Implementirajte `scriptPubKey` za zadatak 3

# Pretpostavite da vi igrate ulogu banke u ovom zadatku na nacin da privatni
# kljuc od banke `bank_private_key` odgovara vasem privatnom kljucu
# `my_private_key`.

Q3a_txout_scriptPubKey = [
    mypublic,
    OP_CHECKSIGVERIFY,
    OP_1,
    cust1_public_key,
    cust2_public_key,
    cust3_public_key,
    OP_3,
    OP_CHECKMULTISIG
]
######################################################################

if __name__ == '__main__':
    ######################################################################
    # TODO: postavite parametre transakcije
    # amount_to_send = {cjelokupni iznos BTC-a u UTXO-u kojeg otkljucavamo} - {fee}
    amount_to_send = 0.00002 - 0.000008
    txid_to_spend = (
        'f795a521d165aa46f274d2c47badb4cff39ee86d1297b54c99c5beb53d540adc')
    # indeks UTXO-a unutar transakcije na koju se referiramo
    # (indeksi pocinju od nula)
    utxo_index = 5
    ######################################################################

    response = send_from_P2PKH_transaction(amount_to_send, txid_to_spend,
                                           utxo_index, Q3a_txout_scriptPubKey,
                                           my_private_key, network_type)
    print(response.status_code, response.reason)
    print(response.text)
