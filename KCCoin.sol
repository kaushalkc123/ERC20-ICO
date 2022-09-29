// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface IERC20 {
    function totalSupply() external view returns(uint);

    function balanceOf(address account) external view returns(uint balance);

    function transfer(address to, uint tokens) external returns(bool success);

    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender, uint tokens) external returns(bool success);

    function transferFrom(address from, address to, uint tokens) external returns(bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approve(address indexed owner, address indexed spender, uint tokens);
}

contract KCToken is IERC20 {
     string public name="KCToken";
     string public symbol="KC";
     uint public decimal=0;
     address public founder;
     uint public override totalSupply;

     mapping(address => uint) public balances;
     mapping(address => mapping(address => uint)) allowed;

     constructor(){
         totalSupply = 100000;
         founder = msg.sender;
         balances[founder]=totalSupply;
     }

     function balanceOf(address account) public view override returns(uint) {
           return balances[account];
     }
     
     function transfer(address to, uint tokens) public override virtual returns(bool success) {
         require(balances[msg.sender] >= tokens);
         balances[to]+=tokens;
         balances[msg.sender]-=tokens;
         emit Transfer(msg.sender,to,tokens);
         return true;
     }

     function approve(address spender, uint tokens) public  override returns(bool success) {
          require(balances[msg.sender] >= tokens);
          require(tokens > 0);
          allowed[msg.sender][spender] = tokens;
          emit Approve(msg.sender, spender, tokens);
          return true;
     }

     function allowance(address owner, address spender) public view override returns(uint) {
         return allowed[owner][spender]; 
     }

     function transferFrom(address from, address to, uint tokens) public  override virtual returns(bool success){
         require(allowed[from][to] >= tokens);
         require(balances[from] >= tokens);
         balances[from]-=tokens;
         balances[to]+=tokens;
         return true;
     }

    function mint(uint tokens) external{
        balances[msg.sender] += tokens;
        totalSupply += tokens;
        emit Transfer(address(0), msg.sender, tokens);
    }

    function burn(uint tokens) external{
        balances[msg.sender] -= tokens;
        totalSupply -= tokens;
        emit Transfer( msg.sender, address(0), tokens);
    }

}

