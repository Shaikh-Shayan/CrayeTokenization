//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract PropertyAppraisalOracle  {
    address owner;
    address PropertySmartcontract;
    address AppraisalAddress;
    uint AppraisalId;
    bool PropertyAppraisal;
    uint propertyId;
    uint timestamp;
  

    constructor(){
        owner=msg.sender;
       
    }
    mapping(uint => bool) propertyAppraisal;
    modifier onlyOwner{
        require(msg.sender== owner,"not owner");//Check address of submitted requiest is owner or not 
        _;//if msg.sender is the owner of the contract then go ahead and allow execution of the rest of the function.
    }
    /*Taking inputs form frontend */
    function appraisalReport(uint _propertyId,address _PropertySmartcontract,uint _AppraisalId,bool _PropertyAppraisal)external onlyOwner{
       propertyId=_propertyId;
       PropertySmartcontract=_PropertySmartcontract;
       AppraisalAddress=msg.sender;
      AppraisalId=_AppraisalId;
      PropertyAppraisal=_PropertyAppraisal;
       propertyAppraisal[propertyId]=PropertyAppraisal;
       timestamp = block.timestamp;
    }
  /*Returns the timestamp value */
    function getTimestamp() public view returns(uint){
       return timestamp;
    }
    /*Returns the property id  */
    function getPropertyId() public view returns(uint){
       return propertyId;
    }
    /*Returns the address of property smart contract  */
     function getAppraisalAddress() public view returns(address){
       return AppraisalAddress;
    }
    /*Returns the address of property smart contract  */
     function getPropertySmartcontract() public view returns(address){
       return PropertySmartcontract;
    }
    /*Returns the appraisal id*/
     function getAppraisalId() public view returns(uint){
       return AppraisalId;
    }/*Returns the status of property appraisal*/
     function getPropertyAppraisal() public view returns(bool){
       return PropertyAppraisal;
    }
  
}