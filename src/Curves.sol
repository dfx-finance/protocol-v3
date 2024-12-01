// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ABDKMath64x64} from "./lib/ABDKMath64x64.sol";
import {Storage} from "./Storage.sol";

library Curves {
    using ABDKMath64x64 for int128;

    event Approval(address indexed _owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function add(uint256 x, uint256 y, string memory errorMessage) private pure returns (uint256 z) {
        require((z = x + y) >= x, errorMessage);
    }

    function sub(uint256 x, uint256 y, string memory errorMessage) private pure returns (uint256 z) {
        require((z = x - y) <= x, errorMessage);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(Storage.Curve storage curve, address recipient, uint256 amount) external returns (bool) {
        _transfer(curve, msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(Storage.Curve storage curve, address spender, uint256 amount) external returns (bool) {
        _approve(curve, msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`
     */
    function transferFrom(Storage.Curve storage curve, address sender, address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(curve, sender, recipient, amount);
        _approve(
            curve, sender, msg.sender, sub(curve.allowances[sender][msg.sender], amount, "Curve/insufficient-allowance")
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(Storage.Curve storage curve, address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _approve(
            curve,
            msg.sender,
            spender,
            add(curve.allowances[msg.sender][spender], addedValue, "Curve/approval-overflow")
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(Storage.Curve storage curve, address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        _approve(
            curve,
            msg.sender,
            spender,
            sub(curve.allowances[msg.sender][spender], subtractedValue, "Curve/allowance-decrease-underflow")
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is public function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(Storage.Curve storage curve, address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        curve.balances[sender] = sub(curve.balances[sender], amount, "Curve/insufficient-balance");
        curve.balances[recipient] = add(curve.balances[recipient], amount, "Curve/transfer-overflow");
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `_owner`s tokens.
     *
     * This is public function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `_owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(Storage.Curve storage curve, address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        curve.allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
}
