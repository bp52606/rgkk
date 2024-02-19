// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public priceDecrement;
    uint public currentPrice;

    uint internal auctionEnd;
    uint internal auctionStart;

    /// Creates the DutchAuction contract.
    ///
    /// @param _sellerAddress Address of the seller.
    /// @param _judgeAddress Address of the judge.
    /// @param _timer Timer reference
    /// @param _initialPrice Start price of dutch auction.
    /// @param _biddingPeriod Number of time units this auction lasts.
    /// @param _priceDecrement Rate at which price is lowered for each time unit
    ///                        following linear decay rule.
    constructor(
        address _sellerAddress,
        address _judgeAddress,
        Timer _timer,
        uint _initialPrice,
        uint _biddingPeriod,
        uint _priceDecrement
    )  Auction(_sellerAddress, _judgeAddress, _timer) {
        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        priceDecrement = _priceDecrement;
        auctionStart = time();
        // Here we take light assumption that time is monotone
        auctionEnd = auctionStart + _biddingPeriod;
        currentPrice = initialPrice;
    }

    /// In Dutch auction, winner is the first pearson who bids with
    /// bid that is higher than the current prices.
    /// This method should be only called while the auction is active.
    function bid() public payable {
        // TODO Your code here
        require(this.getAuctionOutcome() == Outcome.NOT_FINISHED, "You can only bid while the auction is active");
        require(time()<auctionEnd, "You can only bid while the auction is active");

        currentPrice = initialPrice-(priceDecrement*(time()-auctionStart));
        require(msg.value>=currentPrice, "You can only bid with a bid that is higher than the current prices");

        highestBidderAddress = msg.sender;
        outcome = Outcome.SUCCESSFUL;
        finishAuction(outcome, highestBidderAddress);

        if(msg.value>currentPrice) {
            payable(msg.sender).transfer(msg.value-currentPrice);
        }
    }

    function enableRefunds() public {
        // TODO Your code here
        require(time()>auctionEnd, "Refunds can be enabled only when the auction is over");
        if(highestBidderAddress==address(0)) {
            outcome = Outcome.NOT_SUCCESSFUL;
        }
        highestBidderAddress = msg.sender;


    }
}