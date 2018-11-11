pragma solidity ^0.4.21;

//import "./IERC20.sol";
import "./MyERC20Token.sol";
import "./ReentrancyGuard.sol";
import "./Pausable.sol";

contract MyTokenManage is ReentrancyGuard,Pausable,Ownable {
    struct Token {
        address tokenContract; 
        string symbolName;
    }
    
    //Maxinum 256 tokens
    mapping (uint8 => Token) public tokens;
    uint8 tokenIndex;
    
    //Token balance
    mapping (address => mapping(uint8 => uint256)) tokenBalances;
    
    //Ether balance
    mapping(address => uint256) etherBalances;
    
    //Events to log account activities
    event log_DepositToken(address _from,uint8 _symbolIndex,uint256 _amount,uint256 _timestamp);
    event log_WithDrawToken(address _to, uint8 _symbolIndex, uint256 _amount, uint256 _timestamp);
    event log_DepositEther(address _from, uint256 _amount, uint256 _timestamp);
    event log_WithDrawEther(address _to,uint256 _amount, uint256 _timestamp);
    event log_NewToken(uint8 _symbolIndex, string _tokenName, uint256 _timestamp);
    event log_TokenBalance(string _symbolName,uint8 _symbolIndex, address _from, uint256 _amount);
    
    //Deposit ether 
    function depositEther() public payable{
        require(etherBalances[msg.sender] + msg.value >= etherBalances[msg.sender]);  //overflow checking
        etherBalances[msg.sender] += msg.value;
        emit log_DepositEther(msg.sender,msg.value, now);
    }
    
    //withdraw ether
    function withdrawEther(uint amountInWei) whenNotPaused nonReentrant public{
        require(etherBalances[msg.sender] - amountInWei >=0);
        //overflow checking
        require(etherBalances[msg.sender] - amountInWei <=etherBalances[msg.sender]);
        etherBalances[msg.sender] -=amountInWei;
        msg.sender.transfer(amountInWei);
        emit log_WithDrawEther(msg.sender,amountInWei, now);  
    }
    
    //Get Ether balance
    function getEtherBalance() view public returns(uint256){
        return etherBalances[msg.sender];
    }

    function getEthBalanceInWei() view public returns (uint){
        return etherBalances[msg.sender];
    }
    
    //Enable new _token
    function addToken(string symbolName, address erc20Token) public onlyOwner {
        require(!hasToken(symbolName)); //make sure this token not exist yet
        require(tokenIndex +1 > tokenIndex);   //Ovweflow checking
        tokenIndex++;
        
        tokens[tokenIndex].symbolName = symbolName;
        tokens[tokenIndex].tokenContract = erc20Token;
        emit log_NewToken(tokenIndex,symbolName,now);
    }
    
    function hasToken(string symbolName) view public returns(bool){
        uint8 index = getSymbolIndex(symbolName);
        if (index ==0) {
            return false;
        }
        return true;
    }
    
    function getSymbolIndex(string symbolName) public view returns(uint8){
        for(uint8 i=1;i<=tokenIndex;i++){
            if (keccak256(tokens[i].symbolName) == keccak256(symbolName)){
                return i;
            }
        }
        return 0;
    }
    
    //Deposit Token
    function depositToken(string symbolName, uint256 amount) public{
        uint8 symbolIndex = getSymbolIndex(symbolName);
        emit log_DepositToken(msg.sender,symbolIndex,amount,now);
        require(tokens[symbolIndex].tokenContract != address(0));  //make sure the token is added already
        IERC20 token = IERC20(tokens[symbolIndex].tokenContract);
        //Traner token to this contract
        require(token.transferFrom(msg.sender, address(this),amount) == true);
        require(tokenBalances[msg.sender][symbolIndex] + amount >=  tokenBalances[msg.sender][symbolIndex]);  //overflow checking
        tokenBalances[msg.sender][symbolIndex] +=amount;
        emit log_DepositToken(msg.sender,symbolIndex,amount,now);
    }
    
    //withdraw token
    function withdrawToken(string symbolName,uint256 amount) public {
        uint8 symbolIndex = getSymbolIndex(symbolName);
        require(tokens[symbolIndex].tokenContract !=address(0));
        IERC20 token = IERC20(tokens[symbolIndex].tokenContract);
        
        require(tokenBalances[msg.sender][symbolIndex] - amount >=0);
        require(tokenBalances[msg.sender][symbolIndex] - amount <= tokenBalances[msg.sender][symbolIndex]);
        
        tokenBalances[msg.sender][symbolIndex] -= amount;
        require(token.transfer(msg.sender,amount) == true);
        emit log_WithDrawToken(msg.sender, symbolIndex,amount,now);
    }
    
    function getBalance(string symbolName) view public returns (uint) {
        uint8 symbolNameIndex = getSymbolIndex(symbolName);
        emit log_TokenBalance(symbolName,symbolNameIndex, msg.sender,tokenBalances[msg.sender][symbolNameIndex]);
        return tokenBalances[msg.sender][symbolNameIndex];
    }
    
}