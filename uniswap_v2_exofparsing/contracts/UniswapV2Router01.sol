// SPDX-License-Identifier: Unlicensed
/**
 *Submitted for verification at Etherscan.io on 2020-06-05
*/

pragma solidity >=0.6.6;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract UniswapV2Router02 is IUniswapV2Router02 {
    using SafeMath for uint;
    //部署时定义工厂合约地址和weth合约地址
    address public immutable override factory;
    address public immutable override WETH;

//修饰符：确保最后期限大于当前时间
    //以太放交易很慢，在你提交交易处理的时间内，你交易对的代币价格有可能发生变化，所以要输入一个截至期限，如果超过这个期限，则交易失败
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }

    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }
    /**
     * @dev 添加流动性的私有方法
     * @param tokenA  tokenA地址
     * @param tokenB  tokenB地址
     * @param amountADesired 期望数值A
     * @param amountBDesired 期望数值B
     * @param amountAMin 最小数值A
     * @param amountBMin 最小数值B
     * @return amountA 数量A
     * @return amountB 数量B
     */
    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        //判断tokenA和tookenB的交易对是否存在，如果不存在则创建交易对
        if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
            IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        }
        //获取储备量A和储备量B
        (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(factory, tokenA, tokenB);
        //如何储备量A和储备量B都等于0
        if (reserveA == 0 && reserveB == 0) {
            //则最小数值A和最小数值B就等于期望数值A和期望数值B
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            //否则来计算最优数量B=期望数量A*储备B/储备A
            uint amountBOptimal = UniswapV2Library.quote(amountADesired, reserveA, reserveB);
            //如果最优解数量B<=期望数量B
            if (amountBOptimal <= amountBDesired) {
                //确认最优数量B是否>=最小值B
                require(amountBOptimal >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
                //则数量A和数量B=期望数值A和最优数值B
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                //否则反运算，算A的最优解
                 //最优数量A=期望数量B*储备A/储备B
                uint amountAOptimal = UniswapV2Library.quote(amountBDesired, reserveB, reserveA);
                //断言最优解数量A<=期望数量A
                assert(amountAOptimal <= amountADesired);
                //确认最优数量A是否>=最小值A
                require(amountAOptimal >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
                //则数量A和数量B=最优数值A和期望数值B
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }
    /**
     * @dev 添加流动性的方法
     * @param tokenA tokenA地址
     * @param tokenB tokenB地址
     * @param amountADesired 期望数值A
     * @param amountBDesired 期望数值B
     * @param amountAMin 最小数值A
     * @param amountBMin 最小数值B
     * @param to 获取流动性的to地址
     * @param deadline 截至日期
     * @return amountA 添加tokenA的数量
     * @return amountB 添加tokenB的数量
     * @return liquidity 流动性代币数量
     */
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        //获取数量A，数量B
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        //计算tokenA和tokenB的交易对地址
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        //从我的地址向配对合约地址发送amountA数量的tokenA
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        //从我的地址向配对合约地址发送amountB数量的tokenB
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        //流动性代币数量=pair合约的铸造方法铸造给to地址的返回值
        liquidity = IUniswapV2Pair(pair).mint(to);
    }
    /**
     * @dev 添加eth流动性的方法
     * @param token token地址
     * @param amountTokenDesired token期望数值 
     * @param amountTokenMin token最小数值
     * @param amountETHMin eth最小数值
     * @param to 获取流动性的to地址
     * @param deadline 截至日期
     * @return amountToken 最终添加的token数量
     * @return amountETH 添加的eth数量
     * @return liquidity 流动性数量
     */
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
        //ensure判断
    ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        //获取token数量，eth数量
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        //根据token，weth地址，获取交易对地址
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        //将token数量的token从msg.sender账户中安全发送到交易对中
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        //向weth合约存入eth数量的主币
        IWETH(WETH).deposit{value: amountETH}();
        //将eth数量发送给pair合约
        assert(IWETH(WETH).transfer(pair, amountETH));
        //获得流动性的数量
        liquidity = IUniswapV2Pair(pair).mint(to);
        // refund dust eth, if any
        //如果收到的主币数量大于eht数量，则返还收到的主币数量-eth数量
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }
    /**
     * @dev 移除流动性的方法
     * @param tokenA tokenA的地址
     * @param tokenB tokenB的地址
     * @param liquidity 流动性数量
     * @param amountAMin tokenA的最小值
     * @param amountBMin tokenB的最小值
     * @param to 接受代币的地址
     * @param deadline 截至日期
     * @return amountA 取出tokenA的数量
     * @return amountB 取出tokenB的数量
     */
    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        //计算tokenA和tokenB的交易对的地址
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        //将流动性数量从用户发送到pair地址
        IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        //根据pair合约销毁流动性数量，把计算出来能取出的tokenA和tokenB的数量发送给to地址
        (uint amount0, uint amount1) = IUniswapV2Pair(pair).burn(to);
        //进行排序
        (address token0,) = UniswapV2Library.sortTokens(tokenA, tokenB);
        //获取取出tokenA和tokenB对应的数量
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        //判断取出的数量A的数量是否大于最小值
        require(amountA >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');
        //判断取出的数量B的数量是否大于最小值
        require(amountB >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
    }

    /**
     * @dev 移除以太坊的动性
     * @param token token地址
     * @param liquidity 流动性数量
     * @param amountTokenMin token期望数值
     * @param amountETHMin eth期望数值
     * @param to 接受地址
     * @param deadline 截至日期
     * @return amountToken 取出token数量
     * @return amountETH 取出eth数量
     */
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
        //获取能够取出的token数量和eth数量
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        //把能够去除的token数量发送给接收地址
        TransferHelper.safeTransfer(token, to, amountToken);
        //把weth换成eth
        IWETH(WETH).withdraw(amountETH);
        //把转换的eth发送给接收地址 
        TransferHelper.safeTransferETH(to, amountETH);
    }
    /**
     * @dev 带签名移除流动性
     * @notice 主要是为了节省gas，因为一般流程是用户批准uniswap合约使用他们的流动性代币，然后再把流动性代币发送给合约销毁，
     * 这样会产生两次的gas费用，这里直接批准和发送一起操作，只需要交付一次gas费用
     * @param tokenA tokenA地址
     * @param tokenB tokenB地址
     * @param liquidity 流动性数量
     * @param amountAMin tokenA的最小值
     * @param amountBMin tokenB的最小值
     * @param to 接收地址
     * @param deadline 截止日期
     * @param approveMax 允许合约操作的最大数量
     * @param v 签名验证
     * @param r 签名验证
     * @param s 签名验证
     * @return amountA 获取的tokenA的数量
     * @return amountB 获取的tokenB的数量
     */
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountA, uint amountB) {
        //获取tokenA和tokenB组成的交易对的地址
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        //如果approveMax是允许的流动性最大值,则value的就等于用户拥有的流动性，如果不是，则返回传入的流动性数值
        uint value = approveMax ? uint(-1) : liquidity;
        //签名授权转移一步操作
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        //获取用户能够取出的tokenA的数量和tokenB的数量，并且发送刚给接收地址
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    /**
     * @dev 授权移除eth流动性
     * @param token token地址
     * @param liquidity 流动性数量
     * @param amountTokenMin token最小值
     * @param amountETHMin eth最小值
     * @param to 接收地址
     * @param deadline 截至日期
     * @param approveMax 是否批准流动性最大值
     * @param v 签名验证
     * @param r 签名验证
     * @param s 签名验证
     * @return amountToken 取出的token数量 
     * @return amountETH 取出的eth数量
     */
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountToken, uint amountETH) {
        //获取token和eth组成的交易对地址
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        //如果approveMax是允许的流动性最大值,则value的就等于用户拥有的流动性，如果不是，则返回传入的流动性数值
        uint value = approveMax ? uint(-1) : liquidity;
        //批准转移流动性到当前合约
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        //把获取到的token数量和eth数量发送给接收地址
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }
    
    /**
     * @dev 移除eth流动性，但是和eth组成的交易对的token是需要收手续费的
     * @param token token地址
     * @param liquidity 流动性数量
     * @param amountTokenMin  token最小数量
     * @param amountETHMin eth最小数量
     * @param to 接收地址
     * @param deadline 截止日期
     */
    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountETH) {
        //获取取出的eth的数量
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        //把当前合约中的token地址发送给接收地址
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        //转换eth
        IWETH(WETH).withdraw(amountETH);
        //把转换的eth发送给接收地址
        TransferHelper.safeTransferETH(to, amountETH);
    }
    /**
     * @dev 授权移除流动性
     * @param token
     * @param liquidity 
     * @param amountTokenMin 
     * @param amountETHMin 
     * @param to 
     * @param deadline 
     * @param approveMax 
     * @param v 
     * @param r 
     * @param s 
     */
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountETH) {
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }
    /**
     * @dev 私有交换
     * @notice 要求初始金额已经发送到第一对
     * @param amounts 数组金额
     * @param path 路径数组
     * @param _to to地址
     */
    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        //遍历数组
        for (uint i; i < path.length - 1; i++) {
            //输入地址 输出地址=（当前地址，下一个地址）
            (address input, address output) = (path[i], path[i + 1]);
            //token0=排序（输入地址，输出地址）
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            //输出数量 = 数额数组下一个数额
            uint amountOut = amounts[i + 1];
            //输出数额0，输出数额1= 输入地址==token0 ？ （0，输出数额）：（输出数额,0）
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            //to地址= i<路径长度-2 ？ （输出地址，路径下下个地址）的pair合约地址：to地址
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            //调用（输入地址，输出地址）的pair合约地址的交换方法（输入数额0，输入数额1，to地址，0x00）bytes(0)不开启闪电贷
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }
    /**
     * @dev 根据精确的token交换尽量多的token
     * @param amountIn 精确的输入数额
     * @param amountOutMin 最小输入数额
     * @param path 路径数组
     * @param to 接收地址
     * @param deadline 截至日期
     * @return amounts 数组数额
     */
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        //数组数额=遍历数组（输入数额*997*储备量out）/（储备量in*1000 + 输入数额*997）
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amountOutput = UniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        payable
        ensure(deadline)
    {
        require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        ensure(deadline)
    {
        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountOut)
    {
        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountIn)
    {
        return UniswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }
}

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

library UniswapV2Library {
    using SafeMath for uint;
     
     /**
      * @dev 排序token地址的方法
      * @param tokenA tokenA地址
      * @param tokenB tokenB地址
      * @return token0 排序后的较小的地址
      * @return token1 排序后的较大的地址
      * @notice 返回排序的令牌地址，用于处理按此排序的对中的返回值
      */
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        //确认tokenA不等于tokenB
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        //排序token地址
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        //确认token地址不等于0地址 
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }
    /**
     * @dev 获取配对方法
     * @param factory 工厂合约地址
    * @param tokenA tokenA地址
    * @param tokenB tokenB地址
     */
    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        //排序token地址
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        //根据排序的token地址计算creat2的pair地址
        pair = address(
            //把传入的数值在进行打包哈希，取哈希之后的前256为字符
            uint(keccak256(abi.encodePacked(
            //hex'ff' 是 Solidity 中的一种字面量表示方式，表示十六进制数值 0xff，在这里是作为一个固定的前缀用于构造 keccak256 哈希。
            //这个固定前缀是用于构造不同的 Solidity 函数的函数签名，以确保函数的唯一性。
                hex'ff',
                //工厂合约地址
                factory,
                //把token0和token1打包哈希计算出盐
                keccak256(abi.encodePacked(token0, token1)),
                //pair合约bytecode的哈希值
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }
    /**
     * @dev 获取储备量
     * @param factory 工厂合约地址
     * @param tokenA TokenA合约地址
     * @param tokenB tokenB合约地址
     * @return reserveA tokenA的储备量
     * @return reserveB tokenB的储备量
     */
    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        //获取排序后token0的地址
        (address token0,) = sortTokens(tokenA, tokenB);
        //通过计算除配对合约的地址来获取TokenA和TokenB交易对中的储备量
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        //判断交易对中的顺序是否是正序给的，然后来获取对应代币的储备量
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }
     /**
      * @dev 对价计算
      * @param amountA 数值A
      * @param reserveA 储备量A
      * @param reserveB  储备量B
      * @return amountB  数值B
      * @notice 给定一定数量的资产和货币对储备金，则返回等值的其他资产
      */
    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        //确认数量A>0
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        //确认储备量0和储备量1
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        //数值B=数值A*储备量B/储备量A
        amountB = amountA.mul(reserveB) / reserveA;
    }

    /**
     * @dev 获取输出数额
     * @param amountIn 
     * @param reserveIn 
     * @param reserveOut
     * @return  amountOut 数额数组
     */
    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    /**
     * @dev 获取输出数额
     * @param factory  工厂合约地址
     * @param amountIn 输入数组
     * @param path 路径数组
     * @return  amounts 数额数组
     */
    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        //确认路径数组长度>=2
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        //初始化数组
        amounts = new uint[](path.length);
        //数额数组[0] =amountin
        amounts[0] = amountIn;
        //遍历路径数组，path长度-1
        for (uint i; i < path.length - 1; i++) {
            //储备量
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}