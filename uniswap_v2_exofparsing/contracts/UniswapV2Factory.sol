// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.5.16;

import './interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';

//uniswap工厂合约
//主要用来操作创建交易对
contract UniswapV2Factory is IUniswapV2Factory {
    //设置收税地址
    address public feeTo;
    //这是收税权限控制地址
    address public feeToSetter;
    
    //配对映射，地址=>(地址=>地址)
    //用来得到配对好的交易对地址
    mapping(address => mapping(address => address)) public getPair;
    //存储所有交易对的数组
    address[] public allPairs;
    //当交易对创建成功之后出发事件,事件包含四个参数，token0代表参与配对的第一个代币地址，token1代表参与配对的第二个代币地址，
    //pair代表配队成功后两个代币组成的配对地址，unit代表这次配对属于第几个配对
    //indexed作用：可以让token0和token1的地址通过索引去查找。
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    /** 
     * @dev 构造函数
     * @param _feeToSetter 收税开关控制权限
    */
    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }
    /** 
     * @dev 查询交易对数组长度的方法
    */
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    /** 
     * @dev 创建交易对的方法
     * @param tokenA tokenA的地址
     * @param tokenB tokenB的地址
     * @param pair 配对地址
    */
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        //确认tokenA的地址不等于tokenB的地址
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        //将token0和token1地址的大小做比较，保证返回出来的token0地址一定小于token1的地址，
        //这一步是防止同时出现tokenA-tokenB和tokenB-tokenA两个相同储备量和价格比例的交易对，
        //因为每个配对都有唯一标识，交易对是按照代币储量区分交易对，而且不代币名称，比如eth-usdt和usdt-eth是两个不同的交易对
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        //判断token0地址不是空地址
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        //判断token0和token1组成的配对地址是空地址，否则说明已经存在这个交易对
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        //获取UniswapV2Pair合约创建的字节码，其中type和creationCode组合就是获取合约字节码
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        //把token0和token1打包哈希运算获取到交易对的地址的哈希值，简称盐
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        //内联汇编
        assembly {
            //通过create2方法部署合约，并且加盐，返回地址到pair变量
            //create2 是以太坊 EVM 中的一种操作码（Opcode），用于根据给定的合约创建码、初始数据和 salt 值计算出合约地址，
            //并在计算得到的地址处部署一个新的合约。create2 操作码在 Solidity 语言中通过 create2 函数进行封装和调用。
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        //通过调用pair地址的合约中的initialize方法，传入token0和token1达到初始化参数的目的
        IUniswapV2Pair(pair).initialize(token0, token1);
        //配对映射中设置token0=>token1的pair地址
        getPair[token0][token1] = pair;
         //配对映射中设置token1=>token0的pair地址
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        //配对数组中加入pair的地址
        allPairs.push(pair);
        //成功后触发事件
        emit PairCreated(token0, token1, pair, allPairs.length);
    }
   
    /** 
     * @dev 设置收费权限
     * @param _feeTo 收税地址
    */
    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }
    /** 
     * @dev 设置收费控制权限
     * @param _feeTo 收费权限控制
    */
    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
