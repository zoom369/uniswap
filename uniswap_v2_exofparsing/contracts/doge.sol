/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

/**

*/


/*
_________________________________________________________
                                                                                                                                                                                                               
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface Token {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}



library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract Sinceredoge is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    //这个地址拥有的返回token数量
    mapping (address => uint256) private _rOwned;
    //这个地址拥有的token数量
    mapping (address => uint256) private _tOwned;
    //查询一个地址授权另一个地址使用的token数量
    mapping (address => mapping (address => uint256)) private _allowances;
    //查询地址是否位收税地址
    mapping (address => bool) private _isExcludedFromFee;
    
    //定义一个uint256位的最大值
    uint256 private constant MAX = ~uint256(0);
    //token总数量
    uint256 private constant _tTotal = 100000000000 * 10**6 * 10**9;
    //返回的token数量
    //100000000
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    //收取手续费的token数量
    uint256 private _tFeeTotal;
    
    //买币收取税点
    uint256 private _redisFeeOnBuy = 2;
    //买币收取费用
    uint256 private _taxFeeOnBuy = 6;
    //买币收取税点
    uint256 private _redisFeeOnSell = 2;
    //买币收取费用
    uint256 private _taxFeeOnSell = 6;
    
    //收取税点
    uint256 private _redisFee;
    //税费
    uint256 private _taxFee;
    
    //代币名称
    string private constant _name = "SincereDoge";
    //代币符号
    string private constant _symbol = "SDoge";
    //代币单位
    uint8 private constant _decimals = 9;
    
    //发展地址
    address payable private _developmentAddress = payable(0x637457e5b3175Ed49e8fA63Af4e6C815D2e99b42); 
    //市场地址
    address payable private _marketingAddress = payable(0xFd0183258934a8C90f1F9c0B2e7F821B5E526666);
    
    //重定义路由合约
    IUniswapV2Router02 public uniswapV2Router;
    //定义一个pair合约地址
    address public uniswapV2Pair;
    
    //是否允许交易
    bool private inSwap = false;
    //是否启用了交换功能
    bool private swapEnabled = true;
    
    //防重入
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        //定义部署合约的地址为部署时接收币的地址
        _rOwned[_msgSender()] = _rTotal;
        //加载路由合约
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //路由合约赋值
        uniswapV2Router = _uniswapV2Router;
        //使用路由合约调用工厂合约的方法创建本合约的代币和weth代币的交易对
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        
        //定义部署地址为收税地址
        _isExcludedFromFee[owner()] = true;
        //定义本合约地址为收税地址
        _isExcludedFromFee[address(this)] = true;
        //定义发展地址为收税地址
        _isExcludedFromFee[_developmentAddress] = true;
        //定义市场地址为收税地址
        _isExcludedFromFee[_marketingAddress] = true;
        
        //成功触发交易事件，把所有token发送给部署地址
        emit Transfer(address(0x0000000000000000000000000000000000000000), _msgSender(), _tTotal);
    }

    modifier onlyDev() {
        //验证调用者地址是否为部署地址，调用者地址是否为发展地址
        require(owner() == _msgSender() || _developmentAddress == _msgSender(), "Caller is not the dev");	
        _;	
    }
     
     //只读方法，返回代币名称
    function name() public pure returns (string memory) {
        return _name;
    }
    //只读方法，返回代币符号
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    //只读方法，返回代币单位
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    //只读方法，返回代币数量
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    
    //查询地址拥有的代币数量
    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }
    //发送代币方法
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    //查询我批准另一个账户使用我这个账户的多少代币
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    //批准方法，批准spender账户使用我的账户amount数量的代币
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
   
    //批准交易的方法
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        //当批准账户花费批准额度时，则从批准额度减去这次交易的数量
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    //无线发币的方法，通过修改_rTotal的金额，然后无限制的发送代币给_rOwned地址
    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    //内部交易方法，owner允许spender使用amount数量的代表
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    //内部交易方法
    function _transfer(address from, address to, uint256 amount) private {
        //验证from，to地址不是空地址，交易的amount数量不小于0
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        

        _redisFee = 0;
        _taxFee = 0;
        
        if (from != owner() && to != owner()) {
            
            //查询本合约的token数量
            uint256 contractTokenBalance = balanceOf(address(this));
            //判断交易开启以及from不等于交易对地址，以及交易功能开启，以及本合约代币余额大于0
            if (!inSwap && from != uniswapV2Pair && swapEnabled && contractTokenBalance > 0) {
                //调用uniswap的收费交易方法
                swapTokensForEth(contractTokenBalance);
                //查询合约中eth的数量给到contractETHBalance
                uint256 contractETHBalance = address(this).balance;
                //如果eth的数量大于0
                if(contractETHBalance > 0) {
                    //设置以太的收费
                    sendETHToFee(address(this).balance);
                }
            }
            
            //如果发送地址是uniswap的配对地址 或者接收地址是uniswap的路由地址
            if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
                //则收费点位买入点
                _redisFee = _redisFeeOnBuy;
                //_taxFee为_taxFeeOnBuy
                _taxFee = _taxFeeOnBuy;
            }
            //如果接收地址是uniswap的配对地址 或者发送地址是uniswap的路由地址
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnSell;
                _taxFee = _taxFeeOnSell;
            }
            //如果from，to不是收税地址或者(from != uniswapV2Pair && to != uniswapV2Pair)
            if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
                _redisFee = 0;
                _taxFee = 0;
            }
            
        }
        //交换方法，但是已经经过扣除手续费的一系列计算 amount的数量已经被收取手续费
        _tokenTransfer(from,to,amount);
    }

    /**
     * @dev 重写uniswap中的eth交易对方法
     * @param tokenAmount token数量
     */
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        //定义交易对地址路径长度，为2
        address[] memory path = new address[](2);
        //路径地址中下标为0的地址为本合约地址
        path[0] = address(this);
        //下标为1的地址为weth代币地址
        path[1] = uniswapV2Router.WETH();
        //允许uniswap路由合约操作本合约的token代币数量为tokenAmount
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        //开启uniswap的收取手续费的交易功能
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    
    /**
     * @dev 设置收取费用的地址的收费逻辑
     * @param amount token数量
     */
    function sendETHToFee(uint256 amount) private {
        //_developmentAddress收取合约合约中token数量的一半
        _developmentAddress.transfer(amount.div(2));
        //_marketingAddress收取合约合约中token数量的一半
        _marketingAddress.transfer(amount.div(2));
    }
    
    //交易方法
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        _transferStandard(sender, recipient, amount);
    }

    event tokensRescued(address indexed token, address indexed to, uint amount);
    function rescueForeignTokens(address _tokenAddr, address _to, uint _amount) public onlyDev() {
        emit tokensRescued(_tokenAddr, _to, _amount);	
        Token(_tokenAddr).transfer(_to, _amount);
    }
    //更新发展地址
    event devAddressUpdated(address indexed previous, address indexed adr);
    function setNewDevAddress(address payable dev) public onlyDev() {
        emit devAddressUpdated(_developmentAddress, dev);	
        _developmentAddress = dev;
        _isExcludedFromFee[_developmentAddress] = true;
    }
    //市场更新 更新市场地址
    event marketingAddressUpdated(address indexed previous, address indexed adr);
    function setNewMarketingAddress(address payable markt) public onlyDev() {
        emit marketingAddressUpdated(_marketingAddress, markt);	
        _marketingAddress = markt;
        _isExcludedFromFee[_marketingAddress] = true;
    }
    
 //计算手续费的方法
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
 //计算手续费的方法
    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate =  _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }
 //计算手续费的方法
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    receive() external payable {}
    
    /**
     * 
     * @param tAmount token数量
     */
     //计算手续费的方法
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(tAmount, _redisFee, _taxFee);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }
     
     //计算收费费率
    function _getTValues(uint256 tAmount, uint256 taxFee, uint256 TeamFee) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tTeam = tAmount.mul(TeamFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }
 //计算手续费的方法
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }
    
    /**
     * @dev 得到两种代币数量的相除的值
     */
	function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
  
     /**
      * @dev 获得供应数量
      * @return _rTotal 返回目前两种代币的供应数量
      * @return _tTotal 返回目前两种代币的供应数量
      */
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    /**
     * @dev 手动交换
     * 可以直接抽空池子
     */
    function manualswap() external {
        require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress || _msgSender() == owner());
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    
    //手动发送
    //可以把池子中收取的手续费全部发送到收费地址
    function manualsend() external {
        require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress || _msgSender() == owner());
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
    //设置收费费率
    function setFee(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyDev {
	    require(redisFeeOnBuy < 11, "Redis cannot be more than 10.");
	    require(redisFeeOnSell < 11, "Redis cannot be more than 10.");
	    require(taxFeeOnBuy < 7, "Tax cannot be more than 6.");
	    require(taxFeeOnSell < 7, "Tax cannot be more than 6.");
        _redisFeeOnBuy = redisFeeOnBuy;
        _redisFeeOnSell = redisFeeOnSell;
        _taxFeeOnBuy = taxFeeOnBuy;
        _taxFeeOnSell = taxFeeOnSell;
    }
    
    //设置是否开启交换功能
    function toggleSwap(bool _swapEnabled) public onlyDev {
        swapEnabled = _swapEnabled;
    }

     //设置收费地址
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }
}