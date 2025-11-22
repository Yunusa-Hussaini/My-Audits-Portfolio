// SPDX-License-Identifier: MIT

   pragma solidity ^0.8.30;

   interface IERC20Token {

      function name() external view returns(string memory);

      function symbol() external view returns(string memory);

      function decimals() external view returns(uint256);

      function totalSupply() external view returns(uint256);
    
      function balanceof(address _owner) external view returns(uint256 balance);

      function tranfer(address _to, uint256 _amount) external returns(bool success);

      function tranferFrom(address _from, address _to, uint256 _amount) external returns(bool success);

      function approve(address _spender, uint256 _value) external view returns(bool success);

      function allowance(address _owner, address _spender) external view returns(uint256 remaining);

      function mint(address _to, uint256 amount) external returns(uint256);

      function burn(address _from, address _to, uint256 _amount) external;

      function deposit(address _to, uint256 _amount) external payable returns(bool success);

      function withdraw(address _user, address _to, uint256 _amount) external payable returns(bool success);


    }
