pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MerkleTreeValidator} from "../src/utils/MerkleTreeValidator.sol";

contract MerkleTreeValidatorTest is Test {
    MerkleTreeValidator public validator;

    function setUp() public {
        validator = new MerkleTreeValidator();
    }

    function testTrue() public {
        assertEq(true, true);
    }
}
