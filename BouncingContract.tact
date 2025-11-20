// BouncingContract.tact
import "@stdlib/ownable";

contract BouncingContract with Ownable {

    // 接收任意内部消息的接收器
    // 所有的内部消息都会进入这里，并且会触发 RichBounce
    receive(message: Slice) {
        // 核心逻辑:
        // 为了触发 RichBounce，合约需要显式地执行一个 `commit()` 之前的操作，
        // 然后在执行过程中遇到一个运行时错误 (runtime error) 或者显式使用 `throw()`。
        //
        // 在 Tact 中，最干净的方法是利用 Tonnel 的消息处理和 `require()` 或 `throw()`。
        // 任何非法的操作或使用 `require(false)` 都会导致执行失败。
        //
        // 由于任务要求 "接受任意消息都报错"，我们使用一个硬编码的错误。
        // 注意：RichBounce 需要合约 B 试图发回一个回复，但在发送前失败。
        // 在 FunC/Tact 中，一个简单的 `throw()` 会确保回弹 (bounce) 发生，
        // 并且如果消息是可回弹的 (bounceable)，它会以 RichBounce 形式返回给发送者。

        // 显式抛出错误，触发合约执行失败
        throw(101); // 错误代码 101: "Always Bounce Error"
        
        // 另一种确保失败的方式是：
        // require(false, "Contract B always bounces!"); 
        // 但 throw() 语义更直接地表达了运行时错误。
    }

    // 额外的接收器，确保外部消息也会被拒绝（尽管任务只关注内部消息）
    receive("Deploy") {
        // 部署时设置所有者
        self.owner = sender();
    }
}
