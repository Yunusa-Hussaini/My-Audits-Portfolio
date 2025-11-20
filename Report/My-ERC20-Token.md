// SPDX-License-Identifier: MIT

   pragma solidity ^0.8.30;

   contract ERC20Token {
         string name;
         string symbol;
         uint256 decimals;
         uint256 totalSupply;
         uint256 minMint = 10e18;
         uint256 maxMint = 1_00_000e18;

           mapping(address => uint256) public balances;

           mapping(address => mapping(address => uint256)) public allowances;


      constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _totalSupply) {
           name = _name;
           symbol = _symbol;
           decimals =_decimals;
           totalSupply = _totalSupply;
      } 
       

        function mint(address _owner, uint256 amount) external returns(uint256) {
           require(_owner != address (0), "can not mint to address(0)");
             if (amount >= minMint && amount <= maxMint) {
             balances[msg.sender] += amount;
           }
            return amount;
    }

      
       function burn(address _owner, uint256 _amount) external {
           require(balances[msg.sender] >= _amount && _amount > 0, "can'not burn from address(0)");
           balances[_owner] -= _amount;
       }


        function approve(address _spender, uint256 _value) external returns(bool success) {
                 require(balances[msg.sender] >= _value && _spender != address(0));
                 allowances[msg.sender][_spender] = _value;
                 return true;
         }


       function tranfer(address _owner, address _spender, uint256 _amount) external returns(bool success) {
             require(balances[msg.sender] >= _amount && _amount > 0, "Insufficeint balance");
               if(_owner != address(0) && _spender != address(0)) {
                balances[_owner] -= _amount;
                balances[_spender] += _amount;
            }
                return true;
         }


        function tranferFrom(address _owner, address _spender, uint256 _amount) external returns(bool success) {
               require(allowances[_owner][_spender] >= _amount && _amount > 0, "tranferFrom failed");
                 allowances[_owner][_spender] -= _amount;
                 balances[_owner] -= _amount;
                 balances[_spender] += _amount;
                 return true;
         }


        function allowance(address _owner, address _spender) external view returns(uint256 remaining) {
                 return allowances[_owner][_spender];
         }


         function balanceof(address _user) external view returns(uint256 balance) {
                return balances[_user];
         }

 }
