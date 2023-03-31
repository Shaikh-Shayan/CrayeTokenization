//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract PropertyInspectionOracle  {
     address public owner;
     bool PropertyExterior;
     bool PropertyInterior;
     uint propertyId=0;

    constructor(){
        owner=msg.sender;
       
    }

    mapping(uint => bool) propertyExteriorStructuralSafety;
    mapping(uint => bool) propertyExteriorMaintenance;
    mapping(uint => bool) propertyExteriorAppearance;
    mapping(uint => bool) propertyInteriorStructual;
    mapping(uint => bool) propertyInteriorMaintenance;
    mapping(uint => bool) propertyInteriorAppearance;
    mapping(uint => bool) propertyValidation;
    modifier onlyOwner{
        require(msg.sender== owner,"not owner");//Check address of submitted requiest is owner or not 
        _;//if msg.sender is the owner of the contract then go ahead and allow execution of the rest of the function.
    }
    /*Returns the property id*/
    function getPropertyId() public view returns(uint){
       return propertyId;
    }/*Sets property id  */
    function setPropertyId(uint _propertyId) public{
        propertyId=_propertyId;
    }/*taking input from frontends*/
    function ExteriorStructuralSafety(bool _foundationCondition,bool _porchCondition,bool _roofCondition)external onlyOwner{
      /*check all the field of a ExteriorStructuralSafety function is same or not*/
     if(_foundationCondition==_porchCondition && _porchCondition==_roofCondition ){
          propertyExteriorStructuralSafety[propertyId]=true;//if yes then set true
      }else
      propertyExteriorStructuralSafety[propertyId]=false;//else set false
    }
     /*check all the field of a ExteriorMaintenance function is same or not*/
    function ExteriorMaintenance(bool _siding,bool _door,bool _window)external onlyOwner{
      
      if(_siding==_door && _door==_window ){
          propertyExteriorMaintenance[propertyId]=true;//if yes then set true
      }else
      propertyExteriorMaintenance[propertyId]=false;//else set false

    }
     /*check all the field of a ExteriorAppearance function is same or not*/
    function ExteriorAppearance(bool _lawn,bool _paint,bool _fencing)external onlyOwner{
      
      if(_lawn==_paint && _paint==_fencing ){
          propertyExteriorAppearance[propertyId]=true;//if yes then set true
      }else
      propertyExteriorAppearance[propertyId]=false;//else set false

    }
     /*check all the field of a InteriorMaintenance function is same or not*/
    function InteriorMaintenance(bool _plumbing,bool _electrical,bool _floors,bool _windows,bool _fixtures,bool _hvac,bool _fireplace)external onlyOwner{
      
      if(_plumbing==_electrical && _electrical==_floors &&_floors==_windows && _windows==_fixtures &&_fixtures==_hvac && _hvac==_fireplace  ){
          propertyInteriorMaintenance[propertyId]=true;//if yes then set true
      }else
      propertyInteriorMaintenance[propertyId]=false;//else set false

    }
      /*check all the field of a InteriorAppearance function is same or not*/
    function InteriorAppearance(bool _walls,bool _doors,bool _pests)external onlyOwner{
      
     if(_walls==_doors && _doors==_pests ){
          propertyInteriorAppearance[propertyId]=true;//if yes then set true
      }else
      propertyInteriorAppearance[propertyId]=false;//else set false
    }
     /*check all the field of a InteriorStructual function is same or not*/
    function InteriorStructual(bool _ceiling,bool _supportBeams,bool _insulation)external onlyOwner{
      
      if(_ceiling==_supportBeams && _supportBeams==_insulation ){
          propertyInteriorStructual[propertyId]=true;//if yes then set true
      }else
      propertyInteriorStructual[propertyId]=false;//else set false

    }
     /*check value of a propertyExterior and PropertyInterior is same or not*/
    function validate() external onlyOwner{
       if(PropertyExterior==PropertyInterior)
       propertyValidation[propertyId]=true;//if yes then set true
       else
       propertyValidation[propertyId]=false;//else set false


    }
     /*check all the field of a ExteriorStructuralSafety function is same or not*/
    function checkPropertyExterriorValidation()public{
if(propertyExteriorStructuralSafety[propertyId]==propertyExteriorMaintenance[propertyId] && propertyExteriorMaintenance[propertyId]==propertyExteriorAppearance[propertyId])
         PropertyExterior= true;//if yes then set true
         else
        PropertyExterior= false;//else set false
        
     }
      /*check all the field of a ExteriorStructuralSafety function is same or not*/
    function checkPropertyInterriorValidation()public{
if(propertyInteriorStructual[propertyId]==propertyInteriorMaintenance[propertyId] && propertyInteriorMaintenance[propertyId]==propertyInteriorAppearance[propertyId])
         PropertyInterior= true;//if yes then set true
         else
        PropertyInterior= false;//else set false
     }
    function checkPropertyInspectionValidation() external onlyOwner view returns (bool)  {
        
       return propertyValidation[propertyId];//returns property validation in the form of bool value
    }
    
  
}