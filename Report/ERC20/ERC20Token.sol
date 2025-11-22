// SPDX-License-Identifier: MIT

   pragma solidity ^0.8.30;

   contract ERC20Token {
          string name;
          string symbol;
          uint256 decimals;
          uint256 totalSupply;
          uint256 minDeposit = 10e18;
          uint256 minMint = 10e18;
          uint256 maxMint = 1_00_000e18;


          event Transfer(address indexed _owner, address indexed _spender, uint256 _amount);
          event TransferFrom(address indexed _owner, address indexed _spender, uint256 _amount);
          event Mint(address indexed _owner, uint256 _amount);
          event Burn(address indexed _owner, address indexed _to, uint256 _amount);
          event Deposit(address indexed _to, uint256 _amount);
          event Withdraw(address indexed _user, address indexed _to, uint256 _amount);

           mapping(address => uint256) public balances;

           mapping(address => mapping(address => uint256)) public allowances;


      constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _totalSupply) {
           name = _name;
           symbol = _symbol;
           decimals =_decimals;
           totalSupply = _totalSupply;
      } 
       
        function deposit(address _to, uint256 _amount) external payable returns(bool success) {
             require(_to != address(0), "can not deposit to address zero");
               if (_amount > 0 && _amount >= minDeposit) {
                balances[_to] += _amount;
                emit Deposit(_to, _amount);
                 return true;
             }
        }


        function mint(address _owner, uint256 amount) external returns(uint256) {
           require(_owner != address (0), "can not mint to address(0)");
             if (amount >= minMint && amount <= maxMint) {
             balances[msg.sender] += amount;
             emit Mint(_owner,amount);
             }
             return amount;
    }

      
       function burn(address _owner, uint256 _amount) external {
           require(balances[msg.sender] >= _amount && _amount > 0, "can'not burn from address(0)");
           balances[_owner] -= _amount;
           emit Burn(_owner, address(0), _amount);
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
                emit Transfer(_owner, _spender, _amount);
            }
                return true;
         }


        function tranferFrom(address _owner, address _spender, uint256 _amount) external returns(bool success) {
               require(allowances[_owner][_spender] >= _amount && _amount > 0, "tranferFrom failed");
                 allowances[_owner][_spender] -= _amount;
                 balances[_owner] -= _amount;
                 balances[_spender] += _amount;
                 emit TransferFrom(_owner, _spender, _amount);
                 return true;
         }


        function allowance(address _owner, address _spender) external view returns(uint256 remaining) {
                 return allowances[_owner][_spender];
         }


        function balanceof(address _user) external view returns(uint256 balance) {
                return balances[_user];
        }

        function withdraw(address _user, address _to, uint256 _amount) external payable returns(bool success) {
             require(balances[_user] >= _amount && _amount > 0, "No enought balance");
              balances[_user] -= _amount;
               payable(_to).transfer(_amount);
               emit Withdraw(_user, _to, _amount);
                return true;
           }
         }  
