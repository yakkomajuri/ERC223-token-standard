contract ERC223BasicToken is ERC223Basic{
    using SafeMath for uint;

    mapping(address => uint) balances;
    
    // Example: give creator 10000 tokens due to testing reasons
    function ERC223BasicToken()
     {
         balances[msg.sender] = 10000;
     }
    
    
    // Call this function with the following params:
    // to              = 0xb4aAc521e6057bd8C95Db300524367a1Dc001953
    // value           = 12
    // custom_fallback = receiveToken(address,uint256,bytes)
    // data            = fffffffffffffffff 
    // to test how it works on Rinkeby
    // this will call `receiveToken` function at receiver.
    
    function transfer(address to, uint value, string custom_fallback, bytes data) {
        uint codeLength;

        assembly {
            codeLength := extcodesize(to)
        }

        balances[msg.sender] = balances[msg.sender] - (value);
        balances[to] = balances[to] + (value);
        if(codeLength>0) {
            if(!to.call.value(0)(bytes4(sha3(custom_fallback)), msg.sender, value, data))
            {
                revert();
            }
        }
        Transfer(msg.sender, to, value, data);
    }

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address to, uint value, bytes data) {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(to)
        }

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            receiver.tokenFallback(msg.sender, value, data);
        }
        Transfer(msg.sender, to, value, data);
    }

    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address to, uint value) {
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(to)
        }

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            bytes memory empty;
            receiver.tokenFallback(msg.sender, value, empty);
        }
        Transfer(msg.sender, to, value, empty);
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }
}
