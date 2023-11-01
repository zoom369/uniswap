// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.5.16;

import './interfaces/IUniswapV2Pair.sol';
import './UniswapV2ERC20.sol';
import './libraries/Math.sol';
import './libraries/UQ112x112.sol';
import './interfaces/IERC20.sol';
import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Callee.sol';

//uniswap配对合约
contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    //把安全数学加入到uint类型中
    using SafeMath  for uint;
    //把UQ112x112计算方法加入到uint224类型中
    using UQ112x112 for uint224;
    //最小流动性，防止攻击，增加攻击者的成本 
    uint public constant MINIMUM_LIQUIDITY = 10**3;
    //对transfer方法进行hash，然后取字节码的前4位，取到的为调用的方法，所以取到为transfer的selector是多少
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;
    /**
     * @dev 函数修饰器，防止重入攻击，保证每次调用被修饰的函数只能调用一次
     */
    modifier lock() {
        //判断unlocked是否为1
        require(unlocked == 1, 'UniswapV2: LOCKED');
        //把判断unlocked是否为1改为0
        unlocked = 0;
        //被修饰的函数执行完毕
        _;
        //然后把unlocked修改为1
        unlocked = 1;
    }
     /**
     * @dev 获取储备量
     * @return _reserve0 token0的储备量
     * @return _reserve1 token1的储备量
     * @return _blockTimestampLast 最后更新的时间戳
     */
    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }
     /**
     * @dev 安全交易
     * @return token token的地址
     * @return to to地址
     * @return value 数量
     */
    function _safeTransfer(address token, address to, uint value) private {
        //call为不知道接口合约的情况下调用合约方法
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        //判断调用方法是否成功，返回的字节码长度是否为0，或者data反解出来的值是否为turn
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'UniswapV2: TRANSFER_FAILED');
    }
     
    //铸造事件
    event Mint(address indexed sender, uint amount0, uint amount1);
    //销毁事件
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    //交换事件
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    //同步事件
    event Sync(uint112 reserve0, uint112 reserve1);

    /**
     * @dev 构造函数
     */
    constructor() public {
        //使合约的调用者为工程合约地址
        factory = msg.sender;
    }
    /**
     * @dev 初始化方法,部署时由工厂合约调用一次
     * @param _token0 代币地址
     * @param _token1 代币地址
     */
    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        //判断使用合约的调用者为工程合约地址
        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    /**
     * @dev 更新方法
     * @param balance0 token0合约额度
     * @param balance1 token1合约额度
     * @param _reserve0 _reserve0 token0储备量
     * @param _reserve1 _reserve1 token1储备量
     */
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        //确认余额0和余额1小于等于最大的uint112数值
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW');
        //区块链时间戳，将时间戳转换为uint112
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        //计算时间流逝
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        //如果时间流逝>0并且 储备量0，1不等于0
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            //价格0的最后累计 +=储备量0*2**112储备量0*时间流逝
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            //价格0的最后累计 +=储备量1*2**112储备量1*时间流逝
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        //余额0，1放入储备量0，1
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        //触发同步事件
        emit Sync(reserve0, reserve1);
    }

     /**
     * @dev 铸造收费的方法，如果开启铸造流动性相当于1/6的增长sqrt（k）
     * @param _reserve0 储备0
     * @param _reserve1 储备1
     * @return feeOn 是否开启
     */
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        //获得工厂合约中的feeTo地址
        address feeTo = IUniswapV2Factory(factory).feeTo();
        //把判断feeto地址是否是空地址的结果传递给feeOn
        feeOn = feeTo != address(0);
        //手续费收取的公式计算如下，具体可以看uniswap的白皮书
        //获取k值
        uint _kLast = kLast; // gas savings
        //如果feeOn=true
        if (feeOn) {
            //如果k值不等于0，因为k值是根据交易对的两个代币的储备量相乘计算得出的，所以如果等于0说明池子里面没有储备量，也就不能铸造费的收取
            if (_kLast != 0) {
                //计算_reserve0*_reserve1的平方根
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                //计算k值的平方根
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    //分子=erc20总值*（rootk-rootklast）
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    //分母= rootk*5+rootklast 
                    uint denominator = rootK.mul(5).add(rootKLast);
                    //流动性的数值等于分子/分母
                    uint liquidity = numerator / denominator;
                    //如果流动性>0 将流动性铸造给feeto地址
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        //如果_kLast不等于0
        } else if (_kLast != 0) {
            //k值=0
            kLast = 0;
        }
    }
    /**
     * @dev 铸造方法
     * @param to to地址，收取流动性代币的地址
     * @return liquidity 流动性代币数量
     */
    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint liquidity) {
        //获取储备量0和储备量1
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        //获取当前合约在token0合约内的余额
        uint balance0 = IERC20(token0).balanceOf(address(this));
        //获取当前合约地址的token1的余额
        uint balance1 = IERC20(token1).balanceOf(address(this));
        //计算用户传入token0的最小值
        uint amount0 = balance0.sub(_reserve0);
        //计算用户传入token1的最小值
        uint amount1 = balance1.sub(_reserve1);
        
        //返回铸造费开关
        bool feeOn = _mintFee(_reserve0, _reserve1);
        //获取totalSupply，必须在此定义，因为totalSupply可以在mintfee中更新
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        //如果_totalSupply等于0
        if (_totalSupply == 0) {
            //流动性=（数量0 * 数量1）的平方根-最小流动性1000
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            //在总量为0的初始状态，永久锁定最低流动性
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            //流动性 = 最小值（amount0*_totalSupply/_reserve0）和（amount1*_totalSupply/_reserve1）
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        //确认流动性大于0
        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
        //铸造流动性给to地址
        _mint(to, liquidity);
        
        //更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        //如果铸造费开关为true，k值=储备量0*储备量1
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        //触发铸造事件
        emit Mint(msg.sender, amount0, amount1);
    }
     
     /**
      * @dev 销毁方法
      * @param to 销毁地址
      * @return amount0 
      * @return amount1 
      * @notice 应该从执行重要安全检查的合同中调用此低级功能
      */
    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint amount0, uint amount1) {
         //获取储备0，储备1
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        //带入变量
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        //获取当前合约在token0合约中的余额
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        //获取当前合约在token1合约中的余额
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        //从当前合约的balanceof映射中获取当前合约自身的流动性数值
        uint liquidity = balanceOf[address(this)];
         
        //返回铸造费开关
        bool feeOn = _mintFee(_reserve0, _reserve1);
        //获取totalSupply，必须在此定义，因为totalSupply可以在mintfee中更新
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        //aomount0=流动性数量*余额0/totalSupply 使用余额确保按比例分配
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        //aomount1=流动性数量*余额1/totalSupply 使用余额确保按比例分配
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        //确认aomount0和aomount1都大于0
        require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        //销毁当前合约内的流动性数量
        _burn(address(this), liquidity);
        //将amount0数量的_token0发送给to地址
        _safeTransfer(_token0, to, amount0);
        //将amount1数量的_token1发送给to地址
        _safeTransfer(_token1, to, amount1);
        //更新余额
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        
        //更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date

        //触发销毁事件
        emit Burn(msg.sender, amount0, amount1, to);
    }
    /**
      * @dev 交换方法
      * @param to to地址
      * @param amount0 输出数额0
      * @param amount1 输出数额1
      * @param data 用于回调的数据
      * @notice 应该从执行重要安全检查的合同中调用此低级功能
      */
    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        //确认amount0Out和amount1Out都大于0
        require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        //获取储备量0和储备量1
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        //确认取出的值小于储备量的值
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');
        
        //初始化变量
        uint balance0;
        uint balance1;
        //标记token{0，1}的作用域，避免堆栈太深的错误
        { // scope for _token{0,1}, avoids stack too deep errors
         //定义一个临时变量，可以节省gas
        address _token0 = token0;
        address _token1 = token1;
        //判断to地址不能是token0和token1的合约地址
        require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
        //如果取出数额大于0，则把取出的数量发送给to地址
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        //如果data的长度大于0，调用to地址的接口，用于闪电贷
        if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
        //更新余额0.1==当前合约在token0，1合约内的余额
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        //如果余额0>储备0-amount0out则amount0in =余额0-（储备0-amount0out） 否则amount0in=0
        // 这段代码的作用是计算当前交易将会向合约中转入多少个代币0
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        //确认“输出数量0||1”大于0
        require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
         //标记token{0，1}的作用域，避免堆栈太深的错误
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors

        //调整后的余额0=余额0*1000-(amount0in*3)
        uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
        uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
        //确认balance0Adjusted*balance1Adjusted>=储备0*储备1*1000000
        //此功能的作用是确认路由合约已经收税
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'UniswapV2: K');
        }
        
        //更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        //触发交换事件
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }
    /**
     * @dev 强制平衡以匹配储备
     * @param to 
     */
    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

     /**
     * @dev 更新储备量
     * @param to 
     */
    function sync() external lock { 
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}
