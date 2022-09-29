// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./KCCoin.sol";

contract ICO is KCToken {
    address public manager;
    address payable public deposit;

    uint tokenprice = 0.1 ether;
    uint public cap = 300 ether;
    uint public raisedAmount;

    uint public icoStart = block.timestamp;
    uint public icoEnd = block.timestamp + 3600;

    uint public tokenTradeTime = icoEnd + 3600;

    uint public maxInvest = 10 ether;
    uint public minInvest = 0.1 ether;

    enum State{beforeStart,afterEnd,running,halted}
    State public icoState;

    event Invest(address investor, uint value, uint tokens);

    constructor(address payable _deposit){
        deposit = _deposit;
        manager = msg.sender;
        icoState = State.beforeStart;
    }

    modifier onlyManager(){
        require(msg.sender==manager);
        _;
    }

    function halt() public onlyManager {
        icoState = State.halted;
    }

    function resume() public onlyManager {
        icoState = State.running;
    }

    function changeDepositAddr(address payable newDeposit) public onlyManager {
        deposit = newDeposit;
    }

    function getState() public view returns(State) {
        if(icoState==State.halted) {
            return State.halted;
        }else if(block.timestamp<icoStart) {
            return State.beforeStart;
        }else if(block.timestamp>=icoStart && block.timestamp<=icoEnd) {
            return State.running;
        }else {
            return State.afterEnd;
        }
    }

    function invest() public payable returns(bool) {
        icoState=getState();
        require(icoState==State.running);
        require(msg.value>=minInvest && msg.value<=maxInvest);

        raisedAmount+=msg.value;
        require(raisedAmount <= cap);

        uint tokens = msg.value/tokenprice;
        balances[msg.sender]+=tokens;
        balances[founder]-=tokens;
        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);
        return true;
    }

    function burnTokens() public onlyManager returns(bool) {
        icoState=getState();
        require(icoState==State.afterEnd);
        balances[founder]=0;
        return true;
    }

    function transfer(address to, uint tokens) public override returns(bool success) {
         require(block.timestamp>tokenTradeTime);
         super.transfer(to,tokens);
         return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns(bool success) {
        require(block.timestamp>tokenTradeTime);
        super.transferFrom(from,to,tokens);
        return true;
    }

    receive() external payable {
        invest();
    }

}