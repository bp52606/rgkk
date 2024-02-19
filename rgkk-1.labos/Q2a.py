from sys import exit
from bitcoin.core.script import *

from lib.utils import *
from lib.config import (my_private_key, my_public_key, my_address,
                        faucet_address, network_type)
from Q1 import send_from_P2PKH_transaction

# znamenke JMBAG-a

# prve 4 = 0036
# zadnje 4 = 6060

######################################################################
# TODO: Implementirajte `scriptPubKey` za zadatak 2
Q2a_txout_scriptPubKey = [
    OP_2DUP,
    OP_ADD,
    36,
    OP_EQUALVERIFY,
    OP_SUB,
    6060,
    OP_EQUAL
]
######################################################################

if __name__ == '__main__':
    ######################################################################
    # TODO: postavite parametre transakcije
    # amount_to_send = {cjelokupni iznos BTC-a u UTXO-u kojeg saljemo} - {fee}
    amount_to_send = 0.00002 - 0.000008
    txid_to_spend = (
        'f795a521d165aa46f274d2c47badb4cff39ee86d1297b54c99c5beb53d540adc')
    # indeks UTXO-a unutar transakcije na koju se referiramo
    # (indeksi pocinju od nula)
    utxo_index = 2
    ######################################################################

    response = send_from_P2PKH_transaction(
        amount_to_send, txid_to_spend, utxo_index,
        Q2a_txout_scriptPubKey, my_private_key, network_type)
    print(response.status_code, response.reason)
    print(response.text)
