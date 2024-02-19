// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BoxOracle.sol";

contract Betting {

    struct Player {
        uint8 id;
        string name;
        uint totalBetAmount;
        uint currCoef; 
    }
    struct Bet {
        address bettor;
        uint amount;
        uint player_id;
        uint betCoef;
    }

    address private betMaker;
    BoxOracle public oracle;
    uint public minBetAmount;
    uint public maxBetAmount;
    uint public totalBetAmount;
    uint public thresholdAmount;

    uint public sumOfElements;

    Bet[] private bets;
    Player public player_1;
    Player public player_2;

    bool private suspended = false;
    uint private winnerAmount = 0;
    bool private amountCalculated = false;
    bool private checked = false;
    mapping (address => uint) public balances;
    
    constructor(
        address _betMaker,
        string memory _player_1,
        string memory _player_2,
        uint _minBetAmount,
        uint _maxBetAmount,
        uint _thresholdAmount,
        BoxOracle _oracle
    ) {
        betMaker = (_betMaker == address(0) ? msg.sender : _betMaker);
        player_1 = Player(1, _player_1, 0, 200);
        player_2 = Player(2, _player_2, 0, 200);
        minBetAmount = _minBetAmount;
        maxBetAmount = _maxBetAmount;
        thresholdAmount = _thresholdAmount;
        oracle = _oracle;

        totalBetAmount = 0;
        sumOfElements = 0;
    }

    receive() external payable {}

    fallback() external payable {}

    event player1Coef(uint coef);
    
    function makeBet(uint8 _playerId) public payable {
        
        require(oracle.getWinner()==0, "Winner must not yet exist");
        require(msg.sender!=betMaker, "Bet maker cannot make bets");
        require(msg.value>= minBetAmount && msg.value<=maxBetAmount, 
        "Betting value must be between minimum and maximum");
        require(_playerId==1 || _playerId==2, "Player id can be only 1 or 2");

        Player memory player;
    
        if(_playerId==1) {
            player_1.totalBetAmount+=msg.value;
            player = player_1;
        } else {
            player_2.totalBetAmount+=msg.value;
            player = player_2;
        }

        bets.push(Bet(msg.sender,msg.value,_playerId, player.currCoef));

        totalBetAmount+=msg.value;

        if(totalBetAmount > thresholdAmount) { 

            if((player_1.totalBetAmount == 0 || player_2.totalBetAmount ==0)) {

                if(checked == false) {

                    suspended = true;
                    checked = true;
                }

            }  else {       

                player_1.currCoef = ((player_1.totalBetAmount+player_2.totalBetAmount)*100)/player_1.totalBetAmount;
                
                emit player1Coef(player_1.currCoef);

                player_2.currCoef = ((player_1.totalBetAmount+player_2.totalBetAmount)*100)/player_2.totalBetAmount;

            }   
        }

        balances[msg.sender]+=msg.value;


    }

    function claimSuspendedBets() public {
        require(suspended==true, "The bet must be suspended");
        require(msg.sender!=betMaker, "Bet maker cannot claim suspended bets");

        payable(msg.sender).transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
    }

    function claimWinningBets() public {
        require(suspended==false, "Bet must not be suspended");
        require(oracle.getWinner()==1 || oracle.getWinner()==2, "Winner must exist");

        uint256 winner = oracle.getWinner();

        uint256 total = 0;

        if(amountCalculated==false){
            getWinningAmount();
            amountCalculated=true;
        }

        for (uint256 i = 0; i < bets.length; i++) {

            if(bets[i].bettor == msg.sender && bets[i].player_id == winner) {

                uint investment = bets[i].amount;
                total+=(investment * bets[i].betCoef)/100;

                winnerAmount-=investment;

            } else {
                sumOfElements+=1;
            }

        }

        payable(msg.sender).transfer(total);
    }

    function claimLosingBets() public {
        require(oracle.getWinner()==1 || oracle.getWinner()==2, "Winner must exist");
        require(msg.sender == betMaker, "Only bet maker can claim losing bets");
        require(winnerAmount==0, "All winning bets must be paid out");

        payable(msg.sender).transfer(address(this).balance);
    }

    function getWinningAmount() public {
        
        for (uint256 i = 0; i < bets.length; i++) {

            uint winner = oracle.getWinner();

            if(bets[i].player_id == winner) {

                winnerAmount+=bets[i].amount;
            } 

        }
    }

}