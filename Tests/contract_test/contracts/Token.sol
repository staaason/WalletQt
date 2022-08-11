//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

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

contract Token is ERC20, EIP2612 {
    using SafeMath for uint256;
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
    uint8 private _chainId;
    address private _admin;

    bytes32 public immutable PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public immutable DOMAIN_SEPARATOR;

   
    constructor(string memory name_, string memory symbol_, uint8 decimals_, address admin_, uint256 totalSupply_)  {
        _name = name_;
        _symbol = symbol_;
        _admin = admin_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
        _balances[_admin] = _totalSupply;
        uint8 chainId;
        assembly {
            chainId := chainid()
        }
        _chainId = chainId;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name_)),
                keccak256(bytes(version())),
                _chainId,
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

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function domainSeparator() public view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }

    function permitTypehash() public view returns (bytes32) {
        return PERMIT_TYPEHASH;
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner];
    }
    function transfer (
        address to, 
        uint256 amount
    ) public override returns (bool) {
        address from = msg.sender;
        require(from == _admin, "action is restricted");
        require(to != address(0), "transfer to the zero address");
        require(_balances[from] >= amount, "transfer amount exceeds balance");
        
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
        require(msg.sender == _admin, "action is restricted");

        uint256 currentAllowance = allowance(from, to);
        require(allowance(from, to) >= amount, "insufficient allowance" );
        approve(to, currentAllowance - amount);

        _balances[from] -= amount;
        _balances[to] += amount;
        return true;
    }

    function buyTokens(address to, uint256 amount) public payable returns (bool) {
        require(msg.sender == _admin, "action is restricted");
        require(msg.value == amount.mul(getExchangeRate()), "low amount of eth");

        approve(to, amount);
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }

    function sellTokens(address from, uint256 amount) public payable returns (bool) {
        require(msg.sender == _admin, "action is restricted");
        approve(from, amount);
        _balances[msg.sender] += amount;
        _balances[from] -= amount;
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = msg.sender;
        require(owner == _admin, "action is restricted");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function setExchangeRate(uint256 ETHforOneAPR) public returns (bool) {
        require(msg.sender == _admin, "action is restricted");
        _exchangeRate =  ETHforOneAPR;
        return true;
    }

    function getExchangeRate() public view returns (uint256) {
        return _exchangeRate;
    }

    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }


    function permit (
        address owner, 
        address spender, 
        uint256 amount, 
        uint256 deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) public override {
        require(_balances[owner] >= amount, 'amount exceeds balance');
        require(deadline >= block.timestamp, 'expired deadline');
        require(spender != address(0), 'spender is zero adress');
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
      

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0) && signer == owner, "invalid signature");

        _allowances[owner][spender] = amount;

    }
}