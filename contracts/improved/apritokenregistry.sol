//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;


interface ERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
    
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

interface EIP2612 {
    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external returns (bool success);

    function nonces(address owner) external view returns (uint256);
}

contract ApriToken is ERC20, EIP2612 {
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) _nonces;


    event Transfer(address from, address to, uint256 amount);
    event Approval(address owner, address spender, uint256 amount);

    constructor(uint256 totalSupply_, address admin_) {
        _totalSupply = totalSupply_;
        _balances[admin_] = _totalSupply;
    }

    function name() public pure override returns (string memory) {
        return "Apritoken";
    }

    function symbol() public pure override returns (string memory) {
        return "APR";
    }
    
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address user) public view override returns (uint256 balance) {
        return _balances[user];
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner];
    }

    function transfer(address to, uint256 value) public override returns (bool success) {
        require(to != address(0), "You can't transfer to zero address.");
        require(balanceOf(msg.sender) >= value, "Transfer amount exceeds your balance.");
        
        _balances[msg.sender] -= value;
        _balances[to] += value;
        
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool success) {
        require(from != address(0), "You can't transfer from zero address.");
        require(to != address(0), "You can't transfer to zero address.");
        
        uint256 currentAllowance = allowance(from, to);
        require(allowance(from, to) >= value, "Insufficient allowance.");
        approve(to, currentAllowance - value);

        emit Transfer(from, to, value);
        return true;
    }

    function approve(
        address to, 
        uint256 value
    ) 
        public
        override 
        returns (bool success) 
    {
        require(to != address(0), "You can't approve to zero address.");
        require(value <= totalSupply(), "You can't approve to transfer this amount of tokens.");

        _allowances[msg.sender][to] = value;
        emit Approval(msg.sender, to, value);
        return true;
    }

    function permit (
        address owner, 
        address spender, 
        uint256 amount,
        uint256 deadline,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        public 
        override 
        returns (bool success) 
    {
        require(spender != address(0), "Can't give allowance for transfer to zero address.");
        require(balanceOf(owner) >= amount, "Amount exceeds balance.");
        require(deadline >= block.timestamp, "Deadline has expired.");

        bytes32 hashStruct = keccak256(
            abi.encode(
                getPermitTypehash(),
                owner,
                spender,
                amount,
                _nonces[owner]++,
                deadline
            )
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                '\x19\x01',
                getDomainSeparator(),
                hashStruct
            )
        );
      
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0) && signer == owner, "Invalid signature.");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }


    function allowance(address from, address to) public view override returns (uint256 remaining) {
        return _allowances[from][to];
    }

    function getPermitTypehash() public pure returns(bytes32 hash) {
        return keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    }

    function getDomainSeparator() public view returns (bytes32 hash) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name())),
                keccak256(bytes(version())),
                getChainId(),
                address(this)
            )
        );
    }

    function getDigest(address owner, address spender, uint256 amount, uint256 deadline) private returns (bytes32 res) {
        bytes32 hashStruct = keccak256(
            abi.encode(
                getPermitTypehash(),
                owner,
                spender,
                amount,
                _nonces[owner]++,
                deadline
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                '\x19\x01',
                getDomainSeparator(),
                hashStruct
            )
        );
        return hash;
    }

    function version() private pure returns(string memory) { 
        return "1"; 
    }

    function getChainId() private view returns(uint8 id_){
        uint8 id;
        assembly {
            id := chainid()
        }
       return id; 
    }
    
}

