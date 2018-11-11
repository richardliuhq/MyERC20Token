var MyERC20Token = artifacts.require('./MyERC20Token.sol')
var MyTokenManage = artifacts.require('./MyTokenManage.sol')

module.exports = function (deployer) {
  deployer.deploy(MyERC20Token)
  deployer.deploy(MyTokenManage)
}
