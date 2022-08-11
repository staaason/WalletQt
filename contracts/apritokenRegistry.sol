//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface EIP2612 {
    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function nonces(address owner) external view returns (uint256);
}

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

contract ApritokenRegistry is ERC20, EIP2612 {
    
    event Transfer(address from, address to, uint256 amount);
    event Approval(address owner, address spender, uint256 amount);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) public _nonces;

    uint256 private _totalSupply;
    uint256 private _exchangeRate;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address _admin;

    //хеш - унікальний ідентифікатор функції permit
    bytes32 public immutable PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    //хеш - унікальний ідентифікатор смарт-контракту
    bytes32 public immutable DOMAIN_SEPARATOR;

   
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_, address admin_)  {
        _name = name_;
        _symbol = symbol_;
        _admin = admin_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
        _balances[address(this)] = _totalSupply;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        //унікальний ідентифікатор смарт-контракту
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name_)),
                keccak256(bytes(version())),
                chainId,
                address(this)
            )
        );
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function version() public pure virtual returns(string memory) { 
        return "1"; 
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer (
        address to, 
        uint256 amount
    ) public override returns (bool) {
        address from = msg.sender;
        require(from == _admin, "APRI::WALLET: action is restricted");
        require(to != address(0), "APRI::WALLET: transfer to the zero address");
        require(_balances[from] >= amount, "APRI::WALLET: transfer amount exceeds balance");
        
        _balances[from] -= amount;
        _balances[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    
    function transferFrom (
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(msg.sender == _admin, "APRI::WALLET: action is restricted");

        uint256 currentAllowance = allowance(from, to);
        require(allowance(from, to) >= amount, "APRI::WALLET: insufficient allowance" );
        approve(to, currentAllowance - amount);

        _balances[from] -= amount;
        _balances[to] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = msg.sender;
        require(owner == _admin, "APRI::WALLET: action is restricted");
        require(spender != address(0), "APRI::WALLET: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view  override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function setExchangeRate(uint256 ETHforOneAPR) public returns (bool) {
        _exchangeRate = ETHforOneAPR;
        return true;
    }

    function getExchangeRate() public view returns (uint256) {
        return _exchangeRate;
    }

    //викликаємо owner - адреса користувача, spender, deadline i решта - 
    function permit (
        address owner, 
        address spender, 
        uint256 amount, 
        uint256 deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) public override {
        //перевіряємо чи аппрув не протермінований
        require(deadline >= block.timestamp, "APRI::WALLET: expired deadline");
        //перераховуємо хеш
        bytes32 hashStruct = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
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
                DOMAIN_SEPARATOR,
                hashStruct
            )
        );

        //перевіряємо чи підпис валідний за допомогою криптографічних штучок:)
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0) && signer == owner, "APRI::WALLET: invalid signature");

        //робимо справжній approve
        approve(spender, amount);

    }

    function buyTokens(address user, uint256 amount) public payable returns (bool){
        require(msg.sender == _admin);
        require(msg.value == getExchangeRate() * amount);
        transferFrom(address(this), user, amount);
        return true;
    }

    function sellTokens(address payable user, uint256 amount) public returns (bool){
        require(msg.sender == _admin);
        require(_balances[user] >= amount);
        transferFrom(user, address(this), amount);
        user.transfer(getExchangeRate() * amount);
        return true;
    }


}