// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Auction.sol";

contract EnglishAuction is Auction {

    uint internal highestBid;
    uint internal initialPrice;
    uint internal biddingPeriod;
    uint internal lastBidTimestamp;
    uint internal minimumPriceIncrement;
    uint internal endOfAuction;

    address internal highestBidder;

    constructor(
        address _sellerAddress,
        address _judgeAddress,
        Timer _timer,
        uint _initialPrice,
        uint _biddingPeriod,
        uint _minimumPriceIncrement
    ) Auction(_sellerAddress, _judgeAddress, _timer) {
        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;

        // Start the auction at contract creation.
        lastBidTimestamp = time();
        highestBid = 0;
        endOfAuction = lastBidTimestamp+biddingPeriod;
    }

    function bid() public payable {
        // TODO Your code here
        require(time()<lastBidTimestamp+biddingPeriod, "You can bid only for a certain period after the last bidding");
        require(msg.value>=initialPrice, "The bid must at least be higher than the initial price");
        require((msg.value-highestBid)>=minimumPriceIncrement, "The increment must be above minimum");

        if(highestBid>0) {
            payable(highestBidder).transfer(highestBid);
        }
        highestBid = msg.value;
        lastBidTimestamp = time();
        highestBidder = msg.sender;

        outcome = Outcome.SUCCESSFUL;
    }

    function getHighestBidder() override public returns (address) {

        if(highestBidder == address(0) || time()<lastBidTimestamp+biddingPeriod) {
            highestBidderAddress = address(0);
        } else {
            highestBidderAddress = highestBidder;
        }

        return highestBidderAddress;
    }

    function enableRefunds() public {
        // TODO Your code here
        require(time()>=lastBidTimestamp+biddingPeriod, "The bidding period must be over for refunds");
        if(initialPrice>highestBid) {
            outcome = Outcome.NOT_SUCCESSFUL;
        }
        highestBidderAddress = msg.sender;
    }

}