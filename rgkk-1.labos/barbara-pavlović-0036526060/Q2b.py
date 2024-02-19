from sys import exit
from bitcoin.core.script import *

from lib.utils import *
from lib.config import (my_private_key, my_public_key, my_address,
                    faucet_address, network_type)
from Q1 import P2PKH_scriptPubKey
from Q2a import Q2a_txout_scriptPubKey


######################################################################
# TODO: postavite parametre transakcije
# amount_to_send = {cjelokupni iznos BTC-a u UTXO-u kojeg saljemo} - {fee}
amount_to_send = 0.000012-0.000008
txid_to_spend = (
        '48fed261a679805a2a761164b82bcfb86f92e9c712bd6a97ad2438fea27411c8')
# indeks UTXO-a unutar transakcije na koju se referiramo
# (indeksi pocinju od nula)
utxo_index = 0
######################################################################

txin_scriptPubKey = Q2a_txout_scriptPubKey
######################################################################
# TODO: implementirajte skriptu `scriptSig` kojom cete otkljucati BTC zakljucan
# pomocu skripte `scriptPubKey` u zadatku 2a
txin_scriptSig = [
    3048,
    -3012
]
######################################################################
txout_scriptPubKey = P2PKH_scriptPubKey(faucet_address)

response = send_from_custom_transaction(
    amount_to_send, txid_to_spend, utxo_index,
    txin_scriptPubKey, txin_scriptSig, txout_scriptPubKey, network_type)
print(response.status_code, response.reason)
print(response.text)
