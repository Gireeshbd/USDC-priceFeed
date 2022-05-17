//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;



contract Airbnb{
    uint registrationFee;
    struct property{
        bool isActive;
        uint price;
        address  payable owner;
        string name;
        string description;
        bool[] isBooked;
    }
    uint public propertyId = 0;
    mapping(uint => property) public properties;
    property[] public propertiess;
    struct Booking{
        uint propertyId;
        uint checkInDate;
        uint checkOutDate;
        address user;
    }
    uint public bookingId;
    mapping(uint=> Booking)public bookings;

    constructor(uint _minResterFee) public{
        registrationFee = _minResterFee;
    }

    function rentOutProperty(uint _price, address _owner, string memory _name, string memory _description) payable public{
        require(msg.value >= registrationFee);
        property memory Property = property
         ({isActive : true,
         price: _price,
         owner: payable(msg.sender),
         name: _name, 
         description:_description, 
         isBooked : new bool[](365)});
        properties[propertyId] = Property;
        propertiess.push(Property);
       
        
         propertyId = propertyId + 1;
    }
    function rentProperty(uint _propertyId, uint _checkInDate, uint _checkOutDate) public payable{
        property storage Property = properties[_propertyId];
        require(Property.isActive == true);
        require(msg.value >= Property.price);
        for(uint i = _checkInDate; i<_checkOutDate; i++){
            if(Property.isBooked[i] == true){
                revert ("property is not available");
            }
        }
        require(
            msg.value >= Property.price*(_checkOutDate - _checkInDate)
        );
        sendFunds(_propertyId, msg.value);
        createBooking(_propertyId, _checkInDate, _checkOutDate);
    }

    function createBooking(uint _propertyId, uint _checkInDate, uint _checkOutDate) internal{
        Booking memory booking = Booking({
            propertyId :_propertyId,
            checkInDate: _checkInDate,
            checkOutDate: _checkOutDate,
            user : msg.sender});
        property storage Property = properties[_propertyId];
        for(uint i = _checkInDate; i<_checkOutDate; i++){
            Property.isBooked[i] == true;
        }

    }
    function sendFunds(uint _propertyId, uint value) internal {
        address payable powner = properties[_propertyId].owner;
        powner.transfer(value);
    }
    /*function makePropertyAsInActive(uint _propertyId) public {
         
        require(properties[_propertyId].owner = msg.sender);
        property[_propertyId].isActive = false;
    }*/
}