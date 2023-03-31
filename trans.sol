//spdx identifier-license: MIT

pragma solidity ^0.8.0;



    interface IERC20
    {

       function transferFrom(address sender , address to , uint256 amt ) external returns(bool);
       function  approve(address user , uint256 amt) external returns(bool);
       function  balanceof(address account) external view returns(uint256);
       function transfer(address receipent , uint256 amt) external returns(bool);

    }

    contract transaction{
        address public owner;
        IERC20 private usdt;


        struct Transaction{
            address from;
            address to;
            uint256 amount;
            uint256 timestamp;
        }
        constructor(address _usdt)
        {
            owner = msg.sender;
            usdt = IERC20(_usdt);
            transactioncount=0;
        }

        mapping(uint256=>Transaction) private _transaction;
        uint256 transactioncount;
        event TransactionSent(address indexed from, address indexed to, uint256 amount, uint256 timestamp);


        function depoist(uint256 amt ) external 
        {
            usdt.transferFrom(msg.sender,address(this),amt );

        }

        function withdraw(uint256 amount) external{
            require(msg.sender==owner,"It must be the owner");
            require(amount <= usdt.balanceof(address(this)),"Insufficient balance");
            usdt.transfer(owner,amount);

        }

        function approve(address spender , uint256 amount) external
        {
            require(msg.sender==owner,"Only owner can apprve");
            usdt.approve(spender,amount);
        }

        function transferUsdt(address[] memory receipent , uint256[] memory amounts ) external
        {
            require(msg.sender==owner,"Only owner can use this function");
            require(receipent.length==amounts.length);
            uint256 amount=0;
            for(uint i=0;i<receipent.length;i++)
            {
                require(amounts[i]>0,"Invalid Amount");
                require(usdt.transferFrom(msg.sender,receipent[i],amounts[i]),"Transaction Failed");
                _transaction[transactioncount]= Transaction(owner,receipent[i],amounts[i],block.timestamp);
                 amount+=amounts[i];
                 transactioncount++;

                emit TransactionSent(msg.sender , receipent[i],amounts[i], block.timestamp);
            }
            require(usdt.balanceof(address(this))==amount,"Invalid Balance");

        }

        function getTrans(uint256 index) external view returns( address , address, uint256, uint256)
        {
            Transaction memory trans = _transaction[index];
            return(trans.from, trans.to, trans.amount , trans.timestamp);

        }
    }
