pragma solidity >0.4.23 <0.7.0;

contract ransom {


    address payable public attacker;
    address payable public victim;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;
    bool paidransom;
    bytes32 decKey;
    uint32 ransomV;
    uint32 min;
    uint32 theta;
    bytes32 victimbid;
    bytes32 attackerbid;
    uint32 rplustheta;


    modifier onlyBefore(uint _time) { require(now < _time); _; }
    modifier onlyAfter(uint _time) { require(now > _time); _; }

    constructor(
        uint _biddingTime,
        uint _revealTime,
        address payable _attacker,
        address payable _victim,
        uint32 _theta
    ) public {
        attacker = _attacker;
        victim = _victim;
        biddingEnd = now + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
        theta = _theta;
    }
    
    
    
    function bid(bytes32 _blindedBid)
        public
        onlyBefore(biddingEnd)
    {

        if (msg.sender == victim){
            victimbid = _blindedBid;
        }
        if (msg.sender ==attacker){
            attackerbid=_blindedBid;
        }

    }
    

    function reveal(
        uint32 _value,
        bytes32 _secret
    )
        public
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {


            if (msg.sender ==victim && victimbid == keccak256(abi.encodePacked(_value, _secret))) {
                ransomV = _value;
            }
    
            if (msg.sender ==attacker && attackerbid == keccak256(abi.encodePacked(_value, _secret)) ) {
                min = _value;
            }
    }
    
    function check () 
    public
    onlyAfter(revealEnd)
    returns(bool approved_)
    {
        if(ransomV >= min){
            approved_=true;
        }
    }
    
    
    function deposit( ) 
    public
    payable
    {
        rplustheta = ransomV + theta;
        if (msg.value == rplustheta){
        paidransom=true;
        }
    }
    
    function checkDeposit( ) public view 
        returns(bool paidransom_)
        {
            paidransom_ =paidransom; 
        }
    
    function setdecKey(bytes32  _decKey ) public
    {
       decKey = _decKey;
    }
    
    function getdecKey( ) public view
        returns (bytes32 deckey_)
    {
       deckey_ = decKey;
    }
    
    
    
    function confirm (bool _signal) public
    {
        if(msg.sender == victim && _signal){
            attacker.transfer(ransomV);
            victim.transfer(theta);
        }
    }

    
}
